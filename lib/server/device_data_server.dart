import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:veego_desktop_application/server/logo_backup_handler.dart';

class DeviceDataServer {
  static bool _started = false;
  static HttpServer? _server;
  static String? _ip;
  static int? _port;
  static Directory get baseDirectory => _dbFolder;

  static final Directory _dbFolder =
  Directory("C:/veego_utility_desktop_application");

  static String get ip => _ip ?? "Starting...";
  static int get port => _port ?? 0;
  static bool get isRunning => _server != null;

  static void _ensureDbFolder() {
    if (!_dbFolder.existsSync()) {
      _dbFolder.createSync(recursive: true);
    }
  }

  static Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        return addr.address;
      }
    }
    return "127.0.0.1";
  }

  static Future<Response> _handleDbFileUpload(Request request) async {
    try {
      _ensureDbFolder();

      final contentType = request.headers['Content-Type'] ?? '';
      if (!contentType.startsWith('multipart/form-data')) {
        return Response(400,
            body: "Invalid content type, must be multipart/form-data");
      }

      final deviceName = request.headers['X-Device-Name'];
      if (deviceName == null || deviceName.isEmpty) {
        throw Exception('X-Device-Name header missing');
      }

      final fileType = request.headers['X-File-Type'];
      if (fileType == null || fileType.isEmpty) {
        throw Exception('X-File-Type header missing');
      }

      final checksum = request.headers['X-Checksum'];
      if (checksum == null || checksum.isEmpty) {
        throw Exception('X-Checksum header missing');
      }

      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response(400, body: "Missing boundary in content type");
      }

      final bodyBytes = await request.read().expand((x) => x).toList();
      final transformer = MimeMultipartTransformer(boundary);
      final parts = transformer.bind(Stream.fromIterable([bodyBytes]));

      await for (var part in parts) {
        final contentDisposition = part.headers['content-disposition'] ?? '';
        if (contentDisposition.contains('filename=')) {
          final filenameReg = RegExp(r'filename="(.+)"');
          final match = filenameReg.firstMatch(contentDisposition);
          final filename = match?.group(1) ??
              "device_${DateTime.now().millisecondsSinceEpoch}.db";

          late String folderPath;

          if (fileType == 'Screenshots') {
            folderPath = "${_dbFolder.path}/$deviceName/screenshots";
          } else {
            folderPath = "${_dbFolder.path}/$deviceName/data";
          }

          Directory(folderPath).createSync(recursive: true);
          final file = File("$folderPath/$filename");

          final sink = file.openWrite();
          await part.pipe(sink);
          await sink.flush();
          await sink.close();

          return Response.ok("DB file saved successfully");
        }
      }

      return Response(400, body: "No file found in multipart request");
    } catch (e) {
      return Response.internalServerError(body: "Failed to save DB file");
    }
  }

  static Future<Response> _handleHealth() async {
    return Response.ok("Health OK");
  }

  static Future<void> start() async {
    if (_started) return;
    _started = true;

    _ensureDbFolder();

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler((Request request) async {
      final logoResponse = await LogoBackupHandler.handle(request);
      if (logoResponse != null) return logoResponse;

      if (request.url.path == 'health') {
        return await _handleHealth();
      }
      if (request.method == 'POST' && request.url.path == 'backup') {
        return await _handleDbFileUpload(request);
      }
      return Response.notFound("Unknown API");
    });

    _server = await io.serve(handler, '0.0.0.0', 0);
    _ip = await _getLocalIp();
    _port = _server!.port;
  }

  static Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _started = false;
    }
  }
}

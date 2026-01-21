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

  static final Directory _dbFolder = Directory("C:/veego_backups");
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
      print("Device name :$deviceName");
      if (deviceName == null || deviceName.isEmpty) {
        throw Exception('X-Device-Name header missing');
      }
      final fileType = request.headers['X-File-Type'];
      print("File Type :$fileType");
      if (fileType == null || fileType.isEmpty) {
        throw Exception('X-Device-Name header missing');
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


          late File file ;
          if(fileType=='Screenshots'){
            file = File("${_dbFolder.path}/$deviceName/screenshots/$filename");
          }else if(fileType=='Database'){
            file = File("${_dbFolder.path}/$deviceName/data/$filename");
          }
          final directory = file.parent;
          if (!directory.existsSync()) {
            directory.createSync(recursive: true);
            print("Directory created: ${directory.path}");
          } else {
            print("Directory already exists: ${directory.path}");
          }

          // Now you can safely use the file
          print("Device name Path: $file");
          
          final sink = file.openWrite();
          await part.pipe(sink);
          await sink.flush();
          await sink.close();

          debugPrint("DB FILE RECEIVED & SAVED");
          debugPrint("Path: ${file.path}");

          return Response.ok("DB file saved successfully");
        }
      }
      return Response(400, body: "No file found in multipart request");
    } catch (e, st) {
      debugPrint("DB FILE SAVE ERROR: $e");
      debugPrint("$st");
      return Response.internalServerError(body: "Failed to save DB file");
    }
  }

  static Future<Response> _handleHealth() async {
    return Response.ok("Health OK");
  }

  static Future<void> start() async {
    if (_started) return;
    _started = true;

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler((Request request) async {
      final logoResponse = await LogoBackupHandler.handle(request);
      if (logoResponse != null) return logoResponse;
      debugPrint(
          "[${DateTime.now()}] Incoming: ${request.method} /${request.url.path}"
      );
      try {


        if (request.url.path == 'health') {
          return await _handleHealth();
        }
        if (request.method == 'POST' && request.url.path == 'backup') {
          return await _handleDbFileUpload(request);
        }
        return Response.notFound("Unknown API");
      } catch (e, st) {
        debugPrint("$st");
        return Response.internalServerError();
      }
    });

    _server = await io.serve(handler, '0.0.0.0', 0);
    _ip = await _getLocalIp();
    _port = _server!.port;

    Timer.periodic(const Duration(seconds: 10), (_) {
    });
  }


  static Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _started = false;
      debugPrint("Server stopped");
    }
  }
}

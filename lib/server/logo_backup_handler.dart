import 'dart:io';
import 'package:shelf/shelf.dart';

class LogoBackupHandler {
  static const String _baseDir =
      r'C:\ProgramData\MyFlutterApp\devices';

  static Future<Response?> handle(Request request) async {
    if (request.url.path != 'logo') return null;

    if (request.method == 'GET') {
      return _sendLogo(request);
    }

    if (request.method == 'POST') {
      return _uploadLogo(request);
    }

    return Response(405);
  }

  static String _getLogoPath(Request request) {
    final deviceName = request.headers['X-Device-Name'];

    if (deviceName == null || deviceName.isEmpty) {
      throw Exception('X-Device-Name header missing');
    }
    return '$_baseDir/$deviceName/logo.jpg';
  }

  static Future<Response> _uploadLogo(Request request) async {
    final path = _getLogoPath(request);
    final file = File(path);
    await file.create(recursive: true);

    final sink = file.openWrite();
    await request.read().pipe(sink);
    await sink.close();

    return Response.ok('Logo uploaded');
  }

  static Future<Response> _sendLogo(Request request) async {
    final path = _getLogoPath(request);
    final file = File(path);

    if (!await file.exists()) {
      return Response.notFound('Logo not found');
    }

    return Response.ok(
      file.openRead(),
      headers: {'Content-Type': 'image/jpeg'},
    );
  }
}

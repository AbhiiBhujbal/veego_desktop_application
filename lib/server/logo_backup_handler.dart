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

  static String _getDeviceDir(Request request) {
    final deviceName = request.headers['X-Device-Name'];

    if (deviceName == null || deviceName.isEmpty) {
      throw Exception('X-Device-Name header missing');
    }

    return '$_baseDir/$deviceName';
  }

  static Future<Response> _uploadLogo(Request request) async {
    final deviceDir = Directory(_getDeviceDir(request));
    await deviceDir.create(recursive: true); // ✅ auto create folder

    final file = File('${deviceDir.path}/logo.jpg');

    final sink = file.openWrite();
    await request.read().pipe(sink);
    await sink.close();

    return Response.ok('Logo uploaded successfully');
  }

  static Future<Response> _sendLogo(Request request) async {
    final file =
    File('${_getDeviceDir(request)}/logo.jpg');

    if (!await file.exists()) {
      return Response.notFound('Logo not found');
    }

    return Response.ok(
      file.openRead(),
      headers: {'Content-Type': 'image/jpeg'},
    );
  }
}

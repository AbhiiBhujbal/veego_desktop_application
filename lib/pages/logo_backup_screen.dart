import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LogoBackupScreen extends StatefulWidget {
  const LogoBackupScreen({super.key});

  @override
  State<LogoBackupScreen> createState() => _LogoBackupScreenState();
}

class _LogoBackupScreenState extends State<LogoBackupScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  final String deviceName = "Device_001";
  final String serverUrl = "http://localhost:8080/logo";

  File logoFile = File('assets/images/veego-logo.png');

  void _onLogoTap() {
    final now = DateTime.now();

    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 1)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTapTime = now;

    if (_tapCount == 3) {
      _tapCount = 0;
      _uploadLogo();
    }
  }

  Future<void> _uploadLogo() async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(serverUrl),
    );

    request.headers['X-Device-Name'] = deviceName;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        logoFile.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo uploaded')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logo Upload')),
      body: Center(
        child: GestureDetector(
          onTap: _onLogoTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                logoFile,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 12),
              const Text('Tap logo 3 times to upload'),
            ],
          ),
        ),
      ),
    );
  }
}

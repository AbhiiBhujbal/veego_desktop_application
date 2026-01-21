import 'dart:io';
import 'package:flutter/material.dart';

class LogoBackupScreen extends StatefulWidget {
  const LogoBackupScreen({super.key});

  @override
  State<LogoBackupScreen> createState() => _LogoBackupScreenState();
}

class _LogoBackupScreenState extends State<LogoBackupScreen> {
  static const String baseDir =
      r'C:\ProgramData\MyFlutterApp\devices';

  late Future<List<FileSystemEntity>> _logosFuture;

  @override
  void initState() {
    super.initState();
    _logosFuture = _loadLogos();
  }

  Future<List<FileSystemEntity>> _loadLogos() async {
    final dir = Directory(baseDir);

    if (!await dir.exists()) {
      return [];
    }

    final List<FileSystemEntity> logos = [];

    await for (final entity in dir.list()) {
      if (entity is Directory) {
        final logoFile = File('${entity.path}/logo.jpg');
        if (await logoFile.exists()) {
          logos.add(logoFile);
        }
      }
    }
    return logos;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Logos'),
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _logosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No logos found'),
            );
          }

          final logos = snapshot.data!;

          return ListView.builder(
            itemCount: logos.length,
            itemBuilder: (context, index) {
              final file = logos[index] as File;
              final deviceId =
                  file.parent.path.split(Platform.pathSeparator).last;

              return ListTile(
                leading: Image.file(
                  file,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
                title: Text(deviceId),
                subtitle: const Text('logo.jpg'),
                onTap: () {
                },
              );
            },
          );
        },
      ),
    );
  }

  // void _openPreview(BuildContext context, File file, String deviceId) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => LogoPreviewScreen(
  //         file: file,
  //         deviceId: deviceId,
  //       ),
  //     ),
  //   );
  // }
}

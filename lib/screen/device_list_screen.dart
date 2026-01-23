import 'dart:io';
import 'package:flutter/material.dart';
import '../server/device_data_server.dart';
import 'device_menu_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<FileSystemEntity> dbFiles = [];
  bool loading = true;
  final String backupDir = "C:/veego_backups";
  @override
  void initState() {
    super.initState();
    _initServer();
    _loadFolders();
  }

  @override
  void dispose() {
    DeviceDataServer.stop();
    super.dispose();
  }
  Future<void> _initServer() async {
    try {
      await DeviceDataServer.start();
      debugPrint("Server initialized successfully");
    } catch (e) {
      debugPrint("Server failed to start: $e");
    }
  }
  void _loadFolders() {
    final directory = Directory(backupDir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final folders = directory
        .listSync()
        .where((entity) => entity is Directory)
        .toList();

    setState(() {
      dbFiles = folders;
      loading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4263),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4263),
        title: const Text(
          "List of Devices",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : dbFiles.isEmpty
          ? const Center(child: Text("No DB files found"))
          : ListView.builder(
        itemCount: dbFiles.length,
        itemBuilder: (context, index) {
          final file = dbFiles[index];
          final fileName =
              file.path.split(Platform.pathSeparator).last;

          return ListTile(
            title: Text(
                fileName,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            onTap: () {
              final fileName = file.path.split(Platform.pathSeparator).last;
              print("File name of Device list screen:${fileName}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceMenuScreen(
                    deviceBasePath: file.path,
                      deviceName:fileName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

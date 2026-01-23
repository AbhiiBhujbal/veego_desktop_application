import 'dart:io';

import 'package:flutter/material.dart';

import 'dbTable_menu_databackup.dart';

class DataBackupScreen extends StatefulWidget {
  final String deviceBasePath;

  const DataBackupScreen({super.key, required this.deviceBasePath});

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen> {
  List<FileSystemEntity> _dbFiles = [];

  @override
  void initState() {
    super.initState();
    _loadDatabaseFiles();
  }

  void _loadDatabaseFiles() {
    final directory = Directory(widget.deviceBasePath);

    debugPrint('DataBackupScreen path: ${widget.deviceBasePath}');
    debugPrint('Directory exists: ${directory.existsSync()}');

    if (!directory.existsSync()) {
      debugPrint('Directory does not exist. Skipping DB load.');
      return;
    }

    final files = directory
        .listSync()
        .where((entity) {
      final isDb =
          entity is File && entity.path.toLowerCase().endsWith('.db');

      if (isDb) {
        debugPrint('DB found: ${entity.path}');
      }
      return isDb;
    })
        .toList();

    debugPrint('Total DB files found: ${files.length}');

    files.sort(
          (a, b) {
        final aTime = a.statSync().modified;
        final bTime = b.statSync().modified;
        return bTime.compareTo(aTime);
      },
    );

    setState(() {
      _dbFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F3E52),
      appBar: AppBar(
        title: const Text(
          "Data",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
        backgroundColor: const Color(0xFF2F3E52),
        elevation: 0,
      ),
      body: _dbFiles.isEmpty
          ? const Center(
        child: Text(
          'No database backup found',
          style: TextStyle(color: Colors.white70),
        ),
      )
      : ListView.separated(
        itemCount: _dbFiles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final dbFile = _dbFiles[index] as File;
          final fileName =
              dbFile.path.split(Platform.pathSeparator).last;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DbTableMenuDatabackup(dbFile: dbFile),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B4B61),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/database.png',
                      width: 22,
                      height: 22,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

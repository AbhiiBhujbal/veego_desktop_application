import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../screen/screenshot_preview_screen.dart';

class ScreenshotBackupScreen extends StatefulWidget {
  final String deviceName;

  const ScreenshotBackupScreen({super.key, required this.deviceName});

  @override
  State<ScreenshotBackupScreen> createState() =>
      _ScreenshotBackupScreenState();
}

class _ScreenshotBackupScreenState extends State<ScreenshotBackupScreen> {
  bool loading = true;
  String? error;
  List<Directory> folders = [];
  List<File> images = [];
  Directory? selectedFolder;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final screenshotDir = Directory(
        p.join('C:/veego_backups', widget.deviceName, 'screenshots'),
      );

      if (!screenshotDir.existsSync()) {
        screenshotDir.createSync(recursive: true);
      }
      final zipFiles = screenshotDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.zip'))
          .toList();

      for (final zipFile in zipFiles) {
        final bytes = zipFile.readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);

        for (final file in archive) {
          if (file.isFile) {
            final outFile =
            File(p.join(screenshotDir.path, file.name));
            outFile.createSync(recursive: true);
            outFile.writeAsBytesSync(file.content as List<int>);
          }
        }
        await zipFile.delete();
      }
      folders = screenshotDir
          .listSync()
          .whereType<Directory>()
          .toList();

      debugPrint("Total folders found: ${folders.length}");
      for (final f in folders) {
        debugPrint(f.path);
      }

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void _openFolder(Directory folder) {
    final files = folder
        .listSync()
        .whereType<File>()
        .where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return ext == '.png' || ext == '.jpg' || ext == '.jpeg';
    })
        .toList();

    debugPrint(
        "Images in ${p.basename(folder.path)}: ${files.length}");

    setState(() {
      selectedFolder = folder;
      images = files;
    });
  }

  void _goBackToFolders() {
    setState(() {
      selectedFolder = null;
      images.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4263),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4263),
        leading: selectedFolder != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToFolders,
        )
            : null,
        title: Text(
          selectedFolder == null
              ? '${widget.deviceName} Screenshots'
              : p.basename(selectedFolder!.path),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : selectedFolder == null
          ? _buildFolderList()
          : _buildImageList(),
    );
  }

  Widget _buildFolderList() {
    if (folders.isEmpty) {
      return const Center(
        child: Text(
          'No screenshot folders found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.separated(
      itemCount: folders.length,
      separatorBuilder: (_, __) => const Divider(
        color: Colors.white24,
        thickness: 1,
        height: 1,
      ),
      itemBuilder: (_, index) {
        final folder = folders[index];

        return InkWell(
          onTap: () => _openFolder(folder),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.folder,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    p.basename(folder.path),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // const Icon(
                //   Icons.chevron_right,
                //   color: Colors.white54,
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageList() {
    if (images.isEmpty) {
      return const Center(
        child: Text(
          'No screenshots found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.separated(
      itemCount: images.length,
      separatorBuilder: (_, __) => const Divider(
        color: Colors.white24,
        thickness: 1,
        height: 1,
      ),
      itemBuilder: (_, index) {
        final file = images[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ScreenshotPreviewScreen(imageFile: file),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            child: Row(
              children: [
                Image.file(
                  file,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    p.basename(file.path),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

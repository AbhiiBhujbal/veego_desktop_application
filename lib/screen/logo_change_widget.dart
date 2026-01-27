import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoChangeWidget extends StatefulWidget {
  const LogoChangeWidget({super.key});

  @override
  State<LogoChangeWidget> createState() => _LogoChangeWidgetState();
}

class _LogoChangeWidgetState extends State<LogoChangeWidget> {
  File? headerLogoFile;

  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadSavedLogo();
  }

  Future<void> _loadSavedLogo() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('header_logo_path');

    if (path != null && File(path).existsSync()) {
      setState(() {
        headerLogoFile = File(path);
      });
    }
  }
  void _handleLogoTap() {
    final now = DateTime.now();

    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTapTime = now;

    if (_tapCount == 3) {
      _tapCount = 0;
      _showChangeLogoDialog();
    }
  }

  void _showChangeLogoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Logo"),
        content: const Text("Do you want to change the logo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _pickAndSaveLogo();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSaveLogo() async {
    final XFile? pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    final File imageFile = File(pickedImage.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('header_logo_path', imageFile.path);

    setState(() {
      headerLogoFile = imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLogoTap,
      child: headerLogoFile != null && headerLogoFile!.existsSync()
          ? Image.file(
        headerLogoFile!,
        height: 40,
      )
          : Image.asset(
        'assets/images/veego-logo.png',
        height: 40,
      ),
    );
  }
}

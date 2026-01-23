import 'dart:io';
import 'package:flutter/material.dart';

class ScreenshotPreviewScreen extends StatelessWidget {
  final File imageFile;

  const ScreenshotPreviewScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4263),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4263),
        title: const Text(
            'Preview',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 800,
          height: 500,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

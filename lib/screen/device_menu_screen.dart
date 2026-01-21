import 'package:flutter/material.dart';
import 'package:veego_desktop_application/pages/comm_check.dart';
import 'package:veego_desktop_application/pages/data_backup_screen.dart';
import 'package:veego_desktop_application/pages/logo_backup_screen.dart';
import 'package:veego_desktop_application/pages/report_backup_screen.dart';
import 'package:veego_desktop_application/pages/screenshot_backup_screen.dart';

import '../server/logo_backup_handler.dart';

class DeviceMenuScreen extends StatelessWidget {
  final String deviceBasePath;
  final String deviceName;

  const DeviceMenuScreen({
    super.key, required this.deviceBasePath,required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    print("Ddatabase path :${deviceBasePath}");
    print("Devcie Name of :Device Menu Screen ${deviceName}");
    return Scaffold(
      backgroundColor: const Color(0xFF2F4263),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4263),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Device: $deviceName",
          style:  TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _menuItem(
                  context,
                  Icons.check,
                  "Comm. Check",
                   CommCheck(),
                ),
                const SizedBox(width: 40),
                _menuItem(
                  context,
                  Icons.folder,
                  "Logo(s)",
                    LogoBackupScreen(),
                ),
                const SizedBox(width: 40),
                _menuItem(
                  context,
                  Icons.camera_alt,
                  "Screenshot(s)",
                   ScreenshotBackupScreen(),
                ),
              ],
            ),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _menuItem(
                  context,
                  Icons.storage,
                  "Data(s)",
                  DataBackupScreen(deviceBasePath: '$deviceBasePath/data'),
                ),
                const SizedBox(width: 40),
                _menuItem(
                  context,
                  Icons.description,
                  "Report(s)",
                   ReportBackupScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _menuItem(
      BuildContext context,
      IconData icon,
      String label,
      Widget nextScreen,
      ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF8FB3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 42,
              color: const Color(0xFFFFD54F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

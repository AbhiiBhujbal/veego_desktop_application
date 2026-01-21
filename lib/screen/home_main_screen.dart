import 'dart:async';
import 'package:flutter/material.dart';
import 'device_list_screen.dart';
import 'package:veego_desktop_application/server/device_data_server.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreen();
}

class _HomeMainScreen extends State<HomeMainScreen> {
  final TextEditingController ipController = TextEditingController();
  Timer? _timer;

  String selectedPrinter = "Select Printer";

  final List<String> printerList = [
    "Select Printer",
    "HP LaserJet",
    "Canon Inkjet",
    "Epson Printer",
  ];

  @override
  void initState() {
    super.initState();

    DeviceDataServer.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B7280),

      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Server",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "IP   : ${DeviceDataServer.ip}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    "Port : ${DeviceDataServer.port}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    DeviceDataServer.isRunning ? "Running" : "Stopped",
                    style: TextStyle(
                      color: DeviceDataServer.isRunning
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Main Screen",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeviceListScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder,
                      size: 48,
                      color: Colors.orange,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Device Explorer",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Logs", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 10),

                    SizedBox(
                      width: 180,
                      height: 32,
                      child: TextField(
                        controller: ipController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: "Enter IP address",
                          filled: true,
                          fillColor: Colors.yellow.shade100,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          if (ipController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter IP address"),
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Connecting to ${ipController.text}",
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text("GO"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Printer is:",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      width: 200,
                      height: 32,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPrinter,
                          isExpanded: true,
                          dropdownColor: Colors.yellow.shade100,
                          items: printerList.map((printer) {
                            return DropdownMenuItem(
                              value: printer,
                              child: Text(
                                printer,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPrinter = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                if (selectedPrinter == "Select Printer")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning, color: Colors.red, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "No printer configured!",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

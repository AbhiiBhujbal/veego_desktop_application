import 'dart:io';
import 'package:flutter/material.dart';
import '../screen/table_data_screen.dart';

class DbTableMenuDatabackup extends StatelessWidget {
  final File dbFile;

  const DbTableMenuDatabackup({
    super.key,
    required this.dbFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4263),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4263),
        elevation: 0,
        title: const Text(
          "Select Table",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuItem(context, Icons.account_circle, "Accounts", "users"),
                  const SizedBox(width: 40),
                  _menuItem(context, Icons.rule, "Audit", "audit_table"),
                  const SizedBox(width: 40),
                  _menuItem(context, Icons.data_object, "TestData", "test_data"),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuItem(context, Icons.production_quantity_limits, "Product", "product_library"),
                  const SizedBox(width: 40),
                  _menuItem(context, Icons.storage, "Select DB", "select_db"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
      BuildContext context,
      IconData icon,
      String label,
      String tableName,
      ) {
    return InkWell(
      onTap: () {
        if (tableName == "select_db") {
          Navigator.pop(context);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TableDataScreen(
              dbFile: dbFile,
              tableName: tableName,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF8FB3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 42, color: const Color(0xFFFFD54F)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

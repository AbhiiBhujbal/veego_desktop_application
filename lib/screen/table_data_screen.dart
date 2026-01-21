import 'dart:io';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class TableDataScreen extends StatefulWidget {
  final File dbFile;
  final String tableName;

  const TableDataScreen({
    super.key,
    required this.dbFile,
    required this.tableName,
  });

  @override
  State<TableDataScreen> createState() => _TableDataScreenState();
}

class _TableDataScreenState extends State<TableDataScreen> {
  List<Map<String, dynamic>> data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    data = await DbHelper.loadTable(
      dbFile: widget.dbFile,
      tableName: widget.tableName,
    );
    setState(() => loading = false);
  }

  bool get showPdf =>
      widget.tableName != "users";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002147),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4263),
        title: Text(
            widget.tableName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (showPdf && data.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf,color: Colors.white),
              onPressed: _printPdf,
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : data.isEmpty
          ? const Center(
            child: Text(
              "No Data",
              style: TextStyle(color: Colors.white),
            )
          )
          : _buildTable(),
    );
  }
  Widget _buildTable() {
    final columns = data.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFF002147)), // Oxford Blue header
        dataRowColor: MaterialStateProperty.all(const Color(0xFF002147)), // Oxford Blue rows
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(
          color: Colors.white,
        ),
        columns: columns
            .map((c) => DataColumn(label: Text(c.toUpperCase())))
            .toList(),
        rows: data
            .map(
              (row) => DataRow(
            cells: columns
                .map(
                  (c) => DataCell(
                Text(row[c]?.toString() ?? ""),
              ),
            )
                .toList(),
          ),
        )
            .toList(),
      ),
    );
  }

  Future<void> _printPdf() async {
    final pdf = pw.Document();
    final columns = data.first.keys.toList();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Table.fromTextArray(
          headers: columns,
          data: data
              .map(
                (row) => columns
                .map((c) => row[c]?.toString() ?? "")
                .toList(),
          )
              .toList(),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
    );
  }
}

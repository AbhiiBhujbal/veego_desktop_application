import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/db_helper.dart';
import 'pdf_preview_screen.dart'; // full DB PDF preview

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

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

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

  bool get showPdf => widget.tableName != "users";

  double _columnWidth(String column, List<Map<String, dynamic>> rows) {
    double max = column.length.toDouble();
    for (final row in rows) {
      final value = row[column]?.toString() ?? '';
      if (value.length > max) max = value.length.toDouble();
    }
    return (max * 8).clamp(100, 1200);
  }
  bool isRowOnlyTable(String tableName) {
    return tableName == 'test_data' ||
        tableName == 'validation_report';
  }
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
        // actions: [
        //   if (showPdf && data.isNotEmpty)
        //     IconButton(
        //       icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (_) => PdfPreviewScreen(tableName: widget.tableName, rowData: {},),
        //           ),
        //         );
        //       },
        //     ),
        // ],
      ),
      body: loading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.white))
          : data.isEmpty
          ? const Center(
        child: Text(
          "No Data",
          style: TextStyle(color: Colors.white),
        ),
      )
          : _buildTable(),
    );
  }

  Widget _buildTable() {
    final columns = data.first.keys
        .where((c) => c.toLowerCase() != 'password')
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = columns.fold<double>(
          0,
              (sum, c) => sum + _columnWidth(c, data),
        );
        final screenWidth = constraints.maxWidth;
        final tableWidth =
        totalWidth < screenWidth ? screenWidth + 50 : totalWidth;

        return Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableWidth),
                  child: DataTable(
                    headingRowColor:
                    MaterialStateProperty.all(const Color(0xFF002147)),
                    dataRowColor:
                    MaterialStateProperty.all(const Color(0xFF002147)),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    dataTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    columns: columns.map((c) {
                      final width = _columnWidth(c, data);
                      return DataColumn(
                        label: SizedBox(
                          width: width,
                          child: Text(
                            c.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    rows: data.map((row) {
                      return DataRow(
                        cells: columns.map((c) {
                          final width = _columnWidth(c, data);
                          return DataCell(
                            SizedBox(
                              width: width,
                              child: Text(
                                row[c]?.toString() ?? "",
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () {
                              debugPrint('TABLE if: ${widget.tableName}, rows = ${data.length}');

                              if (isRowOnlyTable(widget.tableName)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PdfPreviewScreen(
                                      tableName: widget.tableName,
                                      rowData: row,
                                    ),
                                  ),
                                );
                              } else {
                                debugPrint('TABLE else: ${widget.tableName}, rows = ${data.length}');

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PdfPreviewScreen(
                                      tableName: widget.tableName,
                                      rows: data,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

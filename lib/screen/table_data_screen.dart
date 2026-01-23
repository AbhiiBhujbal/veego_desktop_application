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
  Map<String, double> _calculateColumnWidths(
      List<Map<String, dynamic>> rows,
      List<String> columns,
      ) {
    const double minWidth = 80;
    const double maxWidth = 420;
    const double charWidth = 7.5;

    final Map<String, double> widths = {};

    for (final col in columns) {
      int maxLen = col.length;

      for (final row in rows.take(20)) {
        final value = row[col]?.toString() ?? "";
        if (value.length > maxLen) {
          maxLen = value.length;
        }
      }

      double calculated = maxLen * charWidth;
      widths[col] = calculated.clamp(minWidth, maxWidth);
    }

    return widths;
  }
  double _columnWidth(String column, List<Map<String, dynamic>> rows) {
    double max = column.length.toDouble();

    for (final row in rows) {
      final value = row[column]?.toString() ?? '';
      if (value.length > max) {
        max = value.length.toDouble();
      }
    }
    return (max * 8).clamp(100, 1200);
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
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

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
              notificationPredicate: (n) =>
              n.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: tableWidth,
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                        const Color(0xFF002147)),
                    dataRowColor: MaterialStateProperty.all(
                        const Color(0xFF002147)),
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

  Future<void> _printPdf() async {
    final pdf = pw.Document();
    final columns = data.first.keys
        .where((c) => c.toLowerCase() != 'password')
        .toList();

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

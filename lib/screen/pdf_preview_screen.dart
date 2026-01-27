import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPreviewScreen extends StatelessWidget {
  final String tableName;

  final Map<String, dynamic>? rowData;
  final List<Map<String, dynamic>>? rows;

  const PdfPreviewScreen({
    super.key,
    required this.tableName,
    this.rowData,
    this.rows,
  });

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final bool isRowPdf = rowData != null;
    final List<Map<String, dynamic>> dataToPrint =
    isRowPdf ? [rowData!] : rows!;

    final columns = dataToPrint.first.keys
        .where((c) => c.toLowerCase() != 'password')
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(16),
        build: (_) => [
          pw.Text(
            tableName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),

          pw.Table.fromTextArray(
            headers: columns,
            data: dataToPrint
                .map((row) =>
                columns.map((c) => row[c]?.toString() ?? "").toList())
                .toList(),
            border: pw.TableBorder.all(color: PdfColors.black),

            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey,
            ),

            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),

            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.topLeft,

            columnWidths: {
              for (var i = 0; i < columns.length; i++)
                i: columns[i].toLowerCase() == 'activity'
                    ? const pw.FlexColumnWidth(6)
                    : columns[i].toLowerCase() == 'date'
                    ? const pw.FlexColumnWidth(1.5)
                    : columns[i].toLowerCase() == 'time'
                    ? const pw.FlexColumnWidth(1.5)
                    : columns[i].toLowerCase() == 'sr_no'
                    ? const pw.FlexColumnWidth(1)
                    : const pw.FlexColumnWidth(2),
            },
          )
        ],
      ),
    );

    return pdf.save();
  }
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Preview"),
        backgroundColor: const Color(0xFF2F4263),
        actions: [
          IconButton(
            icon: const Icon(
                Icons.print,
              color: Colors.white,
            ),
            tooltip: "Print PDF",
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) => _buildPdf(format),
              );
            },
          ),
        ],
      ),

      body: PdfPreview(
        build: (format) => _buildPdf(format),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        useActions: false,
      ),
    );
  }

}

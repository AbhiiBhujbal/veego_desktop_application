import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateTestReport(
    PdfPageFormat format,
    Map<String, dynamic> report,
    ) async {
  final pdf = pw.Document();

  final Map<String, dynamic> testReport =
  Map<String, dynamic>.from(report['test_report'] ?? {});
  final Map<String, dynamic> rootReport = report;

  final Map<String, dynamic> company =
  Map<String, dynamic>.from(rootReport['company'] ?? {});
  final Map<String, dynamic> instrument =
  Map<String, dynamic>.from(rootReport['instrument'] ?? {});
  final Map<String, dynamic> printInfo =
  Map<String, dynamic>.from(rootReport['print_info'] ?? {});

  final Map<String, dynamic> product =
  Map<String, dynamic>.from(testReport['product'] ?? {});
  final Map<String, dynamic> quantity =
  Map<String, dynamic>.from(product['quantity'] ?? {});
  final Map<String, dynamic> testParams =
  Map<String, dynamic>.from(testReport['test_parameters'] ?? {});

  final List<dynamic> vacuumData =
  (testReport['vacuum_readings'] ?? []) as List<dynamic>;

  print('VACUUM DATA = $vacuumData');
  final now = DateTime.now();

  final String printDate =
      printInfo['print_date'] ?? "${now.day}/${now.month}/${now.year}";

  final String printTime = printInfo['print_time'] ??
      "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";

  pdf.addPage(
    pw.Page(
      pageFormat: format,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        company['name'] ?? '',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(company['location'] ?? ''),
                      pw.Text("Contact: ${company['contact'] ?? ''}"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        instrument['name'] ?? '',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text("Model No: ${instrument['model_no'] ?? ''}"),
                      pw.Text("Serial No: ${instrument['serial_no'] ?? ''}"),
                      pw.Text(
                        "Instrument ID: ${instrument['instrument_id'] ?? ''}",
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Print Time: $printTime"),
                  pw.Text("Print Date: $printDate"),
                ],
              ),

              pw.SizedBox(height: 16),

              pw.Center(
                child: pw.Text(
                  rootReport['report_type'] ?? 'TEST REPORT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _infoRow("TEST REPORT NO",
                            testReport['report_no']?.toString() ?? ""),
                        _infoRow("TEST PERFORMED ON",
                            testReport['test_performed_on'] ?? ""),
                        _infoRow("PRODUCT NAME",
                            product['product_name'] ?? ""),
                        _infoRow("PRODUCT TYPE",
                            product['product_type'] ?? ""),
                        _infoRow(
                          "SET VACUUM",
                          "${testParams['set_vacuum_mmHg']?['value'] ?? ''} mmHg",
                        ),
                        _infoRow(
                          "HOLD TIME",
                          "${testParams['hold_time_sec'] ?? ""} Sec",
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _infoRow("SAMPLE ID", product['sample_id'] ?? ""),
                        _infoRow("BATCH NO", product['batch_no'] ?? "-"),
                        _infoRow("SHIPPER NO",
                            product['shipper_no'] ?? ""),
                        _infoRow(
                          "QUANTITY",
                          "${quantity['value'] ?? ""} ${quantity['unit'] ?? ""}",
                        ),
                        _infoRow(
                          "START DELAY",
                          "${testParams['start_delay_sec'] ?? ""} Sec",
                        ),
                        _infoRow(
                          "RETENTION TIME",
                          "${testParams['retention_time_sec'] ?? ""} Sec",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Vacuum Test Data",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Hold Time (sec)",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Actual Vacuum (mmHg)",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  ...vacuumData.map<pw.TableRow>((row) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(row['hold_time_sec']?.toString() ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(row['actual_vacuum_mmHg']?.toString() ?? ''),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Remark : ${testReport['remark'] ?? 'OK'}",
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          "Tested By : ${testReport['tested_by'] ?? 'Veego Engineer'}",
                        ),
                      ],
                    ),
                  ),

                  pw.Expanded(
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        "Checked By :___________ ${testReport['checked_by'] ?? ''}",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

pw.Widget _infoRow(String title, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            "$title :",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text(value),
        ),
      ],
    ),
  );
}

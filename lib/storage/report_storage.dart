// import 'package:hive/hive.dart';
//
// class ReportStorage {
//   static const String boxName = 'reportBox';
//   static const String key = 'reports';
//
//   static Future<void> saveReport(Map<String, dynamic> data) async {
//     final box = Hive.box(boxName);
//     final List stored = box.get(key, defaultValue: []);
//     List<Map<String, dynamic>> reports = stored
//         .map((e) => Map<String, dynamic>.from(e))
//         .toList();
//
//     reports.add(data);
//     await box.put(key, reports);
//     final box1 = Hive.box('reportBox');
//     print("Hive file path: ${box1.path}");
//
//     print("Report saved! Total reports: ${reports.length}");
//     print("Latest report: ${reports.last}");
//     print("Total reports: ${reports.length}");
//   }
//   static List<Map<String, dynamic>> loadReports() {
//     final box = Hive.box(boxName);
//     final List stored = box.get(key, defaultValue: []);
//     return stored
//         .map((e) => Map<String, dynamic>.from(e))
//         .toList();
//   }
// }

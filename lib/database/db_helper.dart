import 'dart:io';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Future<List<Map<String, dynamic>>> loadTable({
    required File dbFile,
    required String tableName,
  }) async {
    final db = await openDatabase(dbFile.path);
    return await db.query(tableName);
  }
}

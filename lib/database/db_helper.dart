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
  static Future<List<String>> getAllTableNames(File dbFile) async {
    final db = await openDatabase(dbFile.path);

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    return result
        .map((row) => row['name'] as String)
        .where(
          (name) =>
      !name.startsWith('sqlite_') &&
          name.toLowerCase() != 'android_metadata',
    )
        .toList();
  }

}

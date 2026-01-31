import 'dart:convert';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class FiltersLocalDb {
  static const _dbName = 'filters_cache.db';
  static const _table = 'filters';
  static const _version = 1;

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY,
            json TEXT NOT NULL
          );
        ''');
      },
    );
    return _db!;
  }

  Future<void> saveJson(Map<String, dynamic> data) async {
    final db = await _database;
    final jsonStr = jsonEncode(data);
    await db.insert(
      _table,
      {'id': 1, 'json': jsonStr},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> loadJson() async {
    final db = await _database;
    final rows = await db.query(_table, where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['json'] as String) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete(_table);
  }
}

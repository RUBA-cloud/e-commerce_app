import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FaviorateSql {
  static final FaviorateSql _instance = FaviorateSql._internal();
  factory FaviorateSql() => _instance;
  FaviorateSql._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            faviorate_id INTEGER,
            product_id INTEGER,
            product_data TEXT
          )
        ''');
      },
    );
  }

  Future<void> clearTable() async {
    final db = await database;
    await db.delete('favorites');
  }
}

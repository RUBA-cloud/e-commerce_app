import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartSql {
  static final CartSql _instance = CartSql._internal();
  factory CartSql() => _instance;
  CartSql._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'carts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE carts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            quantity INTEGER,
            size_data TEXT,
            additionals TEXT,
            cart_additional_product TEXT,
            color TEXT,
            product_data TEXT
          )
        ''');
      },
    );
  }

  Future<void> clearTable() async {
    final db = await database;
    await db.delete('carts');
  }
}

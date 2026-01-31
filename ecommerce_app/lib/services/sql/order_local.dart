// lib/services/sql/order_sql.dart

import 'dart:convert';

import 'package:ecommerce_app/models/order_model.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class OrderLocalDataSource {
  OrderLocalDataSource._();
  static final OrderLocalDataSource instance = OrderLocalDataSource._();

  static const String _dbName = 'orders.db';
  static const String _tableName = 'orders';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // تخزين الطلب كنص JSON واحد في كل صف (أسهل وأسرع الآن)
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            json TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  /// حفظ كل الطلبات في SQLite (نفرّغ الموجود ونخزّن الجديد)
  Future<void> saveOrders(List<OrderModel> orders) async {
    final db = await database;

    final batch = db.batch();
    batch.delete(_tableName);

    for (final o in orders) {
      batch.insert(
        _tableName,
        {
          'id': o.id,
          'json': jsonEncode(o.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// إرجاع كل الطلبات من SQLite
  Future<List<OrderModel>> getOrders() async {
    final db = await database;

    final rows = await db.query(_tableName, orderBy: 'id DESC');

    if (rows.isEmpty) return [];

    return rows.map<OrderModel>((row) {
      final jsonStr = row['json'] as String;
      final Map<String, dynamic> map =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      return OrderModel.fromJson(map);
    }).toList();
  }

  /// في حال احتجت لمسح كل الطلبات المخزنة محلياً
  Future<void> clear() async {
    final db = await database;
    await db.delete(_tableName);
  }
}


import 'dart:convert';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;


/// Local cache for categories (with products) using SQLite.
class CategoryLocalDataSource {
  CategoryLocalDataSource._();
  static final CategoryLocalDataSource instance =
      CategoryLocalDataSource._();

  static const _dbName = 'category_cache.db';
  static const _dbVersion = 1;
  static const _table = 'categories_cache';

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table(
            id    INTEGER PRIMARY KEY AUTOINCREMENT,
            json  TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  /// Save a list of categories (with nested products) to SQLite.
  /// We keep only ONE row and store JSON for the whole list.
  Future<void> saveCategories(List<CategoryModel> categories) async {
    final db = await _database;

    // remove old cache
    await db.delete(_table);

    final jsonList =
        categories.map((c) => c.toJson()).toList();

    await db.insert(
      _table,
      {
        'json': jsonEncode(jsonList),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load cached categories from SQLite.
  /// Returns empty list if nothing cached.
  Future<List<CategoryModel>> loadCategories() async {
    final db = await _database;
    final rows = await db.query(_table, limit: 1);

    if (rows.isEmpty) return [];

    final row = rows.first;
    final jsonStr = row['json'] as String?;
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final decoded = jsonDecode(jsonStr);

    if (decoded is List) {
      return decoded
          .map((e) =>
              CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Clear cache
  Future<void> clear() async {
    final db = await _database;
    await db.delete(_table);
  }
}

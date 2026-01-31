// lib/features/branches/data/company_branch_sql.dart
import 'dart:convert';
import 'package:ecommerce_app/models/branches.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
class CompanyBranchSql {
  CompanyBranchSql._();
  static final CompanyBranchSql instance = CompanyBranchSql._();

  static const _dbName = 'company_branch_cache.db';
  static const _dbVersion = 1;
  static const _table = 'company_branch_cache';

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

  /// Save a list of branches to SQLite.
  /// We keep only ONE row and store JSON for the whole list.
  Future<void> saveBranches(List<BranchModel> branches) async {
    final db = await _database;

    // remove old cache
    await db.delete(_table);

    final jsonList = branches.map((b) => b.toJson()).toList();

    await db.insert(
      _table,
      {
        'json': jsonEncode(jsonList),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load cached branches from SQLite.
  /// Returns empty list if nothing cached.
  Future<List<BranchModel>> loadBranches() async {
    final db = await _database;
    final rows = await db.query(_table, limit: 1);

    if (rows.isEmpty) return [];

    final row = rows.first;
    final jsonStr = row['json'] as String?;
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final decoded = jsonDecode(jsonStr);

    if (decoded is List) {
      return decoded
          .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
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

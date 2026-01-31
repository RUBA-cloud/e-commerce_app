import 'dart:convert';

import 'package:ecommerce_app/models/about_us.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class AboutLocalDataSource {
  AboutLocalDataSource._();
  static final AboutLocalDataSource instance = AboutLocalDataSource._();

  static const _dbName = 'app_cache.db';
  static const _dbVersion = 1;
  static const _table = 'about_us';

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
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company_name    TEXT,
            tagline         TEXT,
            mission_en      TEXT,
            mission_ar      TEXT,
            vision_en       TEXT,
            vision_ar       TEXT,
            description_en  TEXT,
            description_ar  TEXT,
            values_json     TEXT,
            email           TEXT,
            phone           TEXT,
            address         TEXT,
            website         TEXT,
            facebook        TEXT,
            instagram       TEXT,
            twitter         TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  /// Save model to SQLite (replace old row)
  Future<void> saveAbout(AboutUsInfoModel model) async {
    final db = await _database;

    // keep only one cached record
    await db.delete(_table);

    await db.insert(
      _table,
      {
        'company_name':    model.companyName,
        'tagline':         model.tagline,
        'mission_en':      model.missionEn,
        'mission_ar':      model.missionAr,
        'vision_en':       model.visionEn,
        'vision_ar':       model.visionAr,
        'description_en':  model.descriptionEn,
        'description_ar':  model.descriptionAr,
        'values_json':     jsonEncode(model.values),
        'email':           model.email,
        'phone':           model.phone,
        'address':         model.address,
        'website':         model.website,
        'facebook':        model.social['facebook'],
        'instagram':       model.social['instagram'],
        'twitter':         model.social['twitter'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load model from SQLite
  Future<AboutUsInfoModel?> loadAbout() async {
    final db = await _database;
    final rows = await db.query(_table, limit: 1);

    if (rows.isEmpty) return null;

    final row = rows.first;

    // Decode values_json safely
    List<String> values = [];
    final rawValues = row['values_json'] as String?;
    if (rawValues != null && rawValues.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawValues);
        if (decoded is List) {
          values = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // if parsing fails, we just keep values as empty list
      }
    }

    return AboutUsInfoModel(
      companyName:    row['company_name']?.toString() ?? '',
      tagline:        row['tagline']?.toString() ?? '',
      missionEn:      row['mission_en']?.toString() ?? '',
      missionAr:      row['mission_ar']?.toString() ?? '',
      visionEn:       row['vision_en']?.toString() ?? '',
      visionAr:       row['vision_ar']?.toString() ?? '',
      descriptionEn:  row['description_en']?.toString() ?? '',
      descriptionAr:  row['description_ar']?.toString() ?? '',
      email:          row['email']?.toString() ?? '',
      phone:          row['phone']?.toString() ?? '',
      address:        row['address']?.toString() ?? '',
      website:        row['website']?.toString() ?? '',
      social: {
        'facebook':  row['facebook']?.toString() ?? '',
        'instagram': row['instagram']?.toString() ?? '',
        'twitter':   row['twitter']?.toString() ?? '',
      },
      values: values,
    );
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete(_table);
  }
}



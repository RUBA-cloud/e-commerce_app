import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/post_services.dart';
import 'package:ecommerce_app/services/sql/flutter_sql_lite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluttertoast/fluttertoast.dart';

import '../models/filter_model.dart';

/// واجهة عامة للريبو
abstract class FiltersRepositoryBase {
  Future<FilterModel> getFilters();
  Future<void> saveFiltersSql(FilterModel model);
  Future<FilterModel> loadFilterSqlLite(FilterModel fallback);

  /// نرسل الفلاتر المختارة للسيرفر
  Future<CategoryModel?> sendFilter(
    int? categoryId,
    int? sizeId,
    int? typeId,
    String? color,
    double? minPrice,
    double? maxPrice,
  );
}

/// التنفيذ الفعلي باستخدام API + SQLite ككاش
class ApiFiltersRepository implements FiltersRepositoryBase {
  final FiltersLocalDb _db = FiltersLocalDb();

  @override
  Future<FilterModel> getFilters() async {
    final hasConnection = await checkConnectivity();

    // 🔹 لو ما في إنترنت، حاول تجيب من SQLite أولاً
    if (!hasConnection && !kIsWeb) {
      final cached = await _db.loadJson();
      if (cached != null) {
        return FilterModel.fromJson(cached);
      }
      // لا إنترنت ولا كاش → رجّع فلتر فاضي بدل الكراش
      return FilterModel.initial();
    }

    try {
      // ✅ نستخدم getJson بحيث يرجّع Map<String, dynamic>
      final resp = await GetService.I.getJson(
        filterApi,
        options: authOptions,
      );

      final bool ok = resp['status'] == true;
      final dynamic data = resp['data'];

      if (!ok || data == null || data is! Map<String, dynamic>) {
        Fluttertoast.showToast(msg: 'Invalid filters payload');
        throw Exception('Invalid filters payload');
      }

      // data شكلها تقريبا:
      // {
      //   "categories": [...],
      //   "types": [...],
      //   "sizes": [...],
      //   "category_id": 1,
      //   "min_price": 2,
      //   "max_price": 4,
      //   "colors": [...]
      // }
      final model = FilterModel.fromJson(data);

      // نحفظ كاش في SQLite (لو مو Web)
      if (!kIsWeb) {
        await saveFiltersSql(model);
      }

      return model;
    } catch (e, st) {
      // Debug + Toast
      // ignore: avoid_print
      print('getFilters error: $e\n$st');
      Fluttertoast.showToast(msg: e.toString());

      // 🔁 في حالة الخطأ، نحاول نقرأ من الكاش
      if (!kIsWeb) {
        final cached = await _db.loadJson();
        if (cached != null) {
          return FilterModel.fromJson(cached);
        }
      }

      // لو مافي حتى كاش، رجّع initial بدل rethrow عشان ما يكراش الاب
      return FilterModel.initial();
    }
  }

  @override
  Future<FilterModel> loadFilterSqlLite(FilterModel fallback) async {
    // fallback: قيمة افتراضية لو ما كان في كاش
    if (kIsWeb) return fallback;

    final cached = await _db.loadJson();
    if (cached != null) {
      return FilterModel.fromJson(cached);
    }
    return fallback;
  }

  @override
  Future<void> saveFiltersSql(FilterModel model) async {
    if (kIsWeb) return; // ما في SQLite على الويب
    // FiltersLocalDb يفترض أنه يخزن Map<String, dynamic> في SQLite
    await _db.saveJson(model.toJson());
  }

  @override
  Future<CategoryModel?> sendFilter(
    int? categoryId,
    int? sizeId,
    int? typeId,
    String? color,
    double? minPrice,
    double? maxPrice,
  ) async {
    // نرسل JSON بسيط بناءً على القيم المختارة (جاهزة كلها تكون null ما عندنا مشكلة)
    final Map<String, dynamic> payload = {
      'category_id': categoryId,
      'size_id': sizeId,
      'type_id': typeId,
      'color': color,
      'price_from': minPrice,
      'price_to': maxPrice,
    };

    final response = await PostServices.I.post(
      sendFilterApi,
      data: payload,
      options: authOptions,
    );

    final body = response.data;

    // نفترض شكل الريسبونس: { "status": true, "data": { ... } }
    if (response.statusCode == 200 && body is Map<String, dynamic>) {
      final ok = body['status'] == true;
      final data = body['data'];

      if (ok && data is Map<String, dynamic>) {
        // لو الـ API يرجّع قائمة كاتيجوريز
        if (data['categories'] is List &&
            (data['categories'] as List).isNotEmpty) {
          final firstCat =
              (data['categories'] as List).first as Map<String, dynamic>;
          return CategoryModel.fromJson(firstCat);
        }

        // أو لو يرجع كاتيجوري واحدة مباشرة كـ "category"
        if (data['category'] is Map<String, dynamic>) {
          return CategoryModel.fromJson(
              data['category'] as Map<String, dynamic>);
        }
      }
    }

    return null;
  }
}

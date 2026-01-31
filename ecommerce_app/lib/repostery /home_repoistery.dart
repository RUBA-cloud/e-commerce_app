import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/post_services.dart';
import 'package:ecommerce_app/services/sql/category_sql.dart';
import 'package:flutter/foundation.dart';

abstract class HomeRepository {
  Future<List<CategoryModel>> fetchAll();
  Future<List<CategoryModel?>> search(String? filter);
  Future<List<CategoryModel>> realTimeData();
  Future<void> saveDataSql(CategoryModel model);
  Future<CategoryModel?> loadDataSql();
  Future<CategoryModel?> loadSpecificCategoryProduct({required int categoryId,required int page});
}

class ApiHomeRepository implements HomeRepository {
  bool loadedForApi = false;
  final CategoryLocalDataSource _local = CategoryLocalDataSource.instance;

  // ===== API: Fetch All =====
  @override
  Future<List<CategoryModel>> 
  fetchAll() async {
    try {
      if (await checkConnectivity()) {
        final response = await GetService.I.getList(categoriesApi,query:{'per_page':10});
        // توقّع شكل الاستجابة: { "data": { "data": [ ... ] } }
        final rawList = response["data"]["data"];
        if (rawList is List && rawList.isNotEmpty) {
          loadedForApi = true;

          final categories = rawList
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
          await _local.saveCategories(categories);
          return categories;
        } else {
          // fallback to local cache
          return await _local.loadCategories();
        }
      } else {
        // لا يوجد اتصال → استخدم الكاش المحلي
        return await _local.loadCategories();
      }
    } catch (e) {
      debugPrint('❌ fetchAll() error: $e');
      return await _local.loadCategories();
    }
  }

  // ===== Local Cache (Single) =====
  @override
  Future<void> saveDataSql(CategoryModel model) async {
    // إذا أردت تخزين عنصر واحد فقط، نحفظه كقائمة من عنصر واحد
    await _local.saveCategories([model]);
  }

  @override
  Future<CategoryModel?> loadDataSql() async {
    final list = await _local.loadCategories();
    return list.isNotEmpty ? list.first : null;
  }

  // ===== Real-Time =====
  @override
  Future<List<CategoryModel>> realTimeData() async {
    try {
      // final result = await PusherService().category();
      // if (result.isNotEmpty) {
      //   await _local.saveCategories(result);
      //   return result;
      // }
    } catch (e) {
      debugPrint('⚠️ realTimeData() error: $e');
    }

    return await _local.loadCategories();
  }

  // ===== Load Specific Category =====
  @override
  Future<CategoryModel?> loadSpecificCategoryProduct({ required categoryId, required  int page}) async {
    try {
      // يفضّل استخدام route من api_routes بدل hard-code
      final response = await GetService.I
          .getJson('$categoryApi{$categoryId}+/{$page}');

      final category = CategoryModel.fromJson(response);
      await _local.saveCategories([category]);
      return category;
    } catch (e) {
      debugPrint('⚠️ loadSpecificCategoryProduct() error: $e');
    }

    final cachedList = await _local.loadCategories();
    try {
      return cachedList.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  // ===== Search (online + offline) =====
  @override
  Future<List<CategoryModel?>> search(String? filter) async {
    final query = (filter ?? '').trim();

    // لو الفلتر فاضي رجّع كل شيء حسب وضع الاتصال
    if (query.isEmpty) {
      return await fetchAll();
    }

    // لو في اتصال انترنت نحاول نبحث من API
    if (await checkConnectivity()) {
      try {
        final response = await PostServices.I.post(
          getCategorySearch,
          options: authOptions,
          data: { "search": query.toLowerCase()},
        );

        if (response.statusCode == 200) {
          final body = response.data;

          // توقّع شكل الاستجابة: { "data": [ ... ] } أو [ ... ]
          List<dynamic> rawList;
          if (body is Map && body['data'] is List) {
            rawList = body['data'] as List<dynamic>;
          } else if (body is List) {
            rawList = body;
          } else {
            rawList = const [];
          }

          final categories = rawList
              .map((item) =>
                  CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();

          // خزّن نتيجة البحث في الكاش (اختياري)
          await _local.saveCategories(categories);

          return categories;
        }
      } catch (e) {
        debugPrint('⚠️ search() API error: $e');
        // نكمل نبحث من الكاش بدل ما نرجع فاضي مباشرة
      }
    }

    // لو مافي اتصال أو صار خطأ في الـ API → نبحث من الكاش المحلي
    final localCategories = await _local.loadCategories();
    final lower = query.toLowerCase();

    return localCategories.where((cat) {
      // عدّل أسماء الحقول حسب موديلك الحقيقي
      final nameEn = cat.nameEn .toLowerCase();
      final nameAr = cat.nameAr .toLowerCase();

      return nameEn.contains(lower) || nameAr.contains(lower);
    }).toList();
  }
}

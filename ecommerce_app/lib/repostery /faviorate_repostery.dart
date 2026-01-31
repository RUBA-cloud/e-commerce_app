// ignore_for_file: unnecessary_type_check, use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/faviorate.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/post_services.dart';
import 'package:ecommerce_app/services/sql/faviorate_sql.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_cubit.dart';
import 'package:ecommerce_app/views/home/cubit /home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

abstract class FavoriteRepository {
  Future<List<FavoriteItem>> fetchAll();
  Future<void> saveAll(List<FavoriteItem> items);
  Future<List<FavoriteItem>> loadFromSql();
  Future<FavoriteItem?> addToFaviorate(int itemId, BuildContext context);

  /// لو fromHome = true → نستخدم productId مباشرة
  /// لو fromHome = false → نحاول إيجاد FavoriteItem أولاً بالـ productId
  Future<bool> removeFaviorate(
    int itemId,
    BuildContext context,
    bool fromHome,
    int productId,
  );

  Future<bool> removeAllFaviorate();
  Future<List<FavoriteItem>> search(String? filter);
}

class ApiFaviorateRepository implements FavoriteRepository {
  List<FavoriteItem> _store = [];

  Options get _authOptions {
    final token = UserModel.currentUser?.accessToken;
    return Options(
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );
  }

  /* ================== FETCH ALL ================== */

  @override
  Future<List<FavoriteItem>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final hasConnection = await checkConnectivity();

    if (!hasConnection) {
      // لا يوجد اتصال → نقرأ من SQLite
      return await loadFromSql();
    }

    try {
      final result =
          await GetService.I.getJson(faviorateList, options: _authOptions);

      dynamic rawData;

      if (result is Map<String, dynamic>) {
        rawData = result['data'] ?? result['favorites'] ?? result;
      } else {
        rawData = result;
      }

      final List<dynamic> list =
          rawData is List ? rawData : (rawData['favorites'] as List? ?? []);

      _store = list
          .map<FavoriteItem>(
            (item) => FavoriteItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      // نحفظ في SQLite
      await saveAll(_store);

      return List<FavoriteItem>.from(_store);
    } catch (e, st) {
      debugPrint('fetchAll favorites error: $e\n$st');
      try {
        return await loadFromSql();
      } catch (_) {
        return [];
      }
    }
  }

  /* ================== SAVE / LOAD (SQLite) ================== */

  @override
  Future<void> saveAll(List<FavoriteItem> items) async {
    final db = await FaviorateSql().database;

    // نحذف كل القديم قبل ما نضيف
    await db.delete('favorites');

    for (var fav in items) {
      await db.insert('favorites', {
        'faviorate_id': fav.id, // نخزّن id تبع favorite نفسه
        'product_id': fav.product.id,
        'product_data': jsonEncode(fav.product.toJson()),
      });
    }

    _store = List<FavoriteItem>.from(items);
  }

  @override
  Future<List<FavoriteItem>> loadFromSql() async {
    final db = await FaviorateSql().database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    return List.generate(maps.length, (i) {
      final productJson = jsonDecode(maps[i]['product_data'] as String);
      return FavoriteItem(
        id: maps[i]['faviorate_id'] as int? ??
            maps[i]['id'] as int? ??
            0, // دعم للحالتين
        product: ProductModel.fromJson(productJson),
      );
    });
  }

  /* ================== ADD TO FAVORITE ================== */

  @override
  Future<FavoriteItem?> addToFaviorate(
      int itemId, BuildContext context) async {
    final hasConnection = await checkConnectivity();

    if (!hasConnection) {
      return Future.error("no_internet_connection".tr);
    }

    try {
      final response = await PostServices.I.post(
        addFaviorateApi,
        options: _authOptions,
        data: {'product_id': itemId},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (body is Map &&
          (body['message'] == 'Product already added to favorites.' ||
              body['status'] == 'already_exists')) {
        return Future.error("product_is_already_in_favorites".tr);
      }

      if ((statusCode == 201 || statusCode == 200) &&
          body is Map &&
          body['data'] != null) {
        final favJson = body['data'] as Map<String, dynamic>;
        final fav = FavoriteItem.fromJson(favJson);

        // نحفظ في SQLite
        final db = await FaviorateSql().database;
        await db.insert('favorites', {
          'faviorate_id': fav.id,
          'product_id': fav.product.id,
          'product_data': jsonEncode(fav.product.toJson()),
        });

        // نحدّث الذاكرة المؤقتة
        _store.add(fav);

        // نحدّث Cubit (لو متوفر في الـ context)
          context.read<FavoriteCubit>().toggleFromHome(fav);

        return fav;
      }

      return Future.error('favorite_add_failed'.tr);
    } catch (e, st) {
      debugPrint('addToFaviorate error: $e\n$st');
      return Future.error(e.toString());
    }
  }

  /* ================== HELPERS: DELETE LOCAL ================== */

  Future<void> _deleteLocalByIdOrProduct(int id) async {
    final db = await FaviorateSql().database;

    // نحاول نحذف باعتبار أن id هو faviorate_id
    final deletedByFavId = await db.delete(
      'favorites',
      where: 'faviorate_id = ?',
      whereArgs: [id],
    );

    // لو ما انحذف شيء، نفترض أن id هو product_id
    if (deletedByFavId == 0) {
      await db.delete(
        'favorites',
        where: 'product_id = ?',
        whereArgs: [id],
      );
    }

    // تحديث الكاش في الذاكرة
    _store.removeWhere(
      (fav) => fav.id == id || fav.product.id == id,
    );
  }

  Future<void> _ensureStoreLoaded(bool hasConnection) async {
    if (_store.isNotEmpty) return;

    if (hasConnection) {
      _store = await fetchAll();
    } else {
      _store = await loadFromSql();
    }
  }

  FavoriteItem? _findFavoriteByProductId(int productId) {
    for (final fav in _store) {
      if (fav.product.id == productId) return fav;
    }
    return null;
  }

  /* ================== REMOVE ONE FAVORITE ================== */

  @override
  Future<bool> removeFaviorate(
    int itemId,
    BuildContext context,
    bool fromHome,
    int productId,
  ) async {
    final hasConnection = await checkConnectivity();

    try {
      // تأكد أن _store متعبّي (عشان نقدر نبحث عن FavoriteItem)
      await _ensureStoreLoaded(hasConnection);

      // نحدد الـ productId الحقيقي (لو وصل 0 نتجاهله)
      final int? effectiveProductId = productId > 0 ? productId : null;

      // نحدد favoriteId إن وجد (ولو 0 نعتبره null)
      int? favoriteId = itemId > 0 ? itemId : null;

      FavoriteItem? favForToggle;

      // ============ OFFLINE ============
      if (!hasConnection) {
        if (fromHome) {
          // من الهوم → نحذف بالـ productId
          if (effectiveProductId != null) {
            await _deleteLocalByIdOrProduct(effectiveProductId);
            try {
              context
                  .read<HomeCubit>()
                  .removeItemfromProductIds(effectiveProductId);
            } catch (_) {}
          }
        } else {
          // ليس من الهوم → نحاول أولاً إيجاد الفيفريت بالـ productId
          if (effectiveProductId != null) {
            favForToggle = _findFavoriteByProductId(effectiveProductId);
            favoriteId ??= favForToggle?.id;
          }

          final int? idToDelete =
              favoriteId ?? effectiveProductId; // آخر محاولة

          if (idToDelete != null) {
            await _deleteLocalByIdOrProduct(idToDelete);
          }
        }

        return true;
      }

      // ============ أونلاين ============

      // ----------- FROM HOME -----------
      if (fromHome && effectiveProductId != null) {
        final result = await GetService.I.getJson(
          '$removeFaviorateProductItemApi/$effectiveProductId',
          options: _authOptions,
        );

        if (result is Map<String, dynamic>) {
          final status = result['status'];
          final success = result['success'];
          if ((status is bool && !status) ||
              (success is bool && !success)) {
            Fluttertoast.showToast(msg: 'favorite_remove_failed'.tr);
            return false;
          }
        }

        // حذف محلي
        await _deleteLocalByIdOrProduct(effectiveProductId);

        // تحديث HomeCubit (إزالة productId من الـ set)
        try {
          context
              .read<HomeCubit>()
              .removeItemfromProductIds(effectiveProductId);
        } catch (_) {}

        // لو الـ API رجع data ممكن نستخدمها مع FavoriteCubit
        try {
          if (result is Map<String, dynamic> && result['data'] != null) {
            final fav =
                FavoriteItem.fromJson(result['data'] as Map<String, dynamic>);
            context.read<FavoriteCubit>().toggleFromHome(fav);
          }
        } catch (_) {}

        return true;
      }

      // ----------- NOT FROM HOME -----------
      // هنا نحتاج نبحث عن FavoriteItem لو ما عندنا favoriteId
      if (!fromHome) {
        // حاول إيجاد الفيفريت بالـ productId
        if (effectiveProductId != null) {
          favForToggle = _findFavoriteByProductId(effectiveProductId);
          favoriteId ??= favForToggle?.id;
        }

        // لو لم نجد وما زال favoriteId null، نستخدم productId كملاذ أخير
        final int? idToUse = favoriteId ?? effectiveProductId;

        if (idToUse == null) {
          // لا عندنا favoriteId ولا productId صالح → ما نقدر نحذف
          debugPrint(
              'removeFaviorate: cannot determine id to delete (itemId=$itemId, productId=$productId)');
          Fluttertoast.showToast(msg: 'favorite_remove_failed'.tr);
          return false;
        }

        final result = await GetService.I.getJson(
          '$removeFaviorateItemApi/$idToUse',
          options: _authOptions,
        );

        if (result is Map<String, dynamic>) {
          final status = result['status'];
          final success = result['success'];
          if ((status is bool && !status) ||
              (success is bool && !success)) {
            //Fluttertoast.showToast(msg: 'favorite_remove_failed'.tr);
            return false;
          }
        }

        // حذف من SQLite + الكاش
        await _deleteLocalByIdOrProduct(idToUse);

        // تحديث HomeCubit (حتى لو مو من الهوم، نخلي الأيقونة في الهوم تتحدّث)
        if (effectiveProductId != null) {
          try {
            context
                .read<HomeCubit>()
                .removeItemfromProductIds(effectiveProductId);
          } catch (_) {}
        }

        // تحديث FavoriteCubit لو عندنا FavoriteItem
        try {
          if (favForToggle != null) {
            context.read<FavoriteCubit>().toggleFromHome(favForToggle);
          }
        } catch (_) {}

        return true;
      }

      return true;
    } catch (e, st) {
      debugPrint('removeFaviorate error: $e\n$st');
      return false;
    }
  }

  /* ================== REMOVE ALL FAVORITES ================== */

  @override
  Future<bool> removeAllFaviorate() async {
    final hasConnection = await checkConnectivity();
    final db = await FaviorateSql().database;

    if (hasConnection) {
      try {
        final result = await GetService.I.getJson(
          clearAllFaviorate,
          options: authOptions,
        );

        if (result.isNotEmpty) {
          _store.clear();
          await db.delete('favorites');
          return true;
        }

        return false;
      } catch (e, st) {
        debugPrint('removeAllFaviorate error: $e\n$st');
        return false;
      }
    } else {
      await db.delete('favorites');
      _store.clear();
      return true;
    }
  }

  /* ================== SEARCH FAVORITES ================== */

  @override
  Future<List<FavoriteItem>> search(String? filter) async {
    final q = (filter ?? '').trim().toLowerCase();

    // لو الفلتر فاضي → رجّع الكل حسب الاتصال
    if (q.isEmpty) {
      return await fetchAll();
    }

    final hasConnection = await checkConnectivity();

    // ===== أونلاين =====
    if (hasConnection) {
      try {
        final result = await PostServices.I.post(
          getFaviorateSearch,
          data: {"search": q},
          options: _authOptions,
        );

        if (result.statusCode == 200) {
          final body = result.data;

          List<dynamic> rawList = [];

          if (body is Map<String, dynamic> && body['data'] is List) {
            rawList = body['data'] as List<dynamic>;
          } else if (body is List) {
            rawList = body;
          } else {
            throw Exception(
              'Unexpected favorites search response type: ${body.runtimeType}',
            );
          }

          return rawList
              .map<FavoriteItem>(
                (item) => FavoriteItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }

        // أي كود غير 200 → رجع من الكاش/SQLite
        return await fetchAll();
      } catch (e, st) {
        debugPrint('favorites search error: $e\n$st');
        return await fetchAll();
      }
    }

    // ===== أوفلاين: نفلتر من SQLite / الكاش =====
    final List<FavoriteItem> source =
        _store.isNotEmpty ? _store : await loadFromSql();

    return source.where((fav) {
      final product = fav.product;
      final nameEn = (product.nameEn).toLowerCase();
      final nameAr = (product.nameAr).toLowerCase();
      return nameEn.contains(q) || nameAr.contains(q);
    }).toList();
  }
}

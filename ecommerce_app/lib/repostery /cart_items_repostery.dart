import 'dart:convert';

import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/models/size_model.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/post_services.dart';
import 'package:ecommerce_app/services/sql/cart_sql.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

abstract class CartItemsRepostery {
  Future<List<CartModel>> fetchAll();
  Future<void> saveAll(List<CartModel> items);
  Future<List<CartModel>> loadFromSql();
  Future<CartModel?> addToCart(int itemId, int sizeId, String color,List<int>?additional);
  Future<bool> removeCartItem(int itemId);
  Future<bool> updateQuantity(int itemId, int quantity);
}

class InMemoryCartItemsRepository implements CartItemsRepostery {
  List<CartModel> _store = [];

  @override
  Future<List<CartModel>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // 🔌 Offline → من SQLite فقط
    if (await checkConnectivity() == false) {
      Fluttertoast.showToast(msg: 'no_internet_connection'.tr);
      final local = await loadFromSql();
      _store = local;
      return _store;
    }

    // 🌐 Online
    try {
      final result =
          await GetService.I.getList(cartList, options: authOptions);

      dynamic data;

      // يدعم شكلين:
      // 1) { "data": [ ... ] }
      // 2) [ ... ]
      if (result['data'] is List) {
        data = result['data'];
      } else if (result is List) {
        data = result;
      } else {
        data = [];
      }

      if (data is! List) return [];

      _store = data         
          .map<CartModel>((item) => CartModel.fromJson(item))
          .toList();

      await saveAll(_store);
      return _store;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      // Fallback → SQLite
     final local = await loadFromSql();
     _store = local;
      return _store;
    }
  }

  @override
  Future<void> saveAll(List<CartModel> items) async {
    final db = await CartSql().database;
    await db.delete('carts');

    for (final item in items) {
      // product في CartModel إجباري وغير nullable
      await db.insert('carts', {
        // نخلي الـ id هو id السرفر (cart row id)
        'id': item.id,
        'product_id': item.product!.id,
        'product_data': jsonEncode(item.product!.toJson()),
        'size_data': jsonEncode(item.sizeData.toMap()),
        'quantity': item.quantity,
        // ignore: deprecated_member_use
        'color': item.color,
      });
    }

    _store = List<CartModel>.from(items);
  }

  @override
  Future<List<CartModel>> loadFromSql() async {
    final db = await CartSql().database;
    final List<Map<String, dynamic>> maps = await db.query('carts');

    return maps.map<CartModel>((row) {
      // --- quantity آمن ---
      final rawQty = row['quantity'];
      int quantity;
      if (rawQty == null) {
        quantity = 1;
      } else if (rawQty is int) {
        quantity = rawQty;
      } else {
        quantity = int.tryParse(rawQty.toString()) ?? 1;
      }

      // --- product_data JSON → ProductModel (مطلوب) ---

      // --- size_data JSON → SizeModel ---
      SizeModel size;
      final rawSizeData = row['size_data'];
      if (rawSizeData is String && rawSizeData.isNotEmpty) {
        try {
          final sizeJson =
              jsonDecode(rawSizeData) as Map<String, dynamic>;
          size = SizeModel.fromMap(sizeJson);
        } catch (_) {
          size = const SizeModel(
            id: null,
            nameEn: '',
            nameAr: '',
            descriptionEn: '',
            descriptionAr: '',
            price: null,
          );
        }
      } else {
        size = const SizeModel(
          id: null,
          nameEn: '',
          nameAr: '',
          descriptionEn: '',
          descriptionAr: '',
          price: null,
        );
      }

      // --- color → Color ---
      Color? color ;
      final rawColor = row['color'];
      if (rawColor is int) {
        color = Color(rawColor);
      } else if (rawColor != null) {
        final parsedColor = int.tryParse(rawColor.toString());
        if (parsedColor != null) {
          color = Color(parsedColor);
        }
      }

      return CartModel(
        parsedColor: color,
        id: row['id'] as int?, // نخزن نفس id اللي استخدمناه في insert
        userId: null,
        productId: row['product_id'] as int?,
        quantity: quantity,
        sizeData: size,
        color: null, product: null,
      );
    }).toList();
  }

  @override
  Future<CartModel?> addToCart(int itemId, int sizeId, String color ,List<int>?additionalsId) async {
    if (await checkConnectivity() == false) {
      return Future.error("no_internet_connection".tr);
    }
      final List<int> list =additionalsId!.toList();
    try {

      final response = await PostServices.I.post(
        addCartApi,
        options: authOptions,
        data: {
          'product_id': itemId,
          'quantity': 1,
          'size_id': sizeId,
          'color': color,
         'additionals_id':additionalsId
        }
      );

      // مثال JSON:
      // {"status":"ok","message":"Product added to cart.","data":[{...}]}
      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = response.data;

        final dataList = body['data'];
        if (dataList is! List || dataList.isEmpty) {
          return Future.error('invalid_cart_response'.tr);
        }

        final first = dataList.last;
        if (first is! Map<String, dynamic>) {
          return Future.error('invalid_cart_response'.tr);
        }

        final cartItem = CartModel.fromJson(first);

        // 🗄️ حفظ في SQLite
        final db = await CartSql().database;
        await db.insert('carts', {
          'id': cartItem.id, // cart row id من السرفر
          'product_id': cartItem.product!.id,
          'product_data': jsonEncode(cartItem.product!.toJson()),
          'size_data': jsonEncode(cartItem.sizeData.toMap()),
          'quantity': cartItem.quantity,
          'color': color,
          'additionals':list,
        });

        // تحديث الـ store في الذاكرة
        _store.add(cartItem);

        return cartItem;
      }

      if (response.statusCode == 403) {
        final msg = response.data['message']?.toString() ?? '';
        if (msg.contains('already')) {
          return Future.error("product_is_already_in_cart".tr);
        }
        return Future.error(msg);
      }

      return Future.error('unexpected_error'.tr);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<bool> removeCartItem(int itemId) async {
    // itemId هنا هو cartItem.id

    if (await checkConnectivity() == false) {
      // نحذف من SQLite فقط
      final db = await CartSql().database;
      await db.delete('carts', where: 'id = ?', whereArgs: [itemId]);
      _store.removeWhere((e) => e.id == itemId);
      return true;
    }

    try {
      final result = await PostServices.I.post(
        removeCartApi,
        options: authOptions,
        data: {'id': itemId},
      );

      if (result.statusCode == 200) {
        final db = await CartSql().database;
        await db.delete('carts', where: 'id = ?', whereArgs: [itemId]);
        _store.removeWhere((e) => e.id == itemId);
        return true;
      }
    } catch (e) {
      rethrow;
    }

    return false;
  }

  @override
  Future<bool> updateQuantity(int itemId, int quantity) async {
    // itemId = cartItem.id

    try {
      final result = await PostServices.I.post(
        updateCartApi,
        options: authOptions,
        data: {'id': itemId, 'quantity': quantity},
      );

      if (result.statusCode == 200) {
        final db = await CartSql().database;
        await db.update(
          'carts',
          {'quantity': quantity},
          where: 'id = ?', // نفس id اللي خزنّاه
          whereArgs: [itemId],
        );

        // حدّث النسخة اللي في الذاكرة
        _store = _store
            .map((e) =>
                e.id == itemId ? e.copyWith(quantity: quantity) : e)
            .toList();

        return true;
      }

      if (result.statusCode == 422) {
        Fluttertoast.showToast(
          msg: result.data?['message']?.toString() ??
              result.statusCode.toString(),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    return false;
  }
}

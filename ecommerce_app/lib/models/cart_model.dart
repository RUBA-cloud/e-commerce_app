// lib/models/cart_model.dart
// ignore_for_file: deprecated_member_use

import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/models/additional_model.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/order_status_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/size_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/material.dart';

class CartModel {
  final int? id;
  final int? userId;
  final int? productId;
  final int? sizeId;

  int quantity;

  final SizeModel sizeData;
  final bool selected;
  final ProductModel? product;

  /// ✅ list of chosen additionals (from cart_additional[*].additioanls)
  final List<AdditionalModel> additional;

  /// Original color from API/JSON (string)
  final String? color;

  /// Parsed Flutter Color from [color]
  final Color? parsedColor;

  CartModel({
    this.id,
    this.userId,
    this.productId,
    this.sizeId,
    this.quantity = 1,
    required this.sizeData,
    required this.product,
    this.selected = true,
    required this.color,
    required this.parsedColor,
    this.additional = const [],
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // -------- color (string + parsed) --------
    final String? colorStr = json['color']?.toString();

    Color? parsedColor;
    if (colorStr != null && colorStr.isNotEmpty) {
      parsedColor = convertColorsFromStringToHex(colorStr);
    }

    // -------- size (from "size") --------
    final rawSize = json['size'];
    final SizeModel parsedSize = rawSize is Map<String, dynamic>
        ? SizeModel.fromMap(rawSize)
        : SizeModel(
            id: null,
            nameEn: '',
            nameAr: '',
            descriptionEn: '',
            descriptionAr: '',
            price: null,
          );

    // -------- product (nullable) --------
    final rawProduct = json['product'];
    final ProductModel? parsedProduct =
        rawProduct is Map<String, dynamic> ? ProductModel.fromJson(rawProduct) : null;

    // -------- quantity (safe parsing) --------
    final rawQty = json['quantity'];
    final int qty =
        rawQty is int ? rawQty : int.tryParse(rawQty?.toString() ?? '') ?? 1;

    // -------- additional list (from "cart_additional") --------
    final rawCartAdditional = json['cart_additional'];
    final List<AdditionalModel> additionals = [];

    if (rawCartAdditional is List) {
      for (final item in rawCartAdditional) {
        if (item is Map<String, dynamic>) {
          final rawAdditional = item['additioanls']; // backend key (typo)
          if (rawAdditional is Map<String, dynamic>) {
            additionals.add(AdditionalModel.fromJson(rawAdditional));
          }
        }
      }
    }

    return CartModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      productId: json['product_id'] as int?,
      sizeId: json['size_id'] as int?,
      quantity: qty,
      product: parsedProduct,
      sizeData: parsedSize,
      selected: false,
      color: colorStr,
      parsedColor: parsedColor,
      additional: additionals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (productId != null) 'product_id': productId,
      if (sizeId != null) 'size_id': sizeId,
      'quantity': quantity,
      'product': product?.toJson(),
      'size': sizeData.toMap(),
      'color': color,
      'selected': selected,
      // ⚠️ عادة لا نرسل additional objects، نرسل ids فقط عند الطلب
    };
  }

  /// ✅ ids only (useful when creating order)
  List<int> get additionalIds =>
      additional.map((e) => e.id).whereType<int>().toList();

  /// يحوّل قائمة كارت إلى OrderModel جاهز للإرسال للـ API
  static OrderModel fromCartListToOrder(
    List<CartModel> cartItems,
    String address,
    String buildingNumber,
    String streetName,
    double totalPrice,
    double lat,
    double long,
  ) {
    final userId = UserModel.currentUser?.id;
    if (userId == null) {
      throw StateError('UserModel.currentUser is null');
    }

    final now = DateTime.now();
    final List<OrderItemModel> orderItems = [];

    for (final cart in cartItems) {
      final double unit = cart.unitPrice;
      final double lineTotal = unit * cart.quantity;

      orderItems.add(
        OrderItemModel(
          id: 0,
          orderId: 0,
        
          productId: cart.productId ?? cart.product?.id ?? 0,
          color: cart.color ?? '',
          convertedColor: cart.parsedColor,
          quantity: cart.quantity,
          price: unit,
          size: cart.sizeData,
          totalPrice: lineTotal,
          createdAt: now,
          updatedAt: now,
          additionalModel: cart.additional,
          

          // ✅ if your OrderItemModel supports this field
          // If not, remove this line.
        ),
      );
    }

    return OrderModel(
      id: 0,
      userId: userId,
      employeeId: null,
      status: 0,
      totalPrice: totalPrice,
      buildingNumber: buildingNumber,
      streetName: streetName,
      lat: lat,
      long: long,
      address: address,
      items: orderItems,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
      cartId:cartItems.first.id  ,
      transpartation: null, productAdditional: [], orderStatusModel: OrderStatusModel(id: 1,nameAr: 'pending',nameEn: 'pending',color: Colors.yellow.toString(),iconData: Icons.circle.toString()),
    );
  }

  /// سعر الوحدة – يتعامل مع price سواء كان رقم أو String
  double get unitPrice {
    final p = product?.price;
    if (p == null) return 0.0;
    return double.tryParse(p.toString()) ?? 0.0;
  }

  /// المجموع = السعر * الكمية (كنص جاهز للعرض)
  String get lineTotal => (unitPrice * quantity).toStringAsFixed(2);

  CartModel copyWith({
    int? id,
    int? userId,
    int? productId,
    int? sizeId,
    int? quantity,
    bool? selected,
    ProductModel? product,
    SizeModel? sizeData,
    String? color,
    Color? parsedColor,
    List<AdditionalModel>? additional,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      sizeId: sizeId ?? this.sizeId,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      product: product ?? this.product,
      sizeData: sizeData ?? this.sizeData,
      color: color ?? this.color,
      parsedColor: parsedColor ?? this.parsedColor,
      additional: additional ?? this.additional,
    );
  }

  /// ✅ يدعم response[data] اللي ممكن تكون List أو Map
  static CartModel fromAddToCartResponse(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return CartModel.fromJson(data);
    }

    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        return CartModel.fromJson(first);
      }
    }

    throw const FormatException('No cart item found in response["data"].');
  }

  static List<CartModel> listFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CartModel.fromJson)
          .toList();
    }
    return [];
  }
}

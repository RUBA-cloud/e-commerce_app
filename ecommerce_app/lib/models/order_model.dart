import 'package:ecommerce_app/models/additional_model.dart';
import 'package:ecommerce_app/models/order_status_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/size_model.dart';
import 'package:ecommerce_app/models/transpartation_model.dart';

/// Top-level model for an order
class OrderModel {
  final int? id;
  final int?cartId;
  final int userId;
  final int? employeeId;
  final int status; // backend numeric (0,1,2,3,4,5)

  /// Human-readable (from API): "1 day ago"
  final String createdAt;
  final String updatedAt;

  final double totalPrice;
  final String buildingNumber;
  final String streetName;
  final double? lat;
  final double? long;
  final String address;

  /// from API key: "trnasparation"
  final TranspartationModel? transpartation;

  final List<OrderItemModel> items;

  final List<AdditionalModel> productAdditional;
  final OrderStatusModel? orderStatusModel;

  /// can be null
  final dynamic offer;

  /// can be null or map {id,name,email}
  final EmployeeModel? employee;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.totalPrice,
    required this.buildingNumber,
    required this.streetName,
    required this.orderStatusModel,
    required this.lat,
    required this.long,
    required this.address,
    required this.transpartation,
    required this.items,
    required this.productAdditional,
    required this.cartId,
    this.offer,
    this.employee,

  });

  /// Helper: convert backend status int → UI enum
  
  

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _parseDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final parsedStatus = _parseInt(json['status'], fallback: 0);

    return OrderModel(
      id: json['id'] as int?,
      userId: _parseInt(json['user_id']),
      employeeId: json['employee_id'] == null ? null : _parseInt(json['employee_id']),
      orderStatusModel: OrderStatusModel.fromJson(json['order_status'] as Map<String, dynamic>),
      status: parsedStatus,
      productAdditional: [],
      // ✅ in your JSON you want human fields
      createdAt: json['created_at_human']?.toString() ?? '',
      updatedAt: json['updated_at_human']?.toString() ?? '',

      totalPrice: _parseDouble(json['total_price']),
      buildingNumber: json['building_number']?.toString() ?? '',
      streetName: json['street_name']?.toString() ?? '',
      lat: json['lat'] == null ? null : _parseDouble(json['lat'], fallback: 0),
      long: json['long'] == null ? null : _parseDouble(json['long'], fallback: 0),
      address: json['address']?.toString() ?? '',

      // ✅ FIX: parse model only if not null
      transpartation: json['trnasparation'] != null
          ? TranspartationModel.fromJson(json['trnasparation'] as Map<String, dynamic>)
          : null,

      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
            offer: json['offer'],

      // ✅ employee object (may be null)
      employee: json['employee'] != null
          ? EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : null, cartId: -3,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'employee_id': employeeId,
        'status': status,
        'created_at_human': createdAt,
        'updated_at_human': updatedAt,
        'total_price': totalPrice.toStringAsFixed(2),
        'building_number': buildingNumber,
        'street_name': streetName,
        'lat': lat,
        'long': long,
        'address': address,
        'transpartation_id': transpartation?.id,
        'trnasparation': transpartation?.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'offer': offer,
        'employee': employee?.toJson(),
      };
}

/// Employee nested in order.employee
class EmployeeModel {
  final int id;
  final String name;
  final String email;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    return EmployeeModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

/// One element in order.items[]
class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final String? color;
  final Color? convertedColor;

  final int quantity;
  final double price;
  final double totalPrice;

  final DateTime createdAt;
  final DateTime updatedAt;

  final ProductModel? product;
  final SizeModel? size;
  final List<AdditionalModel>? additionalModel;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.color,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,

    this.product,
    this.size,
    this.convertedColor,
    this.additionalModel

  });

  ProductSummary toSummary() {
    return ProductSummary(
      id: productId,
      nameEn: product?.nameEn ?? '',
      nameAr: product?.nameAr ?? '',
      imageUrl: product?.mainImage,
      price: price,
      color: color,
    );
  }

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _parseDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['order_id']),
      productId: _parseInt(json['product_id']),
      color: json['color']?.toString(),
      quantity: _parseInt(json['quantity'], fallback: 1),
      price: _parseDouble(json['price']),
      totalPrice: _parseDouble(json['total_price']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      size: json['size'] != null
          ? SizeModel.fromMap(json['size'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'size_id': size?.id,
        'color': color,
        'quantity': quantity,
        'price': price.toStringAsFixed(2),
        'total_price': totalPrice.toStringAsFixed(2),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'product': product?.toJson(),
        'size': size?.toMap(),
      };
}

/// Product nested in order.items[].product

/// Your UI enum
enum OrderProgress {
  pending,
  accepted,
  cancelled,
  shipped,
  //rejected,
  //delivered,
  compelete,
  
  makingOrder,
}

/// Minimal summary type
class ProductSummary {
  final int id;
  final String nameEn;
  final String nameAr;
  final String? imageUrl;
  final double price;
  final String? color;

  const ProductSummary({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.price,
    this.color,
  });
}

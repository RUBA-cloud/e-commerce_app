// lib/views/orders/cubit/orders_state.dart
import 'package:flutter/foundation.dart';

// NEW: Additional item per product (e.g., "Gift wrap", "Extra cheese")
@immutable
class AdditionalItem {
  final String name;
  final String? value; // optional, e.g., "Large", "No sugar"
  final double? price; // optional

  const AdditionalItem({required this.name, this.value, this.price});
}

@immutable
class ProductSummary {
  final String id;
  final String name;
  final String? imageUrl;
  final double price;
  final int qty;

  // NEW:
  final String? size;
  final int? colorHex; // ARGB (e.g., 0xFF1D5D9B). Nullable.
  final List<AdditionalItem> additionals;

  const ProductSummary({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    this.imageUrl,
    this.size,
    this.colorHex,
    this.additionals = const [],
  });
}

enum OrderProgress { pending, processing, shipped, delivered, cancelled }

@immutable
class OrderModel {
  final String id;
  final DateTime createdAt;
  final List<ProductSummary> items;
  final OrderProgress progress;
  final double subtotal;
  final double shipping;
  final double total;
  final String? code;

  // NEW:
  final String userName; // customer name
  final String addressName; // shipping address label / name

  const OrderModel({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.progress,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.userName,
    required this.addressName,
    this.code,
  });

  // Handy count across quantities
  int get itemsCount => items.fold(0, (p, e) => p + e.qty);
}

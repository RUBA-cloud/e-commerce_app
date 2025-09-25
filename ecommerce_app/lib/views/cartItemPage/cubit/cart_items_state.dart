// lib/views/cart/cubit/cart_state.dart
import 'package:flutter/foundation.dart';

enum CartStatus { idle, loading, success, error }

@immutable
class CartLine {
  final String id;
  final String name;
  final String? variant; // e.g., "Red / M"
  final String? imageUrl;
  final double unitPrice;
  final int qty;
  final bool selected;

  const CartLine({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.qty,
    this.variant,
    this.imageUrl,
    this.selected = true,
  });

  CartLine copyWith({
    String? id,
    String? name,
    String? variant,
    String? imageUrl,
    double? unitPrice,
    int? qty,
    bool? selected,
  }) {
    return CartLine(
      id: id ?? this.id,
      name: name ?? this.name,
      variant: variant ?? this.variant,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      qty: qty ?? this.qty,
      selected: selected ?? this.selected,
    );
  }

  double get lineTotal => unitPrice * qty;
}

@immutable
class CartState {
  final List<CartLine> lines;
  final double subtotal;
  final double discount; // after coupon, etc.
  final double shipping;
  final double total;
  final bool allSelected;
  final CartStatus status;
  final String? error;

  const CartState({
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.allSelected,
    required this.status,
    this.error,
  });

  factory CartState.initial() => const CartState(
        lines: [],
        subtotal: 0,
        discount: 0,
        shipping: 0,
        total: 0,
        allSelected: false,
        status: CartStatus.idle,
        error: null,
      );

  CartState copyWith({
    List<CartLine>? lines,
    double? subtotal,
    double? discount,
    double? shipping,
    double? total,
    bool? allSelected,
    CartStatus? status,
    String? error,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      allSelected: allSelected ?? this.allSelected,
      status: status ?? this.status,
      error: error,
    );
  }
}

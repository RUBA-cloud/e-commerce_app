// lib/views/cart/cubit/cart_state.dart
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:flutter/foundation.dart';

enum CartStatus { idle, loading, loaded, success, error, newItemAdded, removeItem }

@immutable
class CartState {
  final List<CartModel> items;
  final double subtotal;
  final double discount; // after coupon, etc.
  final double shipping;
  final double total;
  final int? cartQuantity;

  final bool allSelected;
  final CartStatus status;
  final String? error;

  const CartState({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.allSelected,
    required this.status,
    this.error,
    this.cartQuantity,
  });

  factory CartState.initial() => const CartState(
        items: [],
        subtotal: 0,
        discount: 0,
        shipping: 0,
        total: 0,
        allSelected: false,
        status: CartStatus.idle,
        error: null,
      );

  CartState copyWith({
    List<CartModel>? items,
    double? subtotal,
    double? discount,
    double? shipping,
    double? total,
    bool? allSelected,
    CartStatus? status,
    String? error,
    int? cartQuantity,
  }) {
    return CartState(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      allSelected: allSelected ?? this.allSelected,
      status: status ?? this.status,
      error: error,
      cartQuantity: cartQuantity ?? this.cartQuantity,
    );
  }
}

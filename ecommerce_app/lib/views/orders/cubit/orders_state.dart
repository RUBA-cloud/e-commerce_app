// OrdersStatus + OrdersState stay the same as you already have
import 'package:ecommerce_app/models/additional_model.dart';
import 'package:flutter/material.dart';

enum OrderStatus { idle, loading, error }

@immutable
class OrdersState {
  final OrderStatus status;
  final List<OrderModel> orders;
  final String? error;

  const OrdersState({required this.status, required this.orders, this.error});

  factory OrdersState.initial() =>
      const OrdersState(status: OrderStatus.idle, orders: [], error: null);

  OrdersState copyWith(
      {OrderStatus? status, List<OrderModel>? orders, String? error}) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error,
    );
  }
}

import 'package:ecommerce_app/models/order_model.dart';

enum OrderStatus { initial, loading, success, error }

class OrdersState {
  final OrderStatus status;
  final List<OrderModel> orders;
  final String? error;
  final int filterIndex; // 0 = all

  const OrdersState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.error,
    this.filterIndex = 0,
  });

  OrdersState copyWith({
    OrderStatus? status,
    List<OrderModel>? orders,
    String? error,
    int? filterIndex,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error,
      filterIndex: filterIndex ?? this.filterIndex,
    );
  }
}

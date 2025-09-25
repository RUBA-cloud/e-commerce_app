// lib/views/orders/cubit/orders_cubit.dart
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/models/additional_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_state.dart';
import 'package:get/get.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: OrderStatus.loading, error: null));
    try {
      // TODO: Replace with repository call
      await Future.delayed(const Duration(milliseconds: 400));

      final demoOrders = <OrderModel>[
        OrderModel(
          id: 'o_1001',
          code: '#ORD-1001',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          progress: OrderProgress.processing,
          items: const [
            ProductSummary(
              id: 'p1',
              name: 'Classic Hoodie',
              price: 22.5,
              qty: 1,
              imageUrl: 'https://placehold.co/120x120?text=Hoodie',
            ),
            ProductSummary(
              id: 'p2',
              name: 'Sneakers',
              price: 45.9,
              qty: 2,
              imageUrl: 'https://placehold.co/120x120?text=Sneakers',
            ),
          ],
          subtotal: 22.5 + 45.9 * 2,
          shipping: 0,
          total: 22.5 + 45.9 * 2,
          userName: '',
          addressName: '',
        ),
        OrderModel(
          id: 'o_1002',
          code: '#ORD-1002',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          progress: OrderProgress.delivered,
          items: const [
            ProductSummary(
              id: 'p3',
              name: 'Denim Jacket',
              price: 39.0,
              qty: 1,
              imageUrl: 'https://placehold.co/120x120?text=Denim',
            ),
          ],
          subtotal: 39.0,
          shipping: 4.99,
          total: 43.99,
          userName: '',
          addressName: '',
        ),
      ];

      emit(state.copyWith(
          status: OrderStatus.idle, orders: demoOrders, error: null));
    } catch (e) {
      emit(state.copyWith(status: OrderStatus.error, error: e.toString()));
    }
  }

  Future<void> refresh() async {
    await load();
  }

  // Open product details
  void openProduct(ProductSummary p) {
    // Option A: direct page
    Get.toNamed(AppRoutes.details);

    // Option B (named route):
    // Get.toNamed('/product/${p.id}', arguments: {'id': p.id});
  }
}

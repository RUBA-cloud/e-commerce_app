import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/repostery%20/order_repoistery.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_cubit.dart';
import 'package:ecommerce_app/views/orders/cubit/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({OrderRepository? repo})
      : _repo = repo ?? ApiOrderRepository(),
        super(const OrdersState());

  final OrderRepository _repo;

  OrderModel? _lastOrder;
  OrderModel? get lastOrder => _lastOrder;

  Future<void> load({OrderModel? order}) async {
    _lastOrder = order;

    emit(
      state.copyWith(
        status: OrderStatus.loading,
        error: null,
      ),
    );

    try {
      List<OrderModel> orders;

      if (order != null) {
        orders = [order];
      } else {
        orders = await _repo.fetchAll();
      }

      emit(
        state.copyWith(
          status: OrderStatus.success,
          orders: orders,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OrderStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    await load(order: _lastOrder);
  }

  void changeFilter(int index) {
    emit(state.copyWith(filterIndex: index));
  }

  void openProduct(ProductSummary product) {}

  /// إرسال طلب جديد
  Future<void> sendOrder(OrderModel order,int cartId,BuildContext context) async {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      final bool ok = await _repo.sendOrder(order,cartId);

      if (ok) {
        Get.offAllNamed(AppRoutes.home);
        _lastOrder = order;
        // ignore: use_build_context_synchronously
        context.read<CartCubit>().state.items.clear();
        emit(
          state.copyWith(
            status: OrderStatus.success,
            orders: [order],
          ),
        );
      } 
    } catch (e) {
      emit(
        state.copyWith(
          status: OrderStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}

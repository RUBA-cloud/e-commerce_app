import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/request/make_order_request.dart';

import 'package:ecommerce_app/data/model/request/update_car_request.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/data/model/response/checkout/order_entity.dart';
import 'package:ecommerce_app/domain/usecases/cart/add_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/cart/delete_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/cart/get_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/cart/update_cart_item.dart';
import 'package:ecommerce_app/services/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/cart/make_order_use_case.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  final GetCartUseCase _getCart = getIt<GetCartUseCase>();
  final AddCartUseCase _addCart = getIt<AddCartUseCase>();
  final UpdateCartItemUseCase _updateCart = getIt<UpdateCartItemUseCase>();
  final DeleteCartUseCase _deleteCart = getIt<DeleteCartUseCase>();
  final MakeOrderUseCase _makeOrder = getIt<MakeOrderUseCase>();

  CartsEntity? _lastCart;
  static CartCubit get(BuildContext context) => BlocProvider.of(context);

  CartsEntity? get currentCart => _lastCart;

  int get itemCount =>
      _lastCart?.data?.fold<int>(0, (sum, item) => sum + (item?.quantity ?? 0)) ??
          0;

  double get subtotal {
    final items = _lastCart?.data ?? [];
    return items.fold<double>(0, (sum, item) {
      final price = double.tryParse(item?.product?.price ?? '0') ?? 0;
      final sizeExtra = (item?.size?.price ?? 0).toDouble();
      return sum + (price + sizeExtra) * (item?.quantity ?? 0);
    });
  }

  // ── Cart CRUD ─────────────────────────────────────────────────────────────

  Future<void> loadCart() async {
    emit(CartLoading());
    final result = await _getCart.execute();
    switch (result) {
      case Success<CartsEntity>(data: final cart):
        _lastCart = cart;
        emit(CartLoaded(cart));
      case Failure<CartsEntity>(error: final err):
        emit(CartFailed(err));
    }
  }

  Future<bool> addToCart(AddToCartRequest request) async {
    emit(CartActionLoading(_lastCart));
    final result = await _addCart.execute(request);
    switch (result) {
      case Success<CartsEntity>(data: final cart):
        _lastCart = cart;
        emit(CartLoaded(cart));
        return true;
      case Failure<CartsEntity>(error: final err):
        emit(CartFailed(err));
        return false;
    }
  }

  Future<void> updateQuantity(CartsDataEntity item, int quantity) async {
    emit(CartActionLoading(_lastCart));
    final result = await _updateCart.execute(
      UpdateCartRequest(
        id: item.id!,
        quantity: quantity,
        sizeId: item.sizeId!,
      ),
    );
    switch (result) {
      case Success<CartsEntity>(data: final cart):
        _lastCart = cart;
        emit(CartLoaded(cart));
      case Failure<CartsEntity>(error: final err):
        emit(CartFailed(err));
    }
  }

  Future<bool?> removeItem(int? cartItemId) async {
    if (cartItemId == null) return false;
    emit(CartActionLoading(_lastCart));
    final result = await _deleteCart.execute(cartItemId);
    if (result case Success<CartsEntity>(data: final cart)) {
      _lastCart = cart;
      emit(CartDeletedSuccess());
      // reload so the list reflects the new cart
      await loadCart();
      return true;
    } else if (result case Failure<CartsEntity>(error: final err)) {
      emit(CartDeletedFailed());
      return false;
    }
    return false;
  }

  // ── Checkout flow ─────────────────────────────────────────────────────────

  /// Step 1 — called when user taps "Checkout" in the cart summary dock.
  /// Navigates to the address screen, passing the current cart along.
  void goToCheckout() {
    if (_lastCart == null) return;
    emit(CartGoToAddressCheckout(_lastCart!));
  }

  /// Step 2 — called from the address screen after the user fills in their
  /// address and confirms. Navigates to the order summary screen.
  void confirmAddress({
    required String street,
    required String building,
    required String fullAddress,
    double? latitude,
    double? longitude,
  }) {
    if (_lastCart == null) return;
    emit(CartGoToOrderSummary(
      cart: _lastCart!,
      street: street,
      building: building,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
    ));
  }

  /// Step 3 — called from the order summary screen to place the order.
  Future<void> placeOrder(MakeOrderRequest request) async {
    emit(CartOrderLoading());
    final result = await _makeOrder.execute(request);
    switch (result) {
      case Success<OrderEntity>(data: final order):
      // Clear local cart after successful order
        _lastCart = null;
        emit(CartOrderSuccess(order.data.id));
      case Failure<OrderEntity>(error: final err):
        emit(CartOrderFailed(err));
    }
  }
}
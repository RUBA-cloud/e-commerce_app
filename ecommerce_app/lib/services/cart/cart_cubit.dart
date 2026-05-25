import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/request/update_car_request.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/domain/usecases/cart/add_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/cart/delete_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/cart/get_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/cart/update_cart_item.dart';
import 'package:ecommerce_app/services/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  final GetCartUseCase _getCart = getIt<GetCartUseCase>();
  final AddCartUseCase _addCart = getIt<AddCartUseCase>();
  final UpdateCartItemUseCase _updateCart = getIt<UpdateCartItemUseCase>();
  final DeleteCartUseCase _deleteCart = getIt<DeleteCartUseCase>();

  CartsEntity? _lastCart;
  static CartCubit get(BuildContext context) => BlocProvider.of(context);

  CartsEntity? get currentCart => _lastCart;

  // ✅ safe null access on data list and quantity
  int get itemCount =>
      _lastCart?.data?.fold<int>(0, (sum, item) => sum + (item?.quantity ?? 0)) ?? 0;

  double get subtotal {
    final items = _lastCart?.data ?? [];
    return items.fold<double>(0, (sum, item) {
      final price = double.tryParse(item?.product?.price ?? '0') ?? 0;
      final sizeExtra = (item?.size?.price ?? 0).toDouble();
      return sum + (price + sizeExtra) * (item?.quantity ?? 0);
    });
  }

  Future<void> loadCart() async {
    emit(CartLoading());
    final result = await _getCart.execute();
    switch (result) {
      case Success<CartsEntity>(data: final cart):
        _lastCart = cart;
        emit(CartLoaded(cart));
      case Failure<CartsEntity>(error: final err):
        print("Failed: $err");
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
    if (quantity < 1) return;
    emit(CartActionLoading(_lastCart));
    final result = await _updateCart.execute(
      UpdateCartRequest(
        id: item.id!,         // ✅ nullable int? — update your request model too
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

  Future<void> removeItem(int? cartItemId) async {
    // ✅ guard against null id
    if (cartItemId == null) return;
    emit(CartActionLoading(_lastCart));
    final result = await _deleteCart.execute(cartItemId);
    switch (result) {
      case Success<CartsEntity>(data: final cart):
        _lastCart = cart;
        emit(CartLoaded(cart));
      case Failure<CartsEntity>(error: final err):
        emit(CartFailed(err));
    }
  }
}
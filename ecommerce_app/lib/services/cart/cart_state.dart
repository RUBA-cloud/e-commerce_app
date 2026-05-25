import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  CartLoaded(this.cart);
  final CartsEntity cart;
}

class CartActionLoading extends CartState {
  CartActionLoading(this.cart);
  final CartsEntity? cart;
}

class CartFailed extends CartState {
  CartFailed(this.message);
  final String? message;
}

import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  CartLoaded(this.cart);
  final CartsEntity cart;
}

class CartDeletedSuccess extends CartState {}
class CartDeletedFailed extends CartState {}

class CartActionLoading extends CartState {
  CartActionLoading(this.cart);
  final CartsEntity? cart;
}

class CartFailed extends CartState {
  CartFailed(this.message);
  final String? message;
}

// ── Checkout flow states ──────────────────────────────────────────────────────

/// Step 1 — user tapped "Checkout"; navigate to address screen
class CartGoToAddressCheckout extends CartState {
  CartGoToAddressCheckout(this.cart);
  final CartsEntity cart;
}

/// Step 2 — address confirmed; show order summary screen
class CartGoToOrderSummary extends CartState {
  CartGoToOrderSummary({
    required this.cart,
    required this.street,
    required this.building,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });
  final CartsEntity cart;
  final String street;
  final String building;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
}

/// Step 3 — order is being placed
class CartOrderLoading extends CartState {}

/// Step 3 success — order placed
class CartOrderSuccess extends CartState {
  CartOrderSuccess(this.orderId);
  final int? orderId;
}

/// Step 3 failure — order failed
class CartOrderFailed extends CartState {
  CartOrderFailed(this.message);
  final String? message;
}
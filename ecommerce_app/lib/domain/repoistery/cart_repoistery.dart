import 'package:ecommerce_app/core/di/api_result.dart' show ApiResult;
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/request/make_order_request.dart';
import 'package:ecommerce_app/data/model/request/update_car_request.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart' show CartsEntity;
import 'package:ecommerce_app/data/model/response/checkout/order_entity.dart';

abstract class  CartRepoistery {
  Future<ApiResult<CartsEntity>> getCart();
  Future<ApiResult<CartsEntity>> addToCart({
    required AddToCartRequest request,
  });
  Future<ApiResult<CartsEntity>> updateCartItem({
    required UpdateCartRequest request,
  });
  Future<ApiResult<CartsEntity>> deleteCartItem({required int cartItemId});
  Future<ApiResult<OrderEntity>>makeOrder({required MakeOrderRequest makeOrderRequest});
}
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/make_order_request.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/data/model/response/checkout/order_entity.dart';
import 'package:ecommerce_app/domain/repoistery/cart_repoistery.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class MakeOrderUseCase {
  final  CartRepoistery   _cartRepo;

  const MakeOrderUseCase({required  CartRepoistery homeRepo})
      : _cartRepo = homeRepo;

  Future<ApiResult<OrderEntity>> execute(MakeOrderRequest make) =>
      _cartRepo.makeOrder(makeOrderRequest:make );
}

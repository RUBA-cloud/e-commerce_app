import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/domain/repoistery/cart_repoistery.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class DeleteCartUseCase {
  final  CartRepoistery   _cartRepo;

  const DeleteCartUseCase({required  CartRepoistery homeRepo})
      : _cartRepo = homeRepo;

  Future<ApiResult<CartsEntity>> execute(int cartItemId) =>
      _cartRepo.deleteCartItem(cartItemId: cartItemId);
}

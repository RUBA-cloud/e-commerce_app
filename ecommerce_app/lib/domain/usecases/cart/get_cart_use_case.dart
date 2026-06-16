import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/domain/repoistery/cart_repoistery.dart' show CartRepoistery;
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class GetCartUseCase {
  final  CartRepoistery  _homeRepo;

  const GetCartUseCase({required   CartRepoistery homeRepo}) : _homeRepo = homeRepo;

  Future<ApiResult<CartsEntity>> execute() => _homeRepo.getCart();
}

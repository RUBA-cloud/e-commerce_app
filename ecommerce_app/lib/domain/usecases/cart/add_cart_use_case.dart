import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class AddCartUseCase {
  final HomeRepoistory _homeRepo;

  const AddCartUseCase({
    required HomeRepoistory homeRepo,
  }) : _homeRepo = homeRepo;

  Future<ApiResult<CartsEntity>> execute(
      AddToCartRequest request,
      ) =>
      _homeRepo.addToCart(request: request);
}
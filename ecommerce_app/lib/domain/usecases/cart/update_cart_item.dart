import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/update_car_request.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class UpdateCartItemUseCase {
  final HomeRepoistory _homeRepo;

  const UpdateCartItemUseCase({
    required HomeRepoistory homeRepo,
  }) : _homeRepo = homeRepo;

  Future<ApiResult<CartsEntity>> execute(
     UpdateCartRequest request,
      ) =>
      _homeRepo.updateCartItem(request: request);
}
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';

import 'package:injectable/injectable.dart';

@singleton
class SelectedCategoryUseCase {
  final HomeRepoistory _homeRepo;

  SelectedCategoryUseCase(this._homeRepo);

  Future<ApiResult<SimilarProductEntityEntity>> execute(int id) =>
      _homeRepo.fetchSimilarProducts(id: id);
}
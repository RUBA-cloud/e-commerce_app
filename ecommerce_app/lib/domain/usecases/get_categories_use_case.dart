import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/category_entity.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class GetCategoryUseCase {
  final HomeRepoistory _homeRepo;

  GetCategoryUseCase(this._homeRepo);

  Future<ApiResult<CategoryEntity>> execute() =>
      _homeRepo.fetchCategories();
}
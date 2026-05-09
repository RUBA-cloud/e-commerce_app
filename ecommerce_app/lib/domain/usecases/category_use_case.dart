import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/categories_entity.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class CategoryUseCase {
  final HomeRepoistory _homeRepo;

  CategoryUseCase(this._homeRepo);

  Future<ApiResult<CategoriesEntity>> execute() =>
      _homeRepo.fetchCategories();
}
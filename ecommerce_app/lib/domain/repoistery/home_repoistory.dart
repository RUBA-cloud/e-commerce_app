import '../../core/di/api_result.dart';
import '../../data/model/response/categories_entity.dart';

abstract class  HomeRepoistory{
  Future<ApiResult<CategoriesEntity>>fetchCategories();
  Future<ApiResult<CategoriesEntity>>fetchSelectedCategory();
}
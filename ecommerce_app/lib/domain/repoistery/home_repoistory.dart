
import 'package:ecommerce_app/data/model/request/brand_request.dart';
import 'package:ecommerce_app/data/model/request/filter_request.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/filter_option_entity.dart';

import 'package:ecommerce_app/data/model/response/filter_result_entity.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';

import '../../core/di/api_result.dart';


abstract class  HomeRepoistory {
  Future<ApiResult<CategoriesEntity>> fetchCategories();

  Future<ApiResult<BrandEntity>> fetchBrands({required BrandRequest brand});

  Future<ApiResult<SimilarProductEntityEntity>> fetchSimilarProducts(
      {required int id });

  Future<ApiResult<FilterOptionEntity>> fetchFilterOptions();

  Future<ApiResult<FilterResultEntity>> submitFilter(FilterRequest filter);

}
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/request/brand_request.dart';
import 'package:ecommerce_app/data/model/request/update_car_request.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';

import '../../core/di/api_result.dart';


abstract class  HomeRepoistory{
  Future<ApiResult<CategoriesEntity>>fetchCategories();
  Future<ApiResult<BrandEntity>>fetchBrands({required BrandRequest brand});
  Future<ApiResult<SimilarProductEntityEntity>>fetchSimilarProducts({required int id });
  Future<ApiResult<CartsEntity>> getCart();
  Future<ApiResult<CartsEntity>> addToCart({
    required AddToCartRequest request,
  });
  Future<ApiResult<CartsEntity>> updateCartItem({
    required UpdateCartRequest request,
  });
  Future<ApiResult<CartsEntity>> deleteCartItem({required int cartItemId});
}
// lib/data/repositories/company_info_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/api_service/api_service.dart';
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/request/brand_request.dart';
import 'package:ecommerce_app/data/model/request/update_car_request.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';

import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

import '../../core/extenstion/dio_excepetion.dart';
import '../model/response/similar_product_entity_entity.dart';

@Injectable(as: HomeRepoistory)
class HomeRepositoryImpl implements HomeRepoistory {
  final ApiService _apiService;

  const HomeRepositoryImpl(this._apiService);


  @override
  Future<ApiResult<CategoriesEntity>> fetchCategories()async {
    try {
      final res = await _apiService.getCategories();
      return Success(data: res);
    } on DioException catch (e) {
      return Failure(
        error: DioExceptionExtension.parseDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }



  @override
  Future<ApiResult< SimilarProductEntityEntity>> fetchSimilarProducts({required int id}) async{
    try {
      final res = await _apiService.getSimilarProducts(id);
      return Success(data: res);
    } on DioException catch (e) {
      return Failure(
        error: DioExceptionExtension.parseDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<CartsEntity>> addToCart({required AddToCartRequest request})async {
    try {
      final res = await _apiService.addToCarts(request);
      return Success(data: res);
    } on DioException catch (e) {
      return Failure(
        error: DioExceptionExtension.parseDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<CartsEntity>> getCart() async{
      try {
        final res = await _apiService.getCart();
        return Success(data: res);
      } on DioException catch (e) {
        return Failure(
          error: DioExceptionExtension.parseDioError(e),
          statusCode: e.response?.statusCode,
        );
      } catch (e) {
        return Failure(error: e.toString());

    }
  }

  @override
  Future<ApiResult<CartsEntity>> updateCartItem({
    required UpdateCartRequest request,
  }) async {
    try {
      final res = await _apiService.updateCartQuantity(request);
      return Success(data: res);
    } on DioException catch (e) {
      return Failure(
        error: DioExceptionExtension.parseDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<CartsEntity>> deleteCartItem({required int cartItemId}) async {
    try {
      final res = await _apiService.deleteCartItem(cartItemId);
      return Success(data: res);
    } on DioException catch (e) {
      return Failure(
        error: DioExceptionExtension.parseDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<BrandEntity>> fetchBrands({required BrandRequest brand})async {
    try {
      final res = await _apiService.topBrands(brand);
      return Success(data: res);
    } on DioException catch (e) {
      return Failure(
        error: DioExceptionExtension.parseDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }
}
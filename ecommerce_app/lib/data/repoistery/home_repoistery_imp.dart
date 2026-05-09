// lib/data/repositories/company_info_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/api_service/api_service.dart';
import 'package:ecommerce_app/data/model/response/categories_entity.dart';
// FIX: was api_service.dart — must match the file where @lazySingleton is declared

import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/domain/repoistery/company_info_repoistirey.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

import '../../core/extenstion/dio_excepetion.dart';

@Injectable(as: HomeRepoistory)
class HomeRepositoryImpl implements HomeRepoistory {
  final ApiService _apiService;

  const HomeRepositoryImpl(this._apiService);


  @override
  Future<ApiResult<CategoriesEntity>> fetchCategories()async {
    try {
      final res = await _apiService.getCategory();
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
  Future<ApiResult<CategoriesEntity>> fetchSelectedCategory() {
    // TODO: implement fetchSelectedCategory
    throw UnimplementedError();
  }
}
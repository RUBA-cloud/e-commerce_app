// lib/data/repositories/company_info_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/api_service/api_service.dart';
// FIX: was api_service.dart — must match the file where @lazySingleton is declared

import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/domain/repoistery/company_info_repoistirey.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: CompanyInfoRepository)
class CompanyInfoRepositoryImpl implements CompanyInfoRepository {
  final ApiService _apiService;

  const CompanyInfoRepositoryImpl(this._apiService);

  @override
  Future<ApiResult<CompanyInfoEntity>> getCompanyInfo() async {
    try {
      final res = await _apiService.getCompanyInfo();
      return Success(data: res);
    } on DioException catch (e) {
      return Failure(
        error: _parseDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'server_error';
    }
    return switch (e.type) {
      DioExceptionType.connectionError   => 'no_internet_connection',
      DioExceptionType.connectionTimeout => 'connection_timeout',
      DioExceptionType.receiveTimeout    => 'receive_timeout',
      DioExceptionType.cancel            => 'request_cancelled',
      _                                  => e.message ?? 'unknown_error',
    };
  }
}
// lib/data/api_service/api_service.dart

import 'package:dio/dio.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/data/model/response/login_entity.dart';
import 'package:injectable/injectable.dart';  // ← must be imported
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';  // ← matches THIS filename api_service.dart

@lazySingleton   // ← line 1 of 2 that were missing
@RestApi()
abstract class ApiService {
  @factoryMethod  // ← line 2 of 2 that were missing
  factory ApiService(Dio dio) = _ApiService;

  @GET('/company-info')
  Future<CompanyInfoEntity> getCompanyInfo();

  @POST('/auth/login')
  Future<LoginEntity> login(@Body() LoginRequest request);

  @POST('/auth/refresh')
  Future<LoginEntity> refreshToken(
      @Query('refresh_token') String refreshToken,
      );
}
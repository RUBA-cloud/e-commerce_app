// lib/data/api_service/api_service.dart

import 'package:dio/dio.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/data/model/response/email_entity.dart';
import 'package:ecommerce_app/data/model/response/email_verified_entity.dart';
import 'package:ecommerce_app/data/model/response/login_entity.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';
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
  @POST('/auth/forgot-password')
  Future<EmailEntity> forgotPassword(@Body() EmailRequest request);
  @POST('/auth/')
  Future<EmailEntity> resendVerifyEmail(@Body() EmailRequest request);
  @POST('/auth/resend-forgot-password')
  Future<EmailEntity> resendForgotPasswordEmail(@Body() EmailRequest request);
  @POST('/auth/register')
  Future<RegisterEntity> register(@Body() RegisterRequest request);
  @POST('/auth/register')
  Future<EmailVerifiedEntity> checkEmailVerified(@Body() EmailRequest request);
  @POST('/auth/refresh')
  Future<LoginEntity> refreshToken(@Query('refresh_token') String refreshToken,);


  /// Categories
 @GET('/categories')
  Future<CategoriesEntity>getCategory();
}
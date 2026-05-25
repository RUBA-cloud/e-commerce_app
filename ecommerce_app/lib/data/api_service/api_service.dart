// lib/data/api_service/api_service.dart

import 'package:dio/dio.dart';
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/request/brand_request.dart';
import 'package:ecommerce_app/data/model/request/update_car_request.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/data/model/response/email_entity.dart';
import 'package:ecommerce_app/data/model/response/email_verified_entity.dart';

import 'package:ecommerce_app/data/model/response/login_user_entity.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';
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
  Future<LoginUserEntity> login(@Body() LoginRequest request);
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
  Future<LoginUserEntity> refreshToken(@Query('refresh_token') String refreshToken,);
  /// Categories
 @GET('/categories')
  Future<CategoriesEntity>getCategories();
  @GET('/similar_product/{id}')
  Future<SimilarProductEntityEntity> getSimilarProducts(@Path('id') int id);
  @POST('/brands')
  Future<BrandEntity>topBrands(@Body()BrandRequest request);

  @POST('/add-to-cart')
  Future<CartsEntity> addToCarts(@Body() AddToCartRequest request);

  @POST('/update-cart-quantity')
  Future<CartsEntity> updateCartQuantity(@Body() UpdateCartRequest request);

  @GET('/cart')
  Future<CartsEntity> getCart();

  @DELETE('/cart/{id}')
  Future<CartsEntity> deleteCartItem(@Path('id') int id);



}
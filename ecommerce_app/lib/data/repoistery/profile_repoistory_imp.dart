import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/api_service/api_service.dart';
import 'package:ecommerce_app/data/model/request/profile/change_password_request.dart';
import 'package:ecommerce_app/data/model/request/profile/update_profile_request.dart';
import 'package:ecommerce_app/data/model/request/update_payment_request.dart';
import 'package:ecommerce_app/data/model/response/carts/company_branch_entity.dart';
import 'package:ecommerce_app/data/model/response/profile/payment_entity.dart';
import 'package:ecommerce_app/data/model/response/profile/profile_entity.dart';
import 'package:ecommerce_app/data/model/response/user_payment_entity.dart';
import 'package:ecommerce_app/domain/repoistery/profile_repoistory.dart';
import 'package:injectable/injectable.dart';
import '../../core/extenstion/dio_excepetion.dart';

@LazySingleton(as: ProfileRepoistory) // ✅ was @Injectable — caused re-creation on every inject
class ProfileRepoistoryImp implements ProfileRepoistory {
  final ApiService _apiService;

  ProfileRepoistoryImp(this._apiService);

  @override
  Future<ApiResult<CompanyBranchEntity>> getCompanyBranch() async {
    try {
      final result = await _apiService.getCompanyBranch();
      return Success(data: result);
    } on DioException catch (e) {
      return Failure(
        error: e.error.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<PaymentEntity>> getPaymentsMethods() async {
    try {
      final result = await _apiService.getPaymentOptions();
      return Success(data: result);
    } on DioException catch (e) {
      return Failure(
        error: e.error.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<ProfileEntity>> updateProfile(
      UpdateProfileRequest updateProfile) async {
    try {
      final result = await _apiService.updateProfile(updateProfile);
      return Success(data: result);
    } on DioException catch (e) {
      return Failure(
        error: e.error.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<bool>> changePassword(ChangePasswordRequest update) async {
    try {
      final result = await _apiService.changePassword(update);
      return Success(data: result.response.statusCode == 200);
    } on DioException catch (e) {
      return Failure(
        error: e.error.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  @override
  Future<ApiResult<UserPaymentEntity>> getSelectedPaymentUserOption()async {
    try {
      final result = await _apiService.getSelectUserPaymentOption();
      return Success(data: result);
    } on DioException catch (e) {
      return Failure(
        error: e.error.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }


  @override
  Future<ApiResult<UserPaymentEntity>> submitPaymentSelectedOption(UpdatePaymentRequest updatePayment)async {
    try {
      final result = await _apiService.getSelectUserPaymentOption();
      return Success(data: result);
    } on DioException catch (e) {
      return Failure(
        error: e.error.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }}


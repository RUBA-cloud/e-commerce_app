import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/api_service/api_service.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/email_entity.dart';
import 'package:ecommerce_app/data/model/response/email_verified_entity.dart';
import 'package:ecommerce_app/data/model/response/login_user_entity.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';
import 'package:ecommerce_app/domain/repoistery/auth_repoistery.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRepoistery)
class AuthRepoisteryImpl implements AuthRepoistery {
  final ApiService _apiService;

  const AuthRepoisteryImpl({required ApiService apiService})
      : _apiService = apiService;

  // ── Login ──────────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<LoginUserEntity>> login(LoginRequest loginRequest) async {
    try {
      final entity = await _apiService.login(loginRequest);
      return Success(data: entity);
    } on DioException catch (e) {
      return Failure(
        error:      _encodeError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<RegisterEntity>> register(RegisterRequest request) async {
    try {
      final entity = await _apiService.register(request);
      return Success(data: entity, statusCode: 200);
    } on DioException catch (e) {
      // FIX: pass full JSON so Failure can parse errors map
      // e.g. {"status":"validation_error","errors":{"email":[...]}}
      // _parseDioError was only returning message string — hasFieldError()
      // in the cubit would always return false because _parsed was empty
      return Failure(
        error:      _encodeError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  // ── Forgot password ────────────────────────────────────────────────────────
  @override
  Future<ApiResult<EmailEntity>> forgetPassword(
      EmailRequest forgetRequest) async {
    try {
      final entity = await _apiService.forgotPassword(forgetRequest);
      return Success(data: entity, statusCode: 200);
    } on DioException catch (e) {
      return Failure(
        error:      _encodeError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  // ── Resend forgot password email ───────────────────────────────────────────
  @override
  Future<ApiResult<EmailEntity>> resendForgetEmail(
      EmailRequest forgetPassword) async {
    try {
      final entity = await _apiService.forgotPassword(forgetPassword);
      return Success(data: entity, statusCode: 200);
    } on DioException catch (e) {
      return Failure(
        error:      _encodeError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  // ── Resend verify email ────────────────────────────────────────────────────
  @override
  Future<ApiResult<EmailEntity>> resendVerifyEmail(
      EmailRequest request) async {
    try {
      final entity = await _apiService.resendVerifyEmail(request);
      return Success(data: entity, statusCode: 200);
    } on DioException catch (e) {
      return Failure(
        error:      _encodeError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  // FIX: renamed from _parseDioError — old version extracted only the message
  // string, losing the full errors map. Now returns the full JSON string so
  // Failure._tryDecode can parse errors, status, message — all cubit helpers
  // (hasFieldError, isValidation, message) depend on the full JSON being here.
  String _encodeError(DioException e) {
    final data = e.response?.data;

    // Server returned a JSON body — re-encode to string for Failure to parse
    if (data is Map<String, dynamic>) {
      try {
        return jsonEncode(data);
      } catch (_) {}
    }

    // Server returned plain string
    if (data is String && data.isNotEmpty) return data;

    // No response body — map Dio error type to a readable key
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'connection_timeout',
      DioExceptionType.receiveTimeout    => 'receive_timeout',
      DioExceptionType.sendTimeout       => 'send_timeout',
      DioExceptionType.connectionError   => 'no_internet_connection',
      DioExceptionType.cancel            => 'request_cancelled',
      _                                  => e.message ?? 'unknown_error',
    };
  }

  @override
  Future<ApiResult<EmailVerifiedEntity>> checkEmailVerified(EmailRequest request) async{
    try {
      final entity = await _apiService.checkEmailVerified(request);
      return Success(data: entity, statusCode: 200);
    } on DioException catch (e) {
      return Failure(
        error:      _encodeError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(error: e.toString());
    }
  }
  }

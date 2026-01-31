// lib/core/network/auth_services.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart' hide NoConnectionException;
import 'package:ecommerce_app/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

typedef Json = Map<String, dynamic>;

/// Simple, predictable result wrapper
class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResult({this.data, this.error, this.statusCode});

  bool get isOk => error == null;
}

class AuthServices {
  AuthServices._internal();
  static final AuthServices I = AuthServices._internal();

  final _postApi = PostServices.I;
  final _getApi = GetService.I;

  String? _deviceToken;

  // ---- shared context ----
  String get _lang => Get.locale?.languageCode ?? 'en';

  /// Call this once you have FCM token, etc.
  void setDeviceToken(String? token) => _deviceToken = token;

  // ---- auth headers (Accept + Bearer) ----
  Options get _authOptions {
    final token = UserModel.currentUser?.accessToken;
    return Options(
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  // =========================================================
  // ======================= JSON SENDER =====================
  // =========================================================
  Future<ApiResult<Map<String, dynamic>>> _sendJson(
    String endpoint, {
    required Json body,
    Options? options,
  }) async {
    final payload = <String, dynamic>{...body};

    try {
      final res = await _postApi.postJson<Map<String, dynamic>>(
        endpoint,
        json: payload,
        options: options,
      );
      return ApiResult(data: res.data, statusCode: res.statusCode);
    } on NoConnectionException catch (e) {
      return ApiResult(error: 'No internet Connection ${e.message}');
    } on DioException catch (e) {
      return ApiResult(
        error: _formatDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // =========================================================
  // =================== MULTIPART SENDER ====================
  // =========================================================
  Future<ApiResult<Map<String, dynamic>>> _sendMultipart(
    String endpoint, {
    required Map<String, dynamic> fields,
    required File file,
    String fileField = 'avatar',
    Options? options,
  }) async {
    try {
      // ✅ Ensure fields are only primitive values (no File inside)
      final safeFields = <String, dynamic>{};
      fields.forEach((k, v) {
        if (v == null) return;
        if (v is File) return;
        safeFields[k] = v;
      });

      final formData = FormData.fromMap({
        ...safeFields,
        fileField: await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : 'avatar.jpg',
        ),
      });

      final res = await _postApi.postMultipart<Map<String, dynamic>>(
        endpoint,
        formData: formData,
        options: options ?? _authOptions,
      );

      return ApiResult(data: res.data, statusCode: res.statusCode);
    } on NoConnectionException catch (e) {
      return ApiResult(error: 'No internet Connection ${e.message}');
    } on DioException catch (e) {
      return ApiResult(
        error: _formatDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // =========================================================
  // ===================== PUBLIC APIs =======================
  // =========================================================

  Future<ApiResult<Map<String, dynamic>>> refreshToken() {
    return _sendJson(refreshTokenApi, body: {}, options: _authOptions);
  }

  /// POST /auth/login (no bearer needed)
  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
    required String country,
        required String city,

  }) {
    return _sendJson(
      loginApi,
      body: {
        'email': email,
        'password': password,
        'device_token': _deviceToken,
        'country':country,
        'city':city.isEmpty?"Amman":city,
        'language': _lang,
      },
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }

  /// POST /auth/register (no bearer needed)
  Future<ApiResult<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? passwordConfirmation,
    String? phone,
  }) async {
    if (await checkConnectivity() == false) {
      return ApiResult(error: "no_internet_connection".tr);
    }

    return _sendJson(
      registerApi,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation ?? password,
        if (phone != null) 'phone': phone,
      },
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }

  /// POST /auth/forgot-password (no bearer needed)
  Future<ApiResult<Map<String, dynamic>>> forgetPassword({
    required String email,
  }) async {
    if (await checkConnectivity() == false) {
      return ApiResult(error: "no_internet_connection".tr);
    }

    return _sendJson(
      forgetPasswordApi,
      body: {'email': email},
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }

  /// General email sender
  Future<ApiResult<Map<String, dynamic>>> sendEmail({
    required String email,
    required String api,
  }) async {
    if (await checkConnectivity() == false) {
      return ApiResult(error: "no_internet_connection".tr);
    }

    return _sendJson(
      api,
      body: {'email': email},
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }

  /// POST /auth/change-password (protected)
  Future<ApiResult<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    String? newPasswordConfirmation,
  }) {
    return _sendJson(
      changetPasswrod,
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation ?? newPassword,
      },
      options: _authOptions,
    );
  }

  // =========================================================
  // ==================== PROFILE APIs =======================
  // =========================================================

  /// GET /user/profile (protected)
  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    if (await checkConnectivity() == false) {
      return ApiResult(error: "no_internet_connection".tr);
    }

    try {
      final res = await _getApi.getJson(
        profileApi,
        options: _authOptions,
      );
      return ApiResult(data: res, statusCode: 200);
    } on NoConnectionException catch (e) {
      return ApiResult(error: 'No internet Connection ${e.message}');
    } on DioException catch (e) {
      return ApiResult(
        error: _formatDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  /// POST /user/profile (update profile, protected)
  Future<ApiResult<Map<String, dynamic>>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? street,
    File? avatarFile,
    String avatarField = 'avatar', String? city, String? country, // must match Laravel request field
  }) {

    final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (street != null) 'street': street,
      if (country != null) 'country': country,
      if (city != null) 'city': city,




    };

    if (avatarFile != null) {
      final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (street != null) 'street': street,
         if (country != null) 'country': country,
      if (city != null) 'city': city,
    };
    debugPrint('Updating profile with avatar, fields: $fields');
      return _sendMultipart(
        profileApi,
        fields: fields,
        file: avatarFile,
        fileField: avatarField,
        options: _authOptions,
      );
    }

    return _sendJson(
      profileApi,
      body: fields,
      options: _authOptions,
    );
  }

  // ---------- helpers ----------
  String _formatDioError(DioException e) {
    final code = e.response?.statusCode;
    final serverMsg = (e.response?.data is Map)
        ? (e.response?.data['message'] ?? e.message)
        : e.message;
    return 'HTTP${code != null ? ' $code' : ''}: ${serverMsg ?? 'Request failed'}';
  }
}

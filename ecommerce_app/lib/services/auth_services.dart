// lib/core/network/auth_services.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/services/post_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' hide MultipartFile;

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
  AuthServices._internal() {
    _seedDeviceToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((t) => _deviceToken = t);
  }
  static final AuthServices I = AuthServices._internal();

  final _api = PostServices.I;
  String? _deviceToken;

  // ---- shared context ----
  String get _lang => Get.locale?.languageCode ?? 'en';

  Future<void> _seedDeviceToken() async {
    try {
      _deviceToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {/* ignore */}
  }

  // =========================================================
  // ===============  SINGLE CORE SENDER (JSON)  =============
  // =========================================================
  Future<ApiResult<Map<String, dynamic>>> _sendJson(
    String endpoint, {
    required Json body,
    Options? options,
  }) async {
    // auto-merge common fields–
    final payload = <String, dynamic>{
      ...body,
    };

    try {
      final res = await _api.postJson<Map<String, dynamic>>(endpoint,
          json: payload, options: options);
      return ApiResult(data: res.data, statusCode: res.statusCode);
    } on NoConnectionException catch (e) {
      return ApiResult(error: "No internet Connection ${e.message}");
    } on DioException catch (e) {
      return ApiResult(
        error: _formatDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // ============ (only when you must upload files) ============
  Future<ApiResult<Map<String, dynamic>>> _sendMultipart(
    String endpoint, {
    required Json fields,
    required File file,
    String fileField = 'avatar',
  }) async {
    final payload = <String, dynamic>{
      ...fields,
      fileField: await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    };

    try {
      final res = await _api.postMultipart<Map<String, dynamic>>(
        endpoint,
        fields: payload,
      );
      return ApiResult(data: res.data, statusCode: res.statusCode);
    } on NoConnectionException catch (e) {
      return ApiResult(error: e.toString());
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

  /// POST /auth/login
  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) {
    return _sendJson(loginApi, body: {
      'email': email,
      'password': password,
      'device_token': _deviceToken,
      'language': _lang,
    });
  }

  /// POST /auth/register
  Future<ApiResult<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? passwordConfirmation,
    String? phone,
  }) {
    return _sendJson(registerApi, body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation ?? password,
      if (phone != null) 'phone': phone,
    });
  }

  Future<ApiResult<Map<String, dynamic>>> forgetPassword({
    required String email,
  }) {
    return _sendJson(forgetPasswordApi, body: {
      'email': email,
    });
  }

  Future<ApiResult<Map<String, dynamic>>> sendEmail(
      {required String email, required String api}) {
    return _sendJson(api, body: {
      'email': email,
    });
  }

  /// POST /auth/change-password
  Future<ApiResult<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    String? newPasswordConfirmation,
  }) {
    return _sendJson(changetPasswrod, body: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation ?? newPassword,
    });
  }

  /// POST /auth/update-profile
  /// If [avatarFile] is provided, sends multipart; otherwise JSON.
  Future<ApiResult<Map<String, dynamic>>> updateProfile({
    String? name,
    String? phone,
    File? avatarFile,
    String avatarField = 'avatar',
  }) {
    if (avatarFile != null) {
      return _sendMultipart(
        profileApi,
        fields: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
        file: avatarFile,
        fileField: avatarField,
      );
    }
    return _sendJson(profileApi, body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
    });
  }

  // ---------- helpers ----------
  String _formatDioError(DioException e) {
    final code = e.response?.statusCode;
    final serverMsg = e.response?.data is Map
        ? (e.response?.data['message'] ?? e.message)
        : e.message;
    return 'HTTP${code != null ? ' $code' : ''}: ${serverMsg ?? 'Request failed'}';
  }
}

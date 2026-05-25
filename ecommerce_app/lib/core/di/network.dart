import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/constant/api_constants.dart';
import 'package:ecommerce_app/constant/shared_prefence_keys.dart';
import 'package:ecommerce_app/core/di/network_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends QueuedInterceptor {

  // ── onRequest — attach token + headers to every request ───────────
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    // FIX 1: Use a single consistent key everywhere
    final token = prefs.getString(SharedPrefKeys.accessToken);

    options.headers[HttpHeaders.acceptHeader]      = ApiConstants.acceptHeader;
    options.headers[HttpHeaders.contentTypeHeader] = ApiConstants.contentType;

    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] =
      '${ApiConstants.bearerPrefix}$token';
    }

    handler.next(options);
  }

  // ── onError — handle 401 → refresh → retry ────────────────────────
  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    final statusCode = err.response?.statusCode;
    final path       = err.requestOptions.uri.path;

    // Skip refresh for non-401s and for auth endpoints (avoid loops)
    if (statusCode != 401 ||
        path.contains(ApiConstants.refresh) ||
        path.contains(ApiConstants.login)) {
      handler.next(err);
      return;
    }

    final refreshed = await _tryRefresh();

    if (!refreshed) {
      // FIX 2: Clear stale tokens on permanent auth failure
      await _clearTokens();
      handler.next(err);
      return;
    }

    try {
      final prefs    = await SharedPreferences.getInstance();
      // FIX 1: Read with the same key used in onRequest and _tryRefresh
      final newToken = prefs.getString(SharedPrefKeys.accessToken);

      if (newToken == null || newToken.isEmpty) {
        handler.next(err);
        return;
      }

      // FIX 3: Clone options to avoid mutating the original request
      final opts = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          HttpHeaders.acceptHeader:        ApiConstants.acceptHeader,
          HttpHeaders.contentTypeHeader:   ApiConstants.contentType,
          HttpHeaders.authorizationHeader: '${ApiConstants.bearerPrefix}$newToken',
        },
      );

      // FIX 4: Use a fresh Dio to avoid re-triggering this interceptor
      final retryDio = Dio(BaseOptions(
        baseUrl:        ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout:    ApiConstants.sendTimeout,
      ));

      final response = await retryDio.fetch(opts);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  // ── _tryRefresh ───────────────────────────────────────────────────
  Future<bool> _tryRefresh() async {
    try {
      final prefs        = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(SharedPrefKeys.accessToken); // FIX 1

      if (refreshToken == null || refreshToken.isEmpty) return false;

      final refreshDio = Dio(BaseOptions(
        baseUrl:        ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout:    ApiConstants.sendTimeout,
        headers: {
          HttpHeaders.contentTypeHeader:   ApiConstants.contentType,
          HttpHeaders.acceptHeader:        ApiConstants.acceptHeader,
          HttpHeaders.authorizationHeader: '${ApiConstants.bearerPrefix}$refreshToken',
        },
      ));

      final res = await refreshDio.post(
        ApiConstants.refresh,
        queryParameters: {ApiConstants.refreshTokenKey: refreshToken},
      );

      final data = res.data is String
          ? jsonDecode(res.data as String) as Map<String, dynamic>
          : res.data as Map<String, dynamic>;

      // FIX 1: Save with the same keys used to read them
      await prefs.setString(SharedPrefKeys.accessToken,  data['access_token']  as String);
      await prefs.setString(SharedPrefKeys.refreshToken, data['refresh_token'] as String);

      return true;
    } catch (_) {
      return false;
    }
  }

  // ── _clearTokens — wipe tokens on unrecoverable auth failure ──────
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPrefKeys.accessToken);
    await prefs.remove(SharedPrefKeys.refreshToken);
  }
}
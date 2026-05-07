import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/constant/api_constants.dart';
import 'package:ecommerce_app/core/di/network_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends QueuedInterceptor {

  // ── onRequest — attach token to every request ──────────────────────
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.accessTokenKey);

    options.headers[HttpHeaders.acceptHeader]      = ApiConstants.acceptHeader;
    options.headers[HttpHeaders.contentTypeHeader] = ApiConstants.contentType;

    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] =
      '${ApiConstants.bearerPrefix}$token';
    }

    handler.next(options);
  }

  // ── onError — handle 401 → refresh → retry ─────────────────────────
  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    final statusCode = err.response?.statusCode;
    final path       = err.requestOptions.uri.path;

    // only handle 401; skip refresh/login endpoints to avoid loops
    if (statusCode != 401 ||
        path.contains(ApiConstants.refresh) ||
        path.contains(ApiConstants.login)) {
      handler.next(err);
      return;
    }

    final refreshed = await _tryRefresh();

    if (!refreshed) {
      handler.next(err);
      return;
    }

    // refresh succeeded → retry original request with new token
    try {
      final prefs    = await SharedPreferences.getInstance();
      final newToken = prefs.getString(ApiConstants.accessTokenKey);

      final opts = err.requestOptions;
      opts.headers[HttpHeaders.authorizationHeader] =
      '${ApiConstants.bearerPrefix}$newToken';

      final response = await NetworkClient.dio.fetch(opts);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  // ── _tryRefresh ────────────────────────────────────────────────────
  Future<bool> _tryRefresh() async {
    try {
      final prefs        = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(ApiConstants.refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) return false;

      // Separate Dio instance — must NOT go through TokenInterceptor again
      final refreshDio = Dio(
        BaseOptions(
          baseUrl:        ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          sendTimeout:    ApiConstants.sendTimeout,
          headers: {
            'Content-Type': ApiConstants.contentType,
            'Accept':        ApiConstants.acceptHeader,
          },
        ),
      );

      final res = await refreshDio.post(
        ApiConstants.refresh,
        queryParameters: {ApiConstants.refreshTokenKey: refreshToken},
      );

      final data = res.data is String
          ? jsonDecode(res.data as String) as Map<String, dynamic>
          : res.data as Map<String, dynamic>;

      await prefs.setString(
          ApiConstants.accessTokenKey,  data['access_token']  as String);
      await prefs.setString(
          ApiConstants.refreshTokenKey, data['refresh_token'] as String);

      return true;
    } catch (_) {
      return false;
    }
  }
}
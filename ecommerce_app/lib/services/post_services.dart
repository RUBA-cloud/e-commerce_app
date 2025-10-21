// lib/core/network/post_services.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce_app/constants/api_routes.dart'; // nsure this exists
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class NoConnectionException implements Exception {
  final String message;
  NoConnectionException([this.message = 'No internet connection']);
  @override
  String toString() => message;
}

class PostServices {
  PostServices._internal({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 20),
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Accept': 'application/json',
          if (defaultHeaders != null) ...defaultHeaders,
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          // Handle errors if desired
          handler.next(e);
        },
      ),
    );
  }

  static PostServices? _instance;
  static bool _initialized = false;
  late final Dio _dio;

  /// Optional token provider. Assign from outside if needed.
  static Future<String?> Function()? _tokenProvider;

  /// Call this once at app start (e.g., in main()).
  static void init({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
    Future<String?> Function()? tokenProvider,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 20),
  }) {
    if (_initialized && _instance != null) {
      return; // Avoid re-initialization
    }
    _instance = PostServices._internal(
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
    _tokenProvider = tokenProvider;
    _initialized = true;
  }

  /// Get the singleton instance. If not initialized, try to auto-init using apiBaseUrl.
  static PostServices get I {
    if (_instance == null) {
      init(baseUrl: basicRoute);
    } else {
      throw StateError(
        'PostServices not initialized. Call PostServices.init(baseUrl: ...) first.',
      );
    }
    return _instance!;
  }

  void _toast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  /// Returns true if device has any connection (wifi/cellular/ethernet/vpn).
  Future<bool> _hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return result == ConnectivityResult.mobile ||
        // ignore: unrelated_type_equality_checks
        result == ConnectivityResult.wifi ||
        // ignore: unrelated_type_equality_checks
        result == ConnectivityResult.ethernet ||
        // ignore: unrelated_type_equality_checks
        result == ConnectivityResult.vpn;
  }

  /// Safe POST with connectivity check + friendly toasts.
  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? noInternetConnection,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (await _hasConnection()) {
      throw NoConnectionException();
    }

    try {
      final response = await _dio.post<T>(
        path,
        queryParameters: query,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Request timed out';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${e.response?.statusCode ?? 'Unknown'}';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error';
          break;
        default:
          errorMessage = 'Unexpected error';
      }
      _toast(errorMessage);
      rethrow;
    } catch (e) {
      _toast('Unexpected error');
      rethrow;
    }
  }

  /// JSON body posts
  Future<Response<T>> postJson<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? json,
    Options? options,
  }) {
    final opt = (options ?? Options()).copyWith(
      contentType: Headers.jsonContentType,
    );
    return post<T>(path, query: query, data: json, options: opt);
  }

  /// x-www-form-urlencoded
  Future<Response<T>> postFormUrlEncoded<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? fields,
    Options? options,
  }) {
    final opt = (options ?? Options()).copyWith(
      contentType: Headers.formUrlEncodedContentType,
    );
    return post<T>(path, query: query, data: fields, options: opt);
  }

  /// multipart/form-data
  Future<Response<T>> postMultipart<T>(
    String path, {
    Map<String, dynamic>? query,
    required Map<String, dynamic> fields,
    Options? options,
  }) {
    final form = FormData.fromMap(fields);
    final opt = (options ?? Options()).copyWith(
      contentType: 'multipart/form-data',
    );
    return post<T>(path, query: query, data: form, options: opt);
  }
}

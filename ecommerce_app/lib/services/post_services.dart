// lib/core/network/post_services.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants/api_routes.dart'; // تأكدي فيه basicRoute & refreshToken
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

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
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
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
          // هنا لو حبيتي مستقبلاً تعملي auto-refresh للـ token لما يطلع 401
          // تقدري تستدعي refreshTokenRequest() ثم تعيدي الطلب
        //  handler.next(e);
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

  static PostServices get I {
    if (_instance == null) {
      // auto init بحد أدنى
      init(baseUrl: basicRoute);
    }
    return _instance!;
  }
  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    

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
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          refreshToken(path,data: data,query: query,cancelToken: cancelToken,onSendProgress: onSendProgress,onReceiveProgress: onReceiveProgress);

        case DioExceptionType.receiveTimeout:
           refreshToken(path,data: data,query: query,cancelToken: cancelToken,onSendProgress: onSendProgress,onReceiveProgress: onReceiveProgress);

          break;
          
        case DioExceptionType.badResponse:
        if(e.response!.statusCode==403) {
          Fluttertoast.showToast(msg: "already_added".tr);
        }
        else if(e.response!.statusCode==404){
                    Fluttertoast.showToast(msg: "does not exist");

        }
          else if(e.response!.statusCode==404){
                    Fluttertoast.showToast(msg: "does not exist");

        }
           else if(e.response!.statusCode==401){
          refreshToken(path,data: data,query: query,cancelToken: cancelToken,onSendProgress: onSendProgress,onReceiveProgress: onReceiveProgress);
          

        }
            
        break;
        
       case DioExceptionType.connectionError:
         Fluttertoast.showToast(msg: "check_your_connection");
          break;
        
        default:
      }
      rethrow;
    } catch (_) {
      rethrow;
    }}
      
  
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
  String url, {
  required FormData formData,
  Options? options,
}) {
  return _dio.post<T>(url, data: formData, options: options);
}


}

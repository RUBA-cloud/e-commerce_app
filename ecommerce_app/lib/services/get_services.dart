// lib/core/network/post_services.dart
import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NoConnectionException implements Exception {
  final String message;
  NoConnectionException([this.message = 'No internet connection']);
  @override
  String toString() => message;
}

class GetService {
  GetService._internal({
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

    // Optional logging (great for debugging)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = UserModel.currentUser!.accessToken!;
          if ( token.isNotEmpty) {
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

  static final GetService I = GetService._internal(baseUrl: basicRoute);

  late final Dio _dio;

  /// Set or clear the bearer token on the client.
  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Merge ad-hoc headers/options with existing ones.
  Options _mergeOptions(Options? base, Map<String, dynamic>? headers) {
    final merged = base ?? Options();
    final h = <String, dynamic>{
      if (merged.headers != null) ...merged.headers!,
      if (headers != null) ...headers,
    };
    return merged.copyWith(headers: h.isEmpty ? null : h);
  }


  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
    Map<String, dynamic>? headers,
    T Function(Object? json)? parser,
       Duration connectTimeout = const Duration(seconds: 10),
           CancelToken? cancelToken,
           ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,

    Duration receiveTimeout = const Duration(seconds: 20),
  }) async {
    final merged = _mergeOptions(options, headers);

    try {
      Response<Object?> response = await _dio.get<Object?>(
        endpoint,
        queryParameters: query,
        options: merged,
      );
      final body = response.data;

      if (parser != null) {
        return parser(body);
      }
      if(response.statusCode ==401){
            refreshToken(sendFilterApi,data: {},query: query,cancelToken: cancelToken,onSendProgress: onSendProgress,onReceiveProgress: onReceiveProgress);
      }
      
      return body as T;
      
    } on DioException catch (e) {
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
                          refreshToken(sendFilterApi,data: {},query: query,cancelToken: cancelToken,onSendProgress: onSendProgress,onReceiveProgress: onReceiveProgress);

        case DioExceptionType.receiveTimeout:
                  refreshToken(sendFilterApi,data: {},query: query,cancelToken: cancelToken,onSendProgress: onSendProgress,onReceiveProgress: onReceiveProgress);

        
          break;
        case DioExceptionType.connectionError:
                 Fluttertoast.showToast(msg: "check_your_connection");

          break;
        default:
      }
      rethrow;
    } 
    }
  

  // ---------- Convenience helpers (optional) ----------
  Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
    Map<String, dynamic>? headers,
  }) {
    return get<Map<String, dynamic>>(
      endpoint,
      query: query,
      options: options,
      headers: headers,
    );
  }

  Future<Map<String,dynamic>> getList(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
    Map<String, dynamic>? headers,
    
  }) {
    return get<Map<String,dynamic>>(
      endpoint,
      query: query,
      options: options,
      headers: headers,
    );
  }
}

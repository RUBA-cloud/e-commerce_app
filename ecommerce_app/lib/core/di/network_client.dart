import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/network.dart';


class NetworkClient {
  NetworkClient._();

  static const baseUrl = 'http://127.0.0.1:8000/api/';  // ← update this

  static final Dio dio = _buildDio();

  static Dio _buildDio() {
    final interceptor = TokenInterceptor();

    final dio = Dio(
      BaseOptions(
        baseUrl:                  baseUrl,
        connectTimeout:           const Duration(seconds: 60),
        receiveTimeout:           const Duration(seconds: 60),
        receiveDataWhenStatusError: true,
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      interceptor,
      LogInterceptor(
        request:       true,
        requestBody:   true,
        responseBody:  true,
        error:         true,
      ),
    ]);

    return dio;
  }
}
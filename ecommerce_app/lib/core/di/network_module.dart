// lib/core/di/network_module.dart

import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/network_client.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  // Reuses the already-configured Dio from NetworkClient
  // (which has TokenInterceptor + LogInterceptor already attached)
  @lazySingleton
  Dio get dio => NetworkClient.dio;
}
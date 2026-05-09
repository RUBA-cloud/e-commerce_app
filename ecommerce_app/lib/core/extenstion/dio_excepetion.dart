import 'package:dio/dio.dart';

class DioExceptionExtension  {
 static String parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'server_error';
    }
    return switch (e.type) {
      DioExceptionType.connectionError   => 'no_internet_connection',
      DioExceptionType.connectionTimeout => 'connection_timeout',
      DioExceptionType.receiveTimeout    => 'receive_timeout',
      DioExceptionType.cancel            => 'request_cancelled',
      _                                  => e.message ?? 'unknown_error',
    };
}}
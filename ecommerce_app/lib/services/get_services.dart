// lib/core/network/post_services.dart
import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants/api_routes.dart';

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

  Future<void> _ensureOnline() async {
    // final result = await Connectivity().checkConnectivity();
    // // ignore: unrelated_type_equality_checks
    // if (result == ConnectivityResult.none) {
    //   throw NoConnectionException();
    // }
  }

  // ---------- Generic GET that returns *data* ----------
  /// Makes a GET request and returns the parsed body as `T`.
  ///
  /// - If you pass `parser`, it will be used to convert the raw `response.data`
  ///   (e.g., Map/List) into your model type `T`.
  /// - If you don't pass `parser`, it will return `response.data as T`.
  ///
  /// Example:
  /// ```dart
  /// final user = await GetService.I.get<UserModel>(
  ///   '/user',
  ///   parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
    Map<String, dynamic>? headers,
    T Function(Object? json)? parser,
  }) async {
    await _ensureOnline();
    final merged = _mergeOptions(options, headers);

    final response = await _dio.get<Object?>(
      endpoint,
      queryParameters: query,
      options: merged,
    );

    final body = response.data;

    if (parser != null) {
      return parser(body);
    }

    // If no parser is provided, try to cast directly.
    // Common cases:
    //   - Map<String, dynamic> -> T
    //   - List<dynamic> -> T
    //   - primitive (String/int/bool/num) -> T
    return body as T;
  }

  // ---------- Convenience helpers (optional) ----------
  Future<Response<Map<String, dynamic>>> getJson(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
    Map<String, dynamic>? headers,
  }) {
    return get<Response<Map<String, dynamic>>>(
      endpoint,
      query: query,
      options: options,
      headers: headers,
    );
  }

  Future<List<dynamic>> getList(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
    Map<String, dynamic>? headers,
  }) {
    return get<List<dynamic>>(
      endpoint,
      query: query,
      options: options,
      headers: headers,
    );
  }
}

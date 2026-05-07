import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/api_service/api_service.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/response/login_entity.dart';
import 'package:ecommerce_app/domain/repoistery/auth_repoistery.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: AuthRepoistery)
class AuthRepoisteryImpl implements AuthRepoistery {
  final ApiService _apiService;

  // FIX: ApiService is a Retrofit abstract class — Retrofit generates
  // ApiServiceImpl at build time. Never call ApiService() directly;
  // receive it from your DI container (get_it) instead.
  const AuthRepoisteryImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<ApiResult<LoginEntity>> login(LoginRequest loginRequest) async {
    try {
      final entity = await _apiService.login(loginRequest);
      return Success(data: entity, statusCode: 200);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 403) {
        return Failure(
          error: _extractError(e.response?.data) ?? 'account_not_verified',
          statusCode: code,
        );
      }
      return Failure(error: _parseDioError(e), statusCode: code);
    } catch (e) {
      return Failure(error: e.toString());
    }
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  String? _extractError(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    return data['message']?.toString() ?? data['error']?.toString();
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'server_error';
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'connection_timeout',
      DioExceptionType.receiveTimeout    => 'receive_timeout',
      DioExceptionType.sendTimeout       => 'send_timeout',
      DioExceptionType.connectionError   => 'no_internet_connection',
      DioExceptionType.cancel            => 'request_cancelled',
      _                                  => e.message ?? 'unknown_error',
    };
  }
}


// ── get_it wiring (add this to your injection.dart) ──────────────────────────
//
// getIt.registerLazySingleton<AuthRepoistery>(
//   () => AuthRepoisteryImpl(apiService: getIt<ApiService>()),
// );
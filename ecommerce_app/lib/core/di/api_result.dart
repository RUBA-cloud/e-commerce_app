// lib/core/network/api_result.dart

sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T      data;
  final int?   statusCode;

  const Success({
    required this.data,
    this.statusCode,
  });
}

class Failure<T> extends ApiResult<T> {
  final String error;
  final int?   statusCode;

  const Failure({
    required this.error,
    this.statusCode,
  });
}
// lib/core/network/api_result.dart

import 'dart:convert';

sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T    data;
  final int? statusCode;

  const Success({
    required this.data,
    this.statusCode,
  });
}

class Failure<T> extends ApiResult<T> {
  final String               error;
  final int?                 statusCode;
  final Map<String, dynamic> _parsed;

  Failure({
     required this.error,
    this.statusCode,
  }) : _parsed = _tryDecode(error);

  // ── Helpers ───────────────────────────────────────────────

  /// Top-level status string e.g. "validation_error"
  String? get status => _parsed['status'] as String?;

  /// All field errors e.g. {"email": ["already taken"], "phone": [...]}
  Map<String, dynamic> get errors =>
      (_parsed['errors'] as Map<String, dynamic>?) ?? {};

  /// First error message for a specific field
  String? fieldError(String field) {
    final list = errors[field];
    if (list is List && list.isNotEmpty) return list.first as String?;
    return null;
  }

  /// True when the response is a 422 validation error
  bool get isValidation => statusCode == 422;

  /// True when a specific field has an error
  bool hasFieldError(String field) => errors.containsKey(field);

  /// Flat human-readable message — first error found or rawError fallback
  String get message {
    if (errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first as String;
    }
    return _parsed['message'] as String? ?? error;
  }

  static Map<String, dynamic> _tryDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }
}
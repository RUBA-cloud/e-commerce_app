class LoginState {
  final bool loading;
  final bool success;
  final String? error;

  const LoginState({this.loading = false, this.success = false, this.error});

  LoginState copyWith({bool? loading, bool? success, String? error}) {
    return LoginState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
    );

    // Note: `error` not null -> new error; pass `null` explicitly to clear
  }
}

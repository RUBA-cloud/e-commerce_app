class RegisterState {
  final bool loading;
  final bool success;
  final String? error;

  const RegisterState({this.loading = false, this.success = false, this.error});

  RegisterState copyWith({bool? loading, bool? success, String? error}) {
    return RegisterState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
    );
  }
}

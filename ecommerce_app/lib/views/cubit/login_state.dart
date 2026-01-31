class LoginState {
  final bool loading;
  final bool success;
 final bool? verifyEmail;
  final String? error;

  const LoginState( {this.loading = false,this.verifyEmail, this.success = false, this.error});

  LoginState copyWith({bool? loading, bool? success, String? error ,bool?verifyEmail}) {
    return LoginState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
     
     verifyEmail:verifyEmail??this.verifyEmail,
      error: error,
    );

    // Note: `error` not null -> new error; pass `null` explicitly to clear
  }
}

// lib/views/login/cubit/login_state.dart
abstract class LoginState {
  const LoginState();
}

/// Initial — nothing has happened yet
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// API call in progress
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Logged in successfully
class LoginSuccess extends LoginState {
  const LoginSuccess();
}

/// Account exists but email not verified
class LoginUnverified extends LoginState {
  const LoginUnverified();
}

/// Any failure — network, server, validation
class LoginFailed extends LoginState {
  final String message;
  const LoginFailed(this.message);
}
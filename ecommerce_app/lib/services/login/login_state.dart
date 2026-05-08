// lib/views/login/cubit/register_state.dart
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
class GoToRegister extends LoginState {
  const GoToRegister();
}
class GoToForgotPassword extends LoginState {
  const GoToForgotPassword();
}

class ForgetPasswordInitial extends LoginState{}
class ForgetPasswordLoading extends LoginState{}
class ForgetPasswordFail extends LoginState{
  String? message;
  ForgetPasswordFail(this.message);

}
class ForgetPasswordLoaded extends LoginState{}
class ForgetPasswordEmailFailedToSend extends LoginState{}
class ForgetPasswordEmailSuccessToSend  extends LoginState{}


/// Account exists but email not verified
class LoginUnverified extends LoginState {
  const LoginUnverified();
}

/// Any failure — network, server, validation
class LoginFailed extends LoginState {
  final String message;
  const LoginFailed(this.message);
}
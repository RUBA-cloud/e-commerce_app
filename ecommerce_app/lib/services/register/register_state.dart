part of 'register_cubit.dart';

abstract class RegisterState {
  const RegisterState();
}

/// Initial — nothing has happened yet.
class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

/// API call in progress.
class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

/// Registration succeeded.
class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

/// Account created but email not yet verified.
class RegisterUnverified extends RegisterState {
  const RegisterUnverified();
}

/// Any failure — network, server, validation.
class RegisterFailed extends RegisterState {
  const RegisterFailed(this.message);

  final String message;
}
class VerifyEmailInitial extends   RegisterState {
  const VerifyEmailInitial();
}
 
class VerifyEmailLoading extends   RegisterState {
  const VerifyEmailLoading();
}
 
class VerifyEmailSuccess extends   RegisterState {
  const VerifyEmailSuccess();
}
 
class VerifyEmailFailed extends   RegisterState {
  const VerifyEmailFailed(this.message);
  final String message;
}
 
class VerifyEmailResendLoading extends   RegisterState {
  const VerifyEmailResendLoading();
}
 
class VerifyEmailResendSuccess extends   RegisterState {
  const VerifyEmailResendSuccess();
}
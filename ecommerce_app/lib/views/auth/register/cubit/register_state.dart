import 'package:equatable/equatable.dart';

enum RegisterPhase {
  idle,
  loading,
  emailFound, // email already exists / found in system
  success,
  failure,
}

class RegisterState extends Equatable {
  final RegisterPhase phase;
  final String? email; // useful when `emailFound`
  final String? error; // useful when `failure`

  const RegisterState({
    this.phase = RegisterPhase.idle,
    this.email,
    this.error,
  });

  // Convenience getters (optional)
  bool get isLoading => phase == RegisterPhase.loading;
  bool get isEmailFound => phase == RegisterPhase.emailFound;
  bool get isSuccess => phase == RegisterPhase.success;
  bool get isFailure => phase == RegisterPhase.failure;

  RegisterState copyWith({
    RegisterPhase? phase,
    String? email,
    String? error, // pass null explicitly to clear
    bool clearEmail = false, // helper flags to clear fields when needed
    bool clearError = false,
  }) {
    return RegisterState(
      phase: phase ?? this.phase,
      email: clearEmail ? null : (email ?? this.email),
      error: clearError ? null : (error ?? this.error),
    );
  }

  // Nice, readable factories
  factory RegisterState.initial() => const RegisterState();

  factory RegisterState.loading() =>
      const RegisterState(phase: RegisterPhase.loading);

  factory RegisterState.emailFound(String email) =>
      RegisterState(phase: RegisterPhase.emailFound, email: email);

  factory RegisterState.success() =>
      const RegisterState(phase: RegisterPhase.success);

  factory RegisterState.failure(String message) =>
      RegisterState(phase: RegisterPhase.failure, error: message);

  @override
  List<Object?> get props => [phase, email, error];
}

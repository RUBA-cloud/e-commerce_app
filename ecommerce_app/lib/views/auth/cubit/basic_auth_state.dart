part of 'basic_auth_cubit.dart';

@immutable
sealed class BasicAuthState {}

final class BasicAuthInitial extends BasicAuthState {}

final class RegisterAuth extends BasicAuthState {}

final class LoginAuth extends BasicAuthState {}

// login_cubit.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/response/login_entity.dart';
import 'package:ecommerce_app/domain/usecases/forget_password_use_case.dart';
import 'package:ecommerce_app/domain/usecases/login_use_case.dart';
import 'package:ecommerce_app/services/login/login_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../constant/shared_prefence_keys.dart' show SharedPrefKeys;
import '../../domain/usecases/shared_prefs_string_use_case.dart' show SharedPrefsStringUseCase;

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginInitial());
  static LoginCubit get(BuildContext context) => BlocProvider.of(context);

  String country = 'Jordan';
  String city    = 'Amman';

  late final LoginUseCase          _loginUseCase          = getIt<LoginUseCase>();
  late final ForgetPasswordUseCase _forgetPasswordUseCase = getIt<ForgetPasswordUseCase>();
  late final SharedPrefsStringUseCase _sharedPrefsStringUseCase= getIt<SharedPrefsStringUseCase>();
  // ── Get country & city from GPS ──────────────────────────────────────
  Future<void> getCountryAndCity() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return;
      final place = placemarks.first;

      if ((place.country ?? '').isNotEmpty) country = place.country!;
      if ((place.locality ?? place.administrativeArea ?? '').isNotEmpty) {
        city = place.locality ?? place.administrativeArea ?? city;
      }
    } catch (_) {
      // Non-fatal — fallback values remain
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────
  Future<void> submit({required LoginRequest loginRequest}) async {
    if (state is LoginLoading) return;
    emit(LoginLoading());

    try {
      final result = await _loginUseCase.execute(loginRequest);

      switch (result) {
        case Success<LoginEntity>():
        await  fromLogin(result.data);


        case Failure():
          final code = result.statusCode;
          if (code == 403) {
            emit(LoginUnverified());
          } else {
            emit(LoginFailed(result.error ?? 'login_failed'.tr()));
          }
      }
    } catch (e) {
      emit(LoginFailed(e.toString()));
    }
  }
  Future<void> fromLogin(LoginEntity entity) async {
    await _sharedPrefsStringUseCase.execute(SharedPrefKeys.accessToken, entity.data.accessToken);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.userId,      entity.data.id.toString());
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.userEmail,   entity.data.email);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.userName,    entity.data.name);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.language,    entity.data.language);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.theme,       entity.data.theme);

    emit(LoginSuccess());
  }

  // ── Forgot Password ───────────────────────────────────────────────────
  // FIX: both forgetPassword and resendForgetPassword were identical —
  // extracted shared logic into _executeForgetPassword to avoid duplication.
  // Public methods only differ in intent (first send vs resend) but hit
  // the same endpoint, so they both delegate to the private method.

  Future<void> forgetPassword(EmailRequest request) =>
      _executeForgetPassword(request);

  Future<void> resendForgetPassword(EmailRequest request) =>
      _executeForgetPassword(request);

  Future<void> _executeForgetPassword(EmailRequest request) async {
    if (state is ForgetPasswordLoading) return;
    emit(ForgetPasswordLoading());

    try {
      final result = await _forgetPasswordUseCase.execute(request);

      switch (result) {
        case Success():
          emit(ForgetPasswordEmailSuccessToSend());

        case Failure():
          final code = result.statusCode;
          if (code == 404) {
            emit(ForgetPasswordEmailFailedToSend());
          } else {
            // FIX: result.error is nullable — added ?? fallback to avoid
            // passing null into ForgetPasswordFail which expects a String
            emit(ForgetPasswordFail(result.error ?? 'unknown_error'));
          }
      }
    } catch (e) {
      emit(ForgetPasswordFail(e.toString()));
    }
  }

  void goToRegister()       => emit(const GoToRegister());
  void goToForgotPassword() => emit(const GoToForgotPassword());
}
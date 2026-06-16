
import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/shared_prefence_keys.dart' show SharedPrefKeys;
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/email_verified_entity.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';
import 'package:ecommerce_app/domain/usecases/check_verify_email_use_case.dart';
import 'package:ecommerce_app/domain/usecases/register_use_case.dart';
import 'package:ecommerce_app/domain/usecases/resend_verify_email.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_string_use_case.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterInitial());

  static RegisterCubit get(BuildContext context) => BlocProvider.of(context);

  // ── Use-case (correctly initialised after super()) ────────
  final RegisterUseCase _registerUseCase = getIt<RegisterUseCase>();
  final ResendVerifyEmailUseCase _resendVerifyEmail = getIt<ResendVerifyEmailUseCase>();
  final CheckVerifyEmailUseCase _checkVerifyEmailUseCase =getIt<CheckVerifyEmailUseCase>();
  // ── Location fallbacks ────────────────────────────────────
  String country = 'Jordan';
  String city    = 'Amman';


  // ── Password visibility toggle ────────────────────────────
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    // re-emit current state to rebuild UI
    emit(state);
  }


  // ── GPS → country & city ──────────────────────────────────
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
      // Non-fatal — registration still works with fallback values
    }
  }
  void reset(){
    emit(RegisterInitial());
  }
  // ── Submit ────────────────────────────────────────────────
  Future<void> submit(RegisterRequest request) async {
    if (state is RegisterLoading) return;
    emit(const RegisterLoading());

    try {


      final result = await _registerUseCase.execute(request);

      switch (result) {
        case Success<RegisterEntity>():
          emit(const RegisterUnverified());


        case Failure():
          final code = result.statusCode;

          if (result.isValidation) {
            if (result.hasFieldError('email')) {
              emit(const EmailAlreadyExist());
            } else if (result.hasFieldError('phone')) {
              emit(const PhoneAlreadyExist());
            } else {
              emit(RegisterFailed(result.message));
            }
            return;
          }

          if (code == 403) {
            emit(const RegisterUnverified());
          } else {
            emit(RegisterFailed(result.message));
          }

      }
    } catch (e) {
      emit(RegisterFailed(e.toString()));
    }
  }
  // ── Resend OTP ────────────────────────────────────────────
  Future<void> resendEmailVerify({required String email}) async {
    if (state is VerifyEmailResendLoading) return;
    emit(const VerifyEmailResendLoading());
 
    try {
      final result = await _resendVerifyEmail.execute( EmailRequest(email: email));
 
      switch (result) {
        case Success():
          emit(const VerifyEmailResendSuccess());
        case Failure():
          emit(VerifyEmailFailed(
            result.error,
          ));
      }
    } catch (e) {
      emit(VerifyEmailFailed(e.toString()));
    }
  }

  void goToLogin() { emit(const BackToLogin());}

  // ── Validators (pure functions, no state emitted) ─────────────────────────

  String? validateName(String? v) {
    final val = (v ?? '').trim();
    if (val.isEmpty) return 'name_required'.tr();
    if (val.length < 2) return 'name_too_short'.tr();
    return null;
  }

  String? validateEmail(String? v) {
    final val = (v ?? '').trim();
    if (val.isEmpty) return 'email_required'.tr();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val)) {
      return 'enter_valid_email'.tr();
    }
    return null;
  }

  String? validatePhone(String? v) {
    final val = (v ?? '').trim();
    if (val.isEmpty) return 'phone_required'.tr();
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(val)) {
      return 'enter_valid_phone'.tr();
    }
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'password_is_required'.tr();
    if (v.length < 8) return 'password_too_short'.tr();
    return null;
  }

// confirmPassword needs the original password value to compare against
  String? validateConfirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'confirm_password_required'.tr();
    if (v != password) return 'passwords_do_not_match'.tr();
    return null;
  }

  String? validateCountry(String? v) {
    if ((v ?? '').trim().isEmpty) return 'country_required'.tr();
    return null;
  }

  String? validateCity(String? v) {
    if ((v ?? '').trim().isEmpty) return 'city_required'.tr();
    return null;
  }

  Future<void> checkEmailVerified({required String email}) async {
    if (state is RegisterLoading) return;
    emit(const RegisterLoading());

    try {
      final result = await _checkVerifyEmailUseCase.execute(EmailRequest(email: email));

      switch (result) {
        case Success():
          fromEmailVerified(result.data);
          emit( CheckEmailVerifiedSuccess(result.data));
        case Failure():
          if (result.statusCode == 403) {
            emit(const RegisterUnverified());
          } else {
            emit(RegisterFailed(result.message));
          }
      }
    } catch (e) {
      emit(RegisterFailed(e.toString()));
    }
  }
  late final SharedPrefsStringUseCase _sharedPrefsStringUseCase= getIt<SharedPrefsStringUseCase>();
  Future<void> fromEmailVerified(EmailVerifiedEntity entity) async {
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.accessToken, entity.accessToken);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.userId,      entity.user.id.toString());
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.userEmail,   entity.user.email);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.userName,    entity.user.name);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.language,    entity.user.language);
    await  _sharedPrefsStringUseCase.execute(SharedPrefKeys.theme,       entity.user.theme);
  }

}
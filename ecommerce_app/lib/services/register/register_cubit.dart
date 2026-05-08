import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';
import 'package:ecommerce_app/domain/usecases/register_use_case.dart';
import 'package:ecommerce_app/domain/usecases/resend_verify_email.dart';
import 'package:ecommerce_app/domain/usecases/resend_verify_use_case.dart';
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
  // ── Location fallbacks ────────────────────────────────────
  String country = 'Jordan';
  String city    = 'Amman';

  // ── Form controllers ──────────────────────────────────────
  final nameController     = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController    = TextEditingController();
  final formKey            = GlobalKey<FormState>();

  // ── Password visibility toggle ────────────────────────────
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    // re-emit current state to rebuild UI
    emit(state);
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    return super.close();
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

  // ── Submit ────────────────────────────────────────────────
  Future<void> submit() async {
    if (state is RegisterLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    emit(const RegisterLoading());

    try {
      final request = RegisterRequest(
        name:     nameController.text.trim(),
        email:    emailController.text.trim(),
        password: passwordController.text,
        phone:    phoneController.text.trim(),
        country:  country,
        city:     city,
      );

      final result = await _registerUseCase.execute(request);

      switch (result) {
        case Success<RegisterEntity>():
          emit(const RegisterSuccess());

        case Failure():
          final code = result.statusCode;
          if (code == 403) {
            emit(const RegisterUnverified());
          } else {
            emit(RegisterFailed(
              result.error ?? 'unknown_error'.tr(),
            ));
          }
      }
    } catch (e) {
      emit(RegisterFailed(e.toString()));
    }
  }

  // ── Verify OTP ────────────────────────────────────────────
  Future<void> verify({
    required String otp,
    required String email,
  }) async {
    if (state is VerifyEmailLoading) return;
    emit(const VerifyEmailLoading());
 
    // try {
    //   final result = await _verifyUseCase.execute(
    //     otp:   otp,
    //     email: email,
    //   );
 
    //   switch (result) {
    //     case Success():
    //       emit(const VerifyEmailSuccess());
    //     case Failure():
    //       emit(VerifyEmailFailed(
    //         result.error ?? 'unknown_error'.tr(),
    //       ));
    //   }
    // } catch (e) {
    //   emit(VerifyEmailFailed(e.toString()));
    // }
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
            result.error ?? 'unknown_error'.tr(),
          ));
      }
    } catch (e) {
      emit(VerifyEmailFailed(e.toString()));
    }
  }


}
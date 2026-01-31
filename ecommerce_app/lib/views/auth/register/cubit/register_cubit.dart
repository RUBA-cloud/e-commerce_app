// lib/views/auth/register/cubit/register_cubit.dart
import 'package:ecommerce_app/services/auth_services.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/views/auth/register/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState.initial());

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final renterPasswordCtrl = TextEditingController(); // confirm password
  final formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    // prevent double-tap while already sending
    if (state.isLoading) return;

    // validate form
    if (!(formKey.currentState?.validate() ?? false)) return;

    emit(RegisterState.loading());

    try {
      final name = nameCtrl.text.trim();
      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text; // keep exact value
      final confirm = renterPasswordCtrl.text; // confirm password
      final phone =
          phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim();
if( await checkConnectivity()){
      final res = await AuthServices.I.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirm,
        phone: phone,
      );

      // Success (commonly 201; accept 200 or 201)
      if (res.isOk == true &&
          (res.statusCode == 201 || res.statusCode == 200)) {
        emit(RegisterState.success());
        Fluttertoast.showToast(msg: " success");
        return;
      }
      // Handle known "email already exists" cases:
      if (_isEmailAlreadyTaken(res)) {
        emit(RegisterState.emailFound(email));
        Fluttertoast.showToast(msg: " email  Founs");

        return;}
      }
      // Generic failure
    } catch (e) {
      emit(RegisterState.failure(e.toString()));
    }
  }

  // Optional: call this to clear any error/emailFound and go back to idle
  void reset() => emit(RegisterState.initial());

  @override
  Future<void> close() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
    renterPasswordCtrl.dispose();
    return super.close();
    // Note: Do NOT dispose formKey
  }

  // ---- Helpers -------------------------------------------------------------

  bool _isEmailAlreadyTaken(dynamic res) {
    // Common API patterns:
    // - HTTP 409 Conflict
    // - HTTP 422 with validation error on "email"
    final code = res.statusCode as int?;
    if (code == 409) return true;

    // Fallback: check error text
    final err = (res.error ?? '').toString().toLowerCase();
    if (err.contains('email') &&
        (err.contains('taken') ||
            err.contains('exists') ||
            err.contains('already'))) {
      return true;
    }

    return false;
  }
}

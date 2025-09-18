import 'package:ecommerce_app/views/auth/register/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final renterPasswordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      nameCtrl.text.trim();
      emailCtrl.text.trim();
      passwordCtrl.text;
      phoneCtrl.text.trim();
      renterPasswordCtrl.text;
      await Future.delayed(const Duration(milliseconds: 500));
      // e.g., await authRepo.register(name, email, password);

      emit(state.copyWith(loading: false, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
    renterPasswordCtrl.dispose();

    return super.close();
  }
}

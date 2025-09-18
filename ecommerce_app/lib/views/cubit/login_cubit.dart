import 'package:ecommerce_app/views/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  // Controllers live in Cubit so the UI can be Stateless.
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      await Future.delayed(const Duration(milliseconds: 450));

      emit(state.copyWith(loading: false, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    return super.close();
  }
}

// lib/views/cubit/login_cubit.dart
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
import 'package:ecommerce_app/services/auth_services.dart';
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
    // prevent double-submit
    if (state.loading == true) return;

    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      emit(state.copyWith(loading: true, error: null, success: false));

      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text; // don't trim password

      final res = await AuthServices.I.login(email: email, password: password);

      // Accept 200 or 201 as success
      if (res.isOk && (res.statusCode == 200 || res.statusCode == 201)) {
        // Your AuthServices returns ApiResult<Map<String, dynamic>>
        // with user under res.data['data']
        final map = res.data ?? {};
        final user = (map['data'] as Map?)?.cast<String, dynamic>() ?? {};

        // persist lightweight profile (adjust keys if your API differs)
        await ProfileRepository().saveProfileData(
          id: int.tryParse(user['id']?.toString() ?? '') ?? 0,
          name: (user['name'] ?? '').toString(),
          email: (user['email'] ?? '').toString(),
          phone: user['phone']?.toString() ?? '',
          address: '', // fill if you have it
          street: '', // fill if you have it
        );

        emit(state.copyWith(loading: false, success: true));
        return;
      }

      // Not OK -> surface server error or fallback
      emit(state.copyWith(
        loading: false,
        success: false,
        error: res.error ?? 'Login failed',
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, success: false, error: e.toString()));
    }
  }

  // optional helper if you still need it
  void saveUser(Map<String, dynamic> result) {
    // result['data'] is typically the user map
    // print(result['data']);
  }

  @override
  Future<void> close() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    return super.close();
  }
}

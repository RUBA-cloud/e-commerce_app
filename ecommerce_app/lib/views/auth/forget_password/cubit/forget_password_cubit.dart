import 'package:ecommerce_app/views/auth/forget_password/cubit/forget_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(ForgetPasswordInitial());

  Future<void> sendResetEmail(String email) async {
    emit(ForgetPasswordLoading());
    await Future.delayed(const Duration(seconds: 2)); // Simulate network
    if (email.isEmpty) {
      emit(ForgetPasswordFailure('email_required'.tr));
    } else if (!email.contains('@')) {
      emit(ForgetPasswordFailure('invalid_email'.tr));
    } else {
      emit(ForgetPasswordSuccess());
    }
  }
}

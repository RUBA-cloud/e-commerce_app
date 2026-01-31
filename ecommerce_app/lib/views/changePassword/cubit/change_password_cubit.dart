import 'package:ecommerce_app/repostery%20/change_password_repoistery.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'change_password_state.dart';

class ChangePasswordCubit  extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(const ChangePasswordState());
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void changePassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      emit(state.copyWith(errorMessage: 'please_fill_all_fields'.tr));
      return;
    }

    if (newPassword != confirmPassword) {

      emit(state.copyWith(errorMessage: 'passwords_do_not_match'.tr));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
       var result= await ChangePasswordRepositoryImpl().changePassword(oldPassword, newPassword);
     if(result){
       emit(state.copyWith(isLoading: false, isSuccess: true));
       return;
     }else{
      await Future.delayed(const Duration(seconds: 2));

      // On success
      emit(state.copyWith(isLoading: false, isSuccess: true));
    }} catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'failed_to_change_password'.tr));
    }
  }
  @override
  Future<void> close() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }

}
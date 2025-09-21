import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'basic_auth_state.dart';

class BasicAuthCubit extends Cubit<BasicAuthState> {
  BasicAuthCubit() : super(BasicAuthInitial());

  void changeTab(int index) {
    if (index == 0) {
      emit(LoginAuth()); // ✅ emit an instance, not the class
    } else {
      emit(RegisterAuth());
    }
  }
}

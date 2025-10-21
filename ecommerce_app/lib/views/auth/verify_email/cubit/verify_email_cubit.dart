import 'dart:async';

import 'package:ecommerce_app/services/auth_services.dart';
import 'package:ecommerce_app/views/auth/verify_email/cubit/verify_email_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit({this.cooldownSeconds = 60})
      : super(const VerifyEmailState());

  final int cooldownSeconds;
  Timer? _timer;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> sendEmail(String apiRoute, String email) async {
    emit(VerifyEmailState().copyWith(sending: true));

    var result = await AuthServices.I.sendEmail(email: email, api: apiRoute);

    if (result.statusCode == 200) {
      emit(VerifyEmailState().copyWith(sent: true));
    }
  }

  Future<void> checkVerified() async {}
}

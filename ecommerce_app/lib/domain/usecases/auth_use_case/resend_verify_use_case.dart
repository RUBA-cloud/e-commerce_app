

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/response/email_entity.dart';


import 'package:ecommerce_app/domain/repoistery/auth_repoistery.dart' show AuthRepoistery;
import 'package:injectable/injectable.dart';
@singleton
class ResendForgetUseCase {
  final AuthRepoistery _authRepo;

  const ResendForgetUseCase({required AuthRepoistery authRepo})
      : _authRepo = authRepo;
  Future<ApiResult<EmailEntity>> execute(EmailRequest request) =>
      _authRepo.resendForgetEmail(request);
}

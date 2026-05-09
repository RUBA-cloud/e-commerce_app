import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/response/email_verified_entity.dart';
import 'package:ecommerce_app/domain/repoistery/auth_repoistery.dart';
import 'package:injectable/injectable.dart';

@singleton
class CheckVerifyEmailUseCase {
  final AuthRepoistery _authRepo;

  const CheckVerifyEmailUseCase({required AuthRepoistery authRepo})
      : _authRepo = authRepo;

  Future<ApiResult<EmailVerifiedEntity>> execute(EmailRequest request) => _authRepo.checkEmailVerified(request);
}
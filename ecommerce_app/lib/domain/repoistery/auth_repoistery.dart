import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/email_entity.dart';
import 'package:ecommerce_app/data/model/response/email_verified_entity.dart';
import 'package:ecommerce_app/data/model/response/login_user_entity.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';


abstract class AuthRepoistery {
   Future<ApiResult<LoginUserEntity>>login(LoginRequest loginRequest);
   Future<ApiResult<RegisterEntity>>register(RegisterRequest loginRequest);
   Future<ApiResult<EmailEntity>>forgetPassword(EmailRequest forgetPassword);
   Future<ApiResult<EmailEntity>>resendVerifyEmail(EmailRequest forgetPassword);
   Future<ApiResult<EmailEntity>>resendForgetEmail(EmailRequest forgetPassword);
   Future<ApiResult<EmailVerifiedEntity>>checkEmailVerified(EmailRequest request);
}
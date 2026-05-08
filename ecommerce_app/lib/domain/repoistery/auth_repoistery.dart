import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/email_entity.dart';
import 'package:ecommerce_app/data/model/response/login_entity.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';


abstract class AuthRepoistery {
   Future<ApiResult<LoginEntity>>login(LoginRequest loginRequest);
   Future<ApiResult<RegisterEntity>>register(RegisterRequest loginRequest);
   Future<ApiResult<EmailEntity>>forgetPassword(EmailRequest forgetPassword);
   Future<ApiResult<EmailEntity>>resendVerifyEmail(EmailRequest forgetPassword);
   Future<ApiResult<EmailEntity>>resendForgetEmail(EmailRequest forgetPassword);

}

class RequestState {
}
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/response/login_entity.dart';


abstract class AuthRepoistery {
   Future<ApiResult<LoginEntity>>login(LoginRequest loginRequest);

}

class RequestState {
}
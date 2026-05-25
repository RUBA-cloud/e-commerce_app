

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/response/login_user_entity.dart';


import 'package:ecommerce_app/domain/repoistery/auth_repoistery.dart' show AuthRepoistery;
import 'package:injectable/injectable.dart';
@singleton
class LoginUseCase {
  final AuthRepoistery _authRepo;

  const LoginUseCase({required AuthRepoistery authRepo})
      : _authRepo = authRepo;
  Future<ApiResult<LoginUserEntity>> execute(LoginRequest request) =>
      _authRepo.login(request);
}

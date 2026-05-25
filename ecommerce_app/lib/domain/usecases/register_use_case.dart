

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/data/model/response/register_entity.dart';

import 'package:ecommerce_app/domain/repoistery/auth_repoistery.dart' show AuthRepoistery;
import 'package:injectable/injectable.dart';
@singleton
class RegisterUseCase {
  final AuthRepoistery _authRepo;

  const RegisterUseCase({required AuthRepoistery authRepo})
      : _authRepo = authRepo;
  Future<ApiResult<RegisterEntity>> execute(RegisterRequest request) =>
      _authRepo.register(request );
}

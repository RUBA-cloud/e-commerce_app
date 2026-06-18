

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/request/profile/change_password_request.dart';
import 'package:ecommerce_app/data/model/response/login_user_entity.dart';


import 'package:ecommerce_app/domain/repoistery/auth_repoistery.dart' show AuthRepoistery;
import 'package:ecommerce_app/domain/repoistery/profile_repoistory.dart';
import 'package:injectable/injectable.dart';
@singleton
class ChangePasswordUseCase {
  final ProfileRepoistory _authRepo;

  const ChangePasswordUseCase({required ProfileRepoistory authRepo})
      : _authRepo = authRepo;
  Future<ApiResult<bool>> execute(ChangePasswordRequest request) =>
      _authRepo.changePassword(request);
}

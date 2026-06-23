import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/user_payment_entity.dart';
import 'package:ecommerce_app/domain/repoistery/profile_repoistory.dart';

import 'package:injectable/injectable.dart';

@singleton
class UserSelectedPaymentOption {
  final ProfileRepoistory _profileRepo;

  UserSelectedPaymentOption(this._profileRepo);

  Future<ApiResult<UserPaymentEntity>> execute() =>
      _profileRepo.getSelectedPaymentUserOption();
}
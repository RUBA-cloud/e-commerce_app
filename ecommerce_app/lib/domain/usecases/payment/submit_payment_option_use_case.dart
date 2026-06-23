

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/update_payment_request.dart';
import 'package:ecommerce_app/data/model/response/user_payment_entity.dart';
import 'package:ecommerce_app/domain/repoistery/profile_repoistory.dart';
import 'package:injectable/injectable.dart';
@singleton
class SubmitPaymentOptionUseCase {
  final ProfileRepoistory _profileRepo;

  const SubmitPaymentOptionUseCase ({required ProfileRepoistory profileRepo})
      : _profileRepo = profileRepo;
  Future<ApiResult<UserPaymentEntity>> execute(UpdatePaymentRequest updatePayment) => _profileRepo.submitPaymentSelectedOption(updatePayment);
}



import 'package:ecommerce_app/core/di/api_result.dart';

import 'package:ecommerce_app/data/model/response/profile/payment_entity.dart';
import 'package:ecommerce_app/domain/repoistery/profile_repoistory.dart';
import 'package:injectable/injectable.dart';
@singleton
class PaymentUseCase {
  final ProfileRepoistory _profileRepo;

  const PaymentUseCase ({required ProfileRepoistory authRepo})
      : _profileRepo = authRepo;
  Future<ApiResult<PaymentEntity>> execute() =>
      _profileRepo.getPaymentsMethods();
}

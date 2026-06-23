import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/profile/change_password_request.dart';
import 'package:ecommerce_app/data/model/request/profile/update_profile_request.dart';
import 'package:ecommerce_app/data/model/request/update_payment_request.dart';
import 'package:ecommerce_app/data/model/response/carts/company_branch_entity.dart';
import 'package:ecommerce_app/data/model/response/profile/payment_entity.dart';
import 'package:ecommerce_app/data/model/response/user_payment_entity.dart';

import '../../data/model/response/profile/profile_entity.dart';

abstract  class ProfileRepoistory {
  Future<ApiResult<CompanyBranchEntity>>getCompanyBranch();
  Future<ApiResult<ProfileEntity>>updateProfile(UpdateProfileRequest update);
  Future<ApiResult<bool>>changePassword(ChangePasswordRequest update);
  Future<ApiResult<PaymentEntity>>getPaymentsMethods();
  Future<ApiResult<UserPaymentEntity>>getSelectedPaymentUserOption();
  Future<ApiResult<UserPaymentEntity>>submitPaymentSelectedOption(UpdatePaymentRequest updatePayment);
}
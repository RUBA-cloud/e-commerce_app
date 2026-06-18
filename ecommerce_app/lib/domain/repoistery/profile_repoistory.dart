import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/profile/change_password_request.dart';
import 'package:ecommerce_app/data/model/request/profile/update_profile_request.dart';
import 'package:ecommerce_app/data/model/response/carts/company_branch_entity.dart';

import '../../data/model/response/profile/profile_entity.dart';

abstract  class ProfileRepoistory {
  Future<ApiResult<CompanyBranchEntity>>getCompanyBranch();
  Future<ApiResult<ProfileEntity>>updateProfile(UpdateProfileRequest update);
  Future<ApiResult<bool>>changePassword(ChangePasswordRequest update);
  Future<ApiResult<CompanyBranchEntity>>getPaymentsMethods();

}
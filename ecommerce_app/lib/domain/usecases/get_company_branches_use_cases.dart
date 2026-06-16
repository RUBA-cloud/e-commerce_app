import 'package:ecommerce_app/core/di/api_result.dart';

import 'package:ecommerce_app/domain/repoistery/profile_repoistory.dart';
import 'package:injectable/injectable.dart';

import '../../data/model/response/carts/company_branch_entity.dart';

@singleton
class GetCompanyBranchesUseCases {
  final ProfileRepoistory _homeRepo;

  GetCompanyBranchesUseCases (this._homeRepo);

  Future<ApiResult<CompanyBranchEntity>> execute() => _homeRepo.getCompanyBranch();
}
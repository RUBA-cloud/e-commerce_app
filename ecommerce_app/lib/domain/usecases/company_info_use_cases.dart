// lib/domain/usecases/get_company_info_use_case.dart

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/domain/repoistery/company_info_repoistirey.dart';
import 'package:injectable/injectable.dart';

@lazySingleton // ✅ was @singleton — must be @lazySingleton for use cases
class GetCompanyInfoUseCase {
  final CompanyInfoRepository _repository;
  const GetCompanyInfoUseCase(this._repository);
  Future<ApiResult<CompanyInfoEntity>> execute() => _repository.getCompanyInfo();
}
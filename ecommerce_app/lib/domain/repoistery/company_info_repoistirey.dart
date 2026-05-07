// lib/domain/repositories/company_info_repository.dart


import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';

abstract class CompanyInfoRepository {
  Future<ApiResult<CompanyInfoEntity>> getCompanyInfo();
}
// lib/domain/repoistery/company_info_repoistirey.dart

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';

abstract class CompanyInfoRepository {
Future<ApiResult<CompanyInfoEntity>> getCompanyInfo();
} // ✅ closed properly — impl must be in a SEPARATE file
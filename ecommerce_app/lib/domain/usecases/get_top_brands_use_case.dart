import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/brand_request.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class GetTopBrandsUseCase {
  final HomeRepoistory _homeRepo;

  GetTopBrandsUseCase(this._homeRepo);

  Future<ApiResult<BrandEntity>> execute( {required BrandRequest request})=>
      _homeRepo.fetchBrands(brand: request);
}
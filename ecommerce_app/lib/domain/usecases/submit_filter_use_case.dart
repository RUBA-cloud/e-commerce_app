import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/filter_request.dart';
import 'package:ecommerce_app/data/model/response/filter_result_entity.dart';
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class SubmitFilterUseCase {
  final HomeRepoistory _homeRepo;

  SubmitFilterUseCase(this._homeRepo);

  Future<ApiResult<FilterResultEntity>> execute(FilterRequest request) =>
      _homeRepo.submitFilter(request);
}
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/response/filter_option_entity.dart' show FilterOptionEntity;
import 'package:ecommerce_app/domain/repoistery/home_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class GetFilterOptionsUseCse {
  final HomeRepoistory _homeRepo;

  GetFilterOptionsUseCse(this._homeRepo);

  Future<ApiResult<FilterOptionEntity>> execute() =>
      _homeRepo.fetchFilterOptions();
}
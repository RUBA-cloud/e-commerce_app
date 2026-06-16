import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/data/model/request/profile/update_profile_request.dart';
import 'package:ecommerce_app/data/model/response/profile/profile_entity.dart';
import 'package:ecommerce_app/domain/repoistery/profile_repoistory.dart';
import 'package:injectable/injectable.dart';

@singleton
class UpdateProfileUseCase {
  final ProfileRepoistory _profileRepoistory;

  UpdateProfileUseCase(this._profileRepoistory);

  Future<ApiResult<ProfileEntity>> execute(UpdateProfileRequest request) =>_profileRepoistory.updateProfile(request);
}
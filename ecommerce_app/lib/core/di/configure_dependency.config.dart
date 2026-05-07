// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/api_service/api_service.dart' as _i790;
import '../../data/repoistery/auth_repoistery.dart' as _i1027;
import '../../data/repoistery/company_repoistery_imp.dart' as _i552;
import '../../domain/repoistery/auth_repoistery.dart' as _i145;
import '../../domain/repoistery/company_info_repoistirey.dart' as _i791;
import '../../domain/usecases/company_info_use_cases.dart' as _i373;
import '../../domain/usecases/login_use_case.dart' as _i210;
import '../../services/company_info/company_info_cubit.dart' as _i267;
import 'network_module.dart' as _i567;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.factory<_i267.CompanyInfoCubit>(() => _i267.CompanyInfoCubit());
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i790.ApiService>(() => _i790.ApiService(gh<_i361.Dio>()));
    gh.factory<_i145.AuthRepoistery>(
      () => _i1027.AuthRepoisteryImpl(apiService: gh<_i790.ApiService>()),
    );
    gh.factory<_i791.CompanyInfoRepository>(
      () => _i552.CompanyInfoRepositoryImpl(gh<_i790.ApiService>()),
    );
    gh.singleton<_i210.LoginUseCase>(
      () => _i210.LoginUseCase(authRepo: gh<_i145.AuthRepoistery>()),
    );
    gh.singleton<_i373.GetCompanyInfoUseCase>(
      () => _i373.GetCompanyInfoUseCase(gh<_i791.CompanyInfoRepository>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i567.NetworkModule {}

import 'dart:convert';

import 'package:ecommerce_app/constant/pusher_config.dart';
import 'package:ecommerce_app/constant/shared_prefence_keys.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/domain/usecases/company_info_use_cases.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_get_string_use_case.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

@injectable
class AppMainCubit extends Cubit<AppMainState> {
  final GetCompanyInfoUseCase _getCompanyInfoUseCase =
  getIt<GetCompanyInfoUseCase>();
  final SharedPrefsGetStringUseCase _getSharedPref =
  getIt<SharedPrefsGetStringUseCase>();

  static bool _pusherInitialized = false;
  static final PusherChannelsFlutter _pusher =
  PusherChannelsFlutter.getInstance();

  static AppMainCubit get(BuildContext context) => BlocProvider.of(context);

  AppMainCubit() : super(CompanyInfoInitial());

  // ── Init ──────────────────────────────────────────────────
  Future<void> init() async {
    await fetchCompanyInfo();

  // await checkUserLoggedIn();
  }



  Future<String?> get savedToken =>
      _getSharedPref.execute(SharedPrefKeys.accessToken);
  Future<String?> get savedEmail =>
      _getSharedPref.execute(SharedPrefKeys.userEmail);
  Future<String?> get savedName =>
      _getSharedPref.execute(SharedPrefKeys.userName);
  Future<String?> get savedUserId =>
      _getSharedPref.execute(SharedPrefKeys.userId);

  Future<void> checkUserLoggedIn() async {
    final token = await _getSharedPref.execute(SharedPrefKeys.accessToken);

    if (token == null || token.isEmpty) {
      emit(UserNotSignedIn());
      return;
    }

    emit(UserAlreadySigned());
  }

  // ── Fetch company info ────────────────────────────────────
  Future<void> fetchCompanyInfo() async {
    emit(CompanyInfoLoading());
    final result = await _getCompanyInfoUseCase.execute();
    switch (result) {
      case Success<CompanyInfoEntity>():
        emit(CompanyInfoLoaded(result.data));
      case Failure<CompanyInfoEntity>():
        emit(CompanyInfoError(result.error));
    }
  }

  // ── Pusher ────────────────────────────────────────────────
  Future<void> subscribePusher() async {
    try {
      print("ubscribeqPusher()");
      if (!_pusherInitialized) {
        await _pusher.init(
          apiKey:  PusherConfig.appKey,
          cluster: PusherConfig.cluster,
          useTLS:  true,
          onConnectionStateChange: (cur, prev) =>
              debugPrint('Pusher: $prev → $cur'),
          onError: (msg, code, err) =>
              debugPrint('Pusher error: $msg'),
          onEvent: (event) {
            debugPrint('Pusher event: ${event.eventName}');
            if (event.eventName == 'company_info_updated' &&
                event.data != null) {
              _onPusherEvent(event.data);
            }
          },
        );
        _pusherInitialized = true;
      }

      await _pusher.subscribe(channelName: 'company-info');
      await _pusher.connect();
    } catch (e) {
      debugPrint('Pusher setup error: $e');
    }
  }

  void _onPusherEvent(dynamic rawData)async {
    try {
      debugPrint('[Pusher] raw: $rawData');

      final map = rawData is String
          ? jsonDecode(rawData) as Map<String, dynamic>
          : rawData as Map<String, dynamic>;

      // Payload may be { company: {...} } or the company object directly
      final companyMap = map['company'] is Map<String, dynamic>
          ? map['company'] as Map<String, dynamic>
          : map;

      final updatedCompany =
      CompanyInfoCompanyEntity.fromJson(companyMap);

      final currentState = state;

      // Build a new CompanyInfoEntity merging old + new
      final CompanyInfoEntity newEntity;
      if (currentState is CompanyInfoLoaded) {
        newEntity = CompanyInfoEntity(
          currentState.company.status,
          currentState.company.message,
          updatedCompany,
        );
        emit( CompanyInfoUpdated (newEntity));

      } else {
        newEntity = CompanyInfoEntity('ok', 'updated', updatedCompany);
      }
      emit(CompanyInfoUpdated(newEntity));

      debugPrint(
        '[Pusher] updated — dark: ${updatedCompany.dark} '
            'main: ${updatedCompany.mainColor} '
            'main_dark: ${updatedCompany.mainColorDark}',
      );
    } catch (e, st) {

      debugPrint('[Pusher] _onPusherEvent error: $e\n$st');
    }
  }

  @override
  Future<void> close() async {
    try {
      await _pusher.unsubscribe(channelName: 'company-info');
      await _pusher.disconnect();
      _pusherInitialized = false;
    } catch (_) {}
    return super.close();
  }
}
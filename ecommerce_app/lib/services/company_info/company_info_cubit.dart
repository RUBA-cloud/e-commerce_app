// lib/services/company_info/company_info_cubit.dart

import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:ecommerce_app/constant/pusher_config.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';

import 'package:ecommerce_app/domain/usecases/company_info_use_cases.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

@injectable
class CompanyInfoCubit extends Cubit<CompanyInfoState> {
  final GetCompanyInfoUseCase _getCompanyInfoUseCase =
  getIt<GetCompanyInfoUseCase>();

  // ✅ Use a static flag to prevent re-initialization of the singleton
  static bool _pusherInitialized = false;
  static final PusherChannelsFlutter _pusher =
  PusherChannelsFlutter.getInstance();
    static CompanyInfoCubit get(BuildContext context) => BlocProvider.of(context);
  CompanyInfoCubit() : super(CompanyInfoInitial());

  Future<void> init() async {
    await fetchCompanyInfo();
    await _subscribePusher();
  }

  Future<void> fetchCompanyInfo() async {
    emit(CompanyInfoLoading());
    final result = await _getCompanyInfoUseCase.execute();
    switch (result) {
      case Success<CompanyInfoEntity>():
        emit(CompanyInfoLoaded(result.data));
      case Failure<CompanyInfoEntity>():
        emit(CompanyInfoError(result.error ?? 'unknown_error'));
    }
  }

  Future<void> _subscribePusher() async {
    try {
      // ✅ Only init once — re-init crashes iOS at line 237
      if (!_pusherInitialized) {
        await _pusher.init(
          apiKey:  PusherConfig.appKey,
          cluster: PusherConfig.cluster,
          useTLS:  true,
          onConnectionStateChange: (currentState, previousState) {
            debugPrint('Pusher: $previousState → $currentState');
          },
          onError: (message, code, error) {
            debugPrint('Pusher error: $message');
          },
          onEvent: (event) {
            debugPrint('Pusher event: ${event.eventName}');
            if (event.eventName == 'company_info_updated') {
              if (event.data != null) _onPusherEvent(event.data);
            }
          },
        );
        _pusherInitialized = true;
      }

      await _pusher.subscribe(channelName: 'company_info');
      await _pusher.connect();
    } catch (e) {
      debugPrint('Pusher error: $e');
      // Non-fatal — REST data still shown
    }
  }void _onPusherEvent(dynamic rawData) {
  try {
    debugPrint('Pusher raw data: $rawData');

    final map = rawData is String
        ? jsonDecode(rawData) as Map<String, dynamic>
        : rawData as Map<String, dynamic>;

    final companyMap = map['company'];
    if (companyMap == null || companyMap is! Map<String, dynamic>) {
      debugPrint('[CompanyInfoCubit] Pusher payload missing "company" key');
      return;
    }

    final updatedCompany = CompanyInfoCompanyEntity.fromJson(companyMap);

    final currentState = state;
    if (currentState is! CompanyInfoLoaded) {
      debugPrint('[CompanyInfoCubit] Pusher event ignored — state not loaded');
      return;
    }

    emit(
      CompanyInfoLoaded(
        CompanyInfoEntity.fromJson({
          ...currentState.company.toJson(),
          'company': updatedCompany.toJson(),
        }),
      ),
    );
  } catch (e, st) {
    debugPrint('[CompanyInfoCubit] _onPusherEvent error: $e\n$st');
  }
}
  @override
  Future<void> close() async {
    try {
      await _pusher.unsubscribe(channelName: 'company_info');
      await _pusher.disconnect();
      _pusherInitialized = false; // ✅ reset so it can re-init if needed
    } catch (_) {}
    return super.close();
  }
}
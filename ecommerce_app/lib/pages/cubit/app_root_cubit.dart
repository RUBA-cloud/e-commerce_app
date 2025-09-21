// lib/pages/cubit/app_root_cubit.dart
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// If you use FCM, uncomment this import and the code in _initFcmImpl()
// import 'package:firebase_messaging/firebase_messaging.dart';

@immutable
class AppRootState {
  final bool fcmInitialized;
  final String? fcmToken;
  final String? error;

  const AppRootState({required this.fcmInitialized, this.fcmToken, this.error});

  factory AppRootState.initial() => const AppRootState(fcmInitialized: false);

  AppRootState copyWith({
    bool? fcmInitialized,
    String? fcmToken,
    String? error,
  }) {
    return AppRootState(
      fcmInitialized: fcmInitialized ?? this.fcmInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      error: error,
    );
  }
}

class AppRootCubit extends Cubit<AppRootState> {
  AppRootCubit() : super(AppRootState.initial());

  Future<void> initFcm() async {
    try {
      final token = await _initFcmImpl();
      emit(state.copyWith(fcmInitialized: true, fcmToken: token, error: null));
    } catch (e) {
      emit(state.copyWith(fcmInitialized: false, error: e.toString()));
    }
  }

  Future<String?> _initFcmImpl() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken(vapidKey: "e-commerce-5bb02");
    FirebaseMessaging.onMessage.listen((m) {
      // Handle foreground messages
    });
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      // Handle notification taps
    });
    return token;
  }
}

// lib/pages/cubit/app_root_cubit.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show immutable, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;

  /// Public entry: initialize FCM and listen for messages.
  Future<void> initFcm() async {
    try {
      final token = await _initFcmImpl();
      emit(state.copyWith(fcmInitialized: true, fcmToken: token, error: null));
    } catch (e) {
      emit(state.copyWith(fcmInitialized: false, error: e.toString()));
    }
  }

  // Call this from your settings UI
  void updateLanguage(Locale locale) {
    final normalized = _normalize(locale);

    // If Get.context is null, wait one frame so MaterialApp exists
    if (Get.context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.updateLocale(normalized);
      });
    } else {
      Get.updateLocale(normalized);
    }
  }

  // Keep only the language code (e.g., "ar" not "ar_JO")
  Locale _normalize(Locale locale) => Locale(locale.languageCode.toLowerCase());

  /// Private: actual FCM wiring.
  Future<String?> _initFcmImpl() async {
    final messaging = FirebaseMessaging.instance;

    // Ask notification permission (iOS, Web, Android 13+).
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // On web, you must pass your Web Push certificates key (VAPID key).
    // Replace 'YOUR_WEB_PUSH_CERTIFICATE_KEY' with the long base64 key
    // from Firebase Console → Project Settings → Cloud Messaging.
    final token = await messaging.getToken(
      vapidKey: kIsWeb ? 'YOUR_WEB_PUSH_CERTIFICATE_KEY' : null,
    );

    // Foreground messages
    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      // TODO: show an in-app banner/snackbar/overlay, update state, etc.
      // print('Foreground message: ${m.notification?.title}');
    });

    // App opened via notification tap
    _onOpenedAppSub?.cancel();
    _onOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage m,
    ) {
      // TODO: deep link / navigate using Get.toNamed(...)
      // final route = m.data['route'];
    });

    // Optionally handle the case where the app is launched from a terminated
    // state via a notification tap:
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Handle deep link/navigation here if desired.
    }

    return token;
  }

  @override
  Future<void> close() {
    _onMessageSub?.cancel();
    _onOpenedAppSub?.cancel();
    return super.close();
  }
}

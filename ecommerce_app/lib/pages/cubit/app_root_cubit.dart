// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

// ...existing code...
@immutable
class AppRootState {
  final bool fcmInitialized;
  final String? fcmToken;
  final String? error;

  const AppRootState({required this.fcmInitialized, this.fcmToken, this.error});

  // Return the initial state (don't perform side-effects here).
  factory AppRootState.initial() {
    return const AppRootState(fcmInitialized: false);
  }

  AppRootState copyWith({
    bool? fcmInitialized,
    String? fcmToken,
    String? error,
  }) {
    return AppRootState(
      fcmInitialized: fcmInitialized ?? this.fcmInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      error: error ?? this.error,
    );
  }
}

class AppRootCubit extends Cubit<AppRootState> {
  AppRootCubit() : super(AppRootState.initial());

  

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

 
  
}
// ...existing code...

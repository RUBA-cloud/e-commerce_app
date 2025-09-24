import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({required this.themeMode, required this.locale});

  factory SettingsState.initial() =>
      const SettingsState(themeMode: ThemeMode.system, locale: Locale('en'));

  get notificationsEnabled => null;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled = false,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
  );
}

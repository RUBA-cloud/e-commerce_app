import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/pages/cubit/app_root_cubit.dart';
import 'package:ecommerce_app/views/settings/cubit/settings_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState.initial());

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeStr = prefs.getString('theme') ?? 'system';
    final theme = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    // Load language
    final langCode =
        prefs.getString('lang') ?? Get.deviceLocale?.languageCode ?? 'en';

    final notification = prefs.getBool('notifications') ?? false;
    final locale = Locale(langCode);

    emit(
      state.copyWith(
        themeMode: theme,
        locale: locale,
        notificationsEnabled: notification,
      ),
    );
    Get.changeThemeMode(theme);
    Get.updateLocale(locale);
  }

  Future<void> toggleTheme() async {
    final next =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
    Get.changeThemeMode(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    final key = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString('theme', key);
    Get.changeThemeMode(mode);
  }

  Future<void> setLanguage(String code, BuildContext context) async {
    final locale = Locale(code);
    emit(state.copyWith(locale: locale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);

    // ignore: use_build_context_synchronously
    final appRootCubit = BlocProvider.of<AppRootCubit>(context);
    appRootCubit.updateLanguage(locale);
  }

  Future<void> logout() async {
    // await Future<void>.delayed(const Duration(milliseconds: 200));
    Get.toNamed(AppRoutes.login);
  }

  Future<void> toggleNotifications(bool val) async {
    emit(state.copyWith(notificationsEnabled: val));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
  }
}

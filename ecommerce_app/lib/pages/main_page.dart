// main.dart
// ---------
// A complete starter showing:
// - GetX routing (GetMaterialApp, named routes)
// - EN/AR localization with GetX Translations
// - RTL/LTR switching
// - flutter_screenutil for multi‑screen responsiveness
// - Simple Home -> Details flow with a language & theme toggle
//
// pubspec.yaml additions (for reference):
// dependencies:
//   flutter:
//     sdk: flutter
//   get: ^4.6.6
//   flutter_screenutil: ^5.9.0
//   flutter_localizations:
//     sdk: flutter

import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/controllers/ThemeController.dart';
import 'package:ecommerce_app/language/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// -----------------------------
// Theme Controller (optional)
// -----------------------------

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.put(ThemeController());

    return ScreenUtilInit(
      designSize: const Size(375, 812), // base iPhone 11 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'app_title'.tr,

            // Localization
            translations: AppTranslations(),
            locale: Get.deviceLocale ?? const Locale('en', 'US'),
            fallbackLocale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'JO')],

            // Themes
            themeMode: themeCtrl.themeMode,
            theme: ThemeData(
              colorSchemeSeed: const Color(0xFF1D5D9B),
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: const Color(0xFF1D5D9B),
              brightness: Brightness.dark,
              useMaterial3: true,
            ),

            // Routing
            initialRoute: AppRoutes.home,
            getPages: AppPages.pages,
          ),
        );
      },
    );
  }
}

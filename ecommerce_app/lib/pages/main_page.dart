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
    final themeCtrl = Get.find<ThemeController>();

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

// -----------------------------
// UI Helpers
// -----------------------------
Widget _langButton(Locale locale, String label) {
  return OutlinedButton(
    onPressed: () => Get.updateLocale(locale),
    child: Text(label),
  );
}

// -----------------------------
// Home Page
// -----------------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    // Direction is auto from locale (AR -> RTL)
    return Scaffold(
      appBar: AppBar(
        title: Text('home_title'.tr),
        actions: [
          // Theme toggle
          IconButton(
            tooltip: 'change_theme'.tr,
            onPressed: themeCtrl.toggle,
            icon: const Icon(Icons.brightness_6),
          ),
          // Language menu
          PopupMenuButton<String>(
            tooltip: 'change_lang'.tr,
            icon: const Icon(Icons.language),
            onSelected: (v) {
              if (v == 'ar') Get.updateLocale(const Locale('ar', 'JO'));
              if (v == 'en') Get.updateLocale(const Locale('en', 'US'));
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'en', child: const Text('English')),
              PopupMenuItem(value: 'ar', child: const Text('العربية')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'hello_user'.trParams({'name': 'Ruba'}),
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: 0.7.sw,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.details,
                    arguments: {'id': 42, 'title': 'details_title'.tr},
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(
                    'open_details'.tr,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

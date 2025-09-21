import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/controllers/theme_controller.dart';
import 'package:ecommerce_app/language/app_translations.dart';
import 'package:ecommerce_app/pages/cubit/app_root_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.put(ThemeController());

    return BlocProvider<AppRootCubit>(
      // Call init once here, not in builder
      create: (_) => AppRootCubit()..initFcm(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Obx(
            () => BlocListener<AppRootCubit, AppRootState>(
              listenWhen: (prev, curr) =>
                  prev.fcmInitialized != curr.fcmInitialized ||
                  prev.error != curr.error,
              listener: (context, state) {
                if (state.error != null && state.error!.isNotEmpty) {
                  Get.snackbar(
                    'FCM',
                    'Init failed: ${state.error}',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else if (state.fcmInitialized) {
                  // You can log or save the token:
                  // debugPrint('FCM Token: ${state.fcmToken}');
                }
              },
              child: GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'app_title'.tr,
                translations: AppTranslations(),
                locale: Get.deviceLocale ?? const Locale('en', 'US'),
                fallbackLocale: const Locale('en', 'US'),
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('ar', 'JO'),
                ],
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
                initialRoute: AppRoutes.home,
                getPages: AppPages.pages,
              ),
            ),
          );
        },
      ),
    );
  }
}

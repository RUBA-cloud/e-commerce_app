import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/controllers/theme_controller.dart';
import 'package:ecommerce_app/language/app_translations.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/pages/cubit/app_root_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.put(ThemeController());
    return BlocProvider<AppRootCubit>(
      create: (_) => AppRootCubit(), // ..initIfYouHaveOne()
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Obx(
            () => GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'app_title'.tr,

              // GetX translations
              translations: AppTranslations(),
              // Use Get.locale so Get.updateLocale(...) actually updates the UI
              locale: Get.locale ?? Get.deviceLocale ?? const Locale('en'),
              fallbackLocale: const Locale('en'),

              // 🔑 These provide Material/Cupertino/Widgets strings & RTL support
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // Keep it simple: language-only codes work great with delegates
              supportedLocales: const [Locale('en'), Locale('ar')],

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

              initialRoute: UserModel.currentUser != null
                  ? AppRoutes.home
                  : AppRoutes.login,
              getPages: AppPages.pages,

              // Attach your BlocListener safely via builder so MaterialApp exists
              builder: (context, appChild) {
                return BlocListener<AppRootCubit, AppRootState>(
                  listenWhen: (prev, curr) =>
                      prev.fcmInitialized != curr.fcmInitialized ||
                      prev.error != curr.error,
                  listener: (context, state) {
                    // Post-frame so we don’t emit snackbars during build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if ((state.error ?? '').isNotEmpty) {
                        Get.snackbar(
                          'FCM',
                          'Init failed: ${state.error}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else if (state.fcmInitialized) {
                        // debugPrint('FCM Token: ${state.fcmToken}');
                      }
                    });
                  },
                  child: appChild,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

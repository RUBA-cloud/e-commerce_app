import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/controllers/theme_controller.dart';
import 'package:ecommerce_app/language/app_translations.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/pages/cubit/app_root_cubit.dart';

// ⬇️ Make sure these imports match your actual paths
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_cubit.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_cubit.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart';

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
    // themeCtrl.getUserThemeandLanguage();
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) {
            final cubit = HomeCubit();
            cubit.loadCategories();
            return cubit;
          },
        ),
        BlocProvider<CartCubit>(
          create: (_) => CartCubit()..load(),
        ),
        BlocProvider<FavoriteCubit>(
          create: (_) => FavoriteCubit()..load(),
        ),
        BlocProvider<AppRootCubit>(
          create: (_) => AppRootCubit(), // ..initIfYouHaveOne()
        ),
      ],
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
              locale: Get.locale ?? Get.deviceLocale ?? const Locale('en'),
              fallbackLocale: const Locale('en'),

              // Localization + RTL support
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
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

              initialRoute: UserModel.currentUser != null
                  ? AppRoutes.home
                  : AppRoutes.login,
              getPages: AppPages.pages,

              // Attach BlocListener around the app tree
              builder: (context, appChild) {
                return BlocListener<AppRootCubit, AppRootState>(
                  listenWhen: (prev, curr) =>
                      prev.fcmInitialized != curr.fcmInitialized ||
                      prev.error != curr.error,
                  listener: (context, state) {
                
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

// lib/main.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/presentation/home/home_buttom_navigation.dart';
import 'package:ecommerce_app/presentation/auth/login_screen.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:ecommerce_app/services/login/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations/',
      fallbackLocale: const Locale('en'),
      child: BlocProvider(
        create: (_) => AppMainCubit()..init(),
        child: const AppRoot(),
      ),
    ),
  );
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with UiUtility {
  AppMainState? _lastRoutableState;

  bool _isRoutable(AppMainState s) =>
      s is CompanyInfoLoaded ||
          s is CompanyInfoUpdated ||
          s is UserAlreadySigned ||
          s is UserNotSignedIn;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (ctx, child) {
        return BlocListener<AppMainCubit, AppMainState>(
          listenWhen: (previous, current) => current is CompanyInfoUpdated,
          listener: (context, state) {
            AppMainCubit.get(context).subscribePusher();
          },
          child: BlocBuilder<AppMainCubit, AppMainState>(
            buildWhen: (previous, current) => _isRoutable(current),
            builder: (context, state) {
              final effective =
              _isRoutable(state) ? state : _lastRoutableState;
              if (_isRoutable(state)) _lastRoutableState = state;

              final companyColor = companyColors(effective ?? state);
              final isDark       = _isDarkMode(effective);
              final theme        = buildTheme(companyColor);
              final darkTheme    =
              buildTheme(companyColor, brightness: Brightness.dark);
              final Widget home  = _resolveHome(effective);

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Ecommerce App',
                localizationsDelegates: context.localizationDelegates,
                supportedLocales:       context.supportedLocales,
                // FIX: always read locale from EasyLocalization context,
                // not cached — this ensures every MaterialApp rebuild picks
                // up the latest locale immediately.
                locale:   context.locale,
                theme:    theme,
                darkTheme: darkTheme,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                home: home,
                builder: (context, child) =>
                child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _resolveHome(AppMainState? state) {
    if (state is UserNotSignedIn) {
      return BlocProvider(
        // FIX: stable key prevents re-creation on locale change rebuilds
        key: const ValueKey('login'),
        create: (_) => LoginCubit(),
        child: const LoginScreen(),
      );
    }

    if (state is CompanyInfoLoaded || state is CompanyInfoUpdated) {
      final isSignedIn = state is UserAlreadySigned;

      if (isSignedIn) {
        return BlocProvider(
          key: const ValueKey('home'),
          create: (_) => HomeCubit(),
          child: const ButtonHomeNavigationScreen(),
        );
      }

      return BlocProvider(
        key: const ValueKey('login'),
        create: (_) => LoginCubit(),
        child: const LoginScreen(),
      );
    }

    if (state is UserAlreadySigned) {
      return BlocProvider(
        key: const ValueKey('home'),
        create: (_) => HomeCubit(),
        child: const ButtonHomeNavigationScreen(),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  bool _isDarkMode(AppMainState? state) {
    if (state is CompanyInfoLoaded)  return state.company.company.dark;
    if (state is CompanyInfoUpdated) return state.company.company.dark;
    return false;
  }
}
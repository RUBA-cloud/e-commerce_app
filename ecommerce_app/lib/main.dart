// lib/main.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/presentation/home/home_buttom_navigation.dart';
import 'package:ecommerce_app/presentation/auth/login_screen.dart';
import 'package:ecommerce_app/services/company_info/app_main_cubit.dart';
import 'package:ecommerce_app/services/company_info/app_main_state.dart';
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

  // ── A state is "routable" if it carries enough info to decide the screen ──
  bool _isRoutable(AppMainState s) =>
      s is CompanyInfoLoaded  ||
          s is CompanyInfoUpdated ||
          s is UserAlreadySigned  ||
          s is UserNotSignedIn    ||
          s is ThemeChangedState;

  @override
  Widget build(BuildContext context) {
    final locale           = context.locale;
    final delegates        = context.localizationDelegates;
    final supportedLocales = context.supportedLocales;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (ctx, child) {
        return BlocListener<AppMainCubit, AppMainState>(
          listenWhen: (_, current) =>
          current is CompanyInfoUpdated ||
              current is ThemeChangedState,
          listener: (context, state) {
            // nothing extra needed here — Pusher is already subscribed in init()
          },
          child: BlocBuilder<AppMainCubit, AppMainState>(
            buildWhen: (_, current) => _isRoutable(current),
            builder: (context, state) {
              // ✅ always keep the last routable state so theme changes
              //    don't wipe out the current auth/company state
              if (_isRoutable(state)) _lastRoutableState = state;
              final effective = _lastRoutableState ?? state;

              // ✅ read isDark from cubit directly — handles ThemeChangedState
              final appCubit = AppMainCubit.get(context);
              final isDark   = _isDarkMode(effective, appCubit);

              // ✅ colorState: ThemeChangedState has no company data —
              //    resolve from cubit if it has loaded company data
              final colorState = (effective is ThemeChangedState)
                  ? ((appCubit.state is CompanyInfoLoaded ||
                  appCubit.state is CompanyInfoUpdated)
                  ? appCubit.state
                  : effective)
                  : effective;

              final companyColor = companyColors(colorState, context);
              final theme        = buildTheme(
                companyColor,
                brightness: Brightness.light,
              );
              final darkTheme    = buildTheme(
                companyColor,
                brightness: Brightness.dark,
              );

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Ecommerce App',
                localizationsDelegates: delegates,
                supportedLocales:       supportedLocales,
                locale:                 locale,
                theme:                  theme,
                darkTheme:              darkTheme,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                home:      _resolveHome(effective, appCubit),
                builder: (_, child) => child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _resolveHome(AppMainState? state, AppMainCubit appCubit) {
    // ── Not signed in ──────────────────────────────────────────────────────
    if (!appCubit.loggedIn) {
      return BlocProvider(
        key: const ValueKey('login'),
        create: (_) => LoginCubit(),
        child: const LoginScreen(),
      );
    }

    // ── Signed in ──────────────────────────────────────────────────────────
    // ✅ UserAlreadySigned, CompanyInfoLoaded, CompanyInfoUpdated,
    //    and ThemeChangedState all go to home when the user is signed in.
    //    The cubit tracks auth separately from company/theme state, so we
    //    check appCubit.isSignedIn rather than the state type.
    if (appCubit.loggedIn) {
      return BlocProvider(
        key: const ValueKey('home'),
        create: (_) => HomeCubit(),
        child: const ButtonHomeNavigationScreen(),
      );
    }

    // ✅ CompanyInfoLoaded / CompanyInfoUpdated / ThemeChangedState —
    //    user was already signed in (token exists) but the state emitted
    //    was company/theme related, not auth related.
    //    Read the saved token from the cubit to decide.
    if (state is CompanyInfoLoaded  ||
        state is CompanyInfoUpdated ||
        state is ThemeChangedState) {
      // ✅ if the cubit ever emitted UserAlreadySigned, the user is signed in
      final isSignedIn = state is UserAlreadySigned;
      if(state is ThemeChangedState) {
       showSnackBar(context: context, message: "message");}
      if (isSignedIn) {
        return BlocProvider(
          key: const ValueKey('home'),
          create: (_) => HomeCubit(),
          child: const ButtonHomeNavigationScreen(),
        );
      } else {
        return BlocProvider(
          key: const ValueKey('login'),
          create: (_) => LoginCubit(),
          child: const LoginScreen(),
        );
      }
    }

    // ── Still loading ──────────────────────────────────────────────────────
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  // ✅ isDark from cubit + ThemeChangedState aware
  bool _isDarkMode(AppMainState? state, AppMainCubit appCubit) {
    // ThemeChangedState carries the new isDark value directly
    if (state is ThemeChangedState) return state.isDark;
    // otherwise trust the cubit's persisted value
    return appCubit.isDark;
  }
}
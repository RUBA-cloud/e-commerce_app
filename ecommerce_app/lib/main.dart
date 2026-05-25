import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/presentation/home/home_buttom_navigation.dart';
import 'package:ecommerce_app/presentation/login_screen.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:ecommerce_app/services/cart/cart_cubit.dart';
import 'package:ecommerce_app/services/login/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget with UiUtility {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final locale           = context.locale;
    final supportedLocales = context.supportedLocales;
    final delegates        = context.localizationDelegates;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (ctx, child) {
        return BlocProvider(
          create: (_) => AppMainCubit()..init(),
          child: BlocBuilder<AppMainCubit, AppMainState>(
            buildWhen: (previous, current) =>
            current is CompanyInfoLoaded   ||
                current is CompanyInfoUpdated  ||
                current is UserAlreadySigned   ||
                current is UserNotSignedIn,
            builder: (context, state) {
              final c = companyColors(state);
              buildTheme(c,brightness: Brightness.dark);
              // ✅ Decide home widget based on login state
              final Widget homeWidget = state is UserAlreadySigned
                  ? BlocProvider(
                      create: (_) => CartCubit()..loadCart(),
                      child: const ButtonHomeNavigationScreen(),
                    )
                  : BlocProvider(
                create: (_) => LoginCubit(),
                child: const LoginScreen(),
              );

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Ecommerce App',

                localizationsDelegates: [
                  ...delegates,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: supportedLocales,
                locale: locale,

                theme: buildTheme(c),

                // ✅ home takes a Widget, not a String
                home: homeWidget,


                builder: (context, child) => child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/presentation/home_screen.dart';
import 'package:ecommerce_app/presentation/login_screen.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
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
    // ✅ Read locale HERE — EasyLocalization is in context at this level
    final locale           = context.locale;
    final supportedLocales = context.supportedLocales;
    final delegates        = context.localizationDelegates;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (ctx, child) {
        return BlocProvider(
          create: (_) => CompanyInfoCubit()..init(),
          child: BlocBuilder<CompanyInfoCubit, CompanyInfoState>(
            buildWhen: (previous, current) =>
                current is CompanyInfoLoaded || current is CompanyInfoUpdated,
            builder: (context, state) {
              // ✅ Single call — all colors extracted + defaulted in UiUtility
              final c = companyColors(state);

              debugPrint('mainColor: ${c.main}');

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

                // ✅ buildTheme is now in UiUtility
                theme: buildTheme(c),

                initialRoute: '/',
                routes: {
                  '/': (context) => BlocProvider(
                        create: (_) => LoginCubit(),
                        child: const LoginScreen(),
                      ),
                  '/home': (context) => const HomeScreen(),
                },
                builder: (context, child) => child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
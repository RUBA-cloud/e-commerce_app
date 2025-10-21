// ignore_for_file: deprecated_member_use
import 'package:ecommerce_app/components/basic_form.dart';
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/services/socail_media_services.dart'; // fix typo if needed
import 'package:ecommerce_app/views/auth/login%20/login_form.dart';
import 'package:ecommerce_app/views/auth/register/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/basic_auth_cubit.dart';

class BasicAuth extends StatelessWidget {
  const BasicAuth({super.key});

  int _indexFromState(BasicAuthState s) {
    if (s is RegisterAuth) return 1;
    return 0; // LoginAuth & Initial
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BasicAuthCubit(),
      child: BlocBuilder<BasicAuthCubit, BasicAuthState>(
        builder: (context, state) {
          final scheme = Theme.of(context).colorScheme;
          final mainColor = scheme.primary;
          final isAr =
              (Get.locale?.languageCode ?? Get.deviceLocale?.languageCode) ==
                  'ar';

          final currentIndex = _indexFromState(state);

          return SafeArea(
            child: Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withOpacity(.06),
                      scheme.secondary.withOpacity(.05),
                      scheme.surface,
                    ],
                  ),
                ),
                child: BasicFormWidget(
                  form: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        elevation: 8,
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        color: scheme.surface.withOpacity(.92),
                        shadowColor: mainColor.withOpacity(.2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: scheme.primary.withOpacity(.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 14.h,
                          ),
                          child: DefaultTabController(
                            length: 2,
                            initialIndex: currentIndex,
                            child: Column(
                              children: [
                                SizedBox(height: 20.h),

                                Align(
                                  alignment: isAr
                                      ? Alignment.topLeft
                                      : Alignment.topRight,
                                  child: TextButton(
                                    child: Text("forget_password".tr),
                                    onPressed: () =>
                                        Get.toNamed(AppRoutes.forgetPassword),
                                  ),
                                ),

                                // Brand mark
                                Container(
                                  height: 56.r,
                                  width: 56.r,
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    Icons.home_work_rounded,
                                    color: mainColor,
                                    size: 28.r,
                                  ),
                                ),
                                SizedBox(height: 14.h),

                                Text(
                                  'welcome'.tr,
                                  style: AppTextStyles.headline(context),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'welcome_subtTitle'.tr,
                                  style: AppTextStyles.bodyMuted(context),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 18.h),

                                // TabBar (controlled by Cubit onTap)
                                Container(
                                  height: 48.h,
                                  width: 230.w,
                                  margin: EdgeInsets.symmetric(
                                    vertical: 6.h,
                                    horizontal: 10.w,
                                  ),
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(60.r),
                                    border: Border.all(
                                      color: mainColor.withOpacity(.20),
                                    ),
                                  ),
                                  child: Center(
                                    child: TabBar(
                                      dividerColor: Colors.transparent,
                                      dividerHeight: 0,
                                      isScrollable: true,
                                      labelPadding: EdgeInsets.symmetric(
                                        horizontal: 22.w,
                                      ),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          26.r,
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            scheme.primary,
                                            scheme.secondary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: scheme.primary.withOpacity(
                                              .35,
                                            ),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      labelColor: scheme.onPrimary,
                                      unselectedLabelColor:
                                          scheme.onSurface.withOpacity(.75),
                                      labelStyle: AppTextStyles.body(context),
                                      unselectedLabelStyle:
                                          AppTextStyles.caption(context),
                                      onTap: (i) => context
                                          .read<BasicAuthCubit>()
                                          .changeTab(i),
                                      tabs: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 1.h,
                                          ),
                                          child: Tab(text: 'login'.tr),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 1.h,
                                          ),
                                          child: Tab(text: 'register'.tr),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16.h),

                                // TabBarView
                                Expanded(
                                  flex: context.read<BasicAuthCubit>().state
                                          is RegisterAuth
                                      ? 5
                                      : 2,
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: const [
                                      LoginForm(),
                                      RegisterForm(),
                                    ],
                                  ),
                                ),

                                Text("-${"or".tr}"),
                                SizedBox(height: 8.h),
                                Expanded(
                                  flex: context.read<BasicAuthCubit>().state
                                          is RegisterAuth
                                      ? 1
                                      : 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        color: Colors.indigo,
                                        onPressed: () {},
                                        icon: const Icon(Icons.facebook),
                                      ),
                                      IconButton(
                                        color: Colors.red,
                                        onPressed: () => SocialAuthService
                                            .instance
                                            .signInWithGoogle(),
                                        icon: const Icon(Icons.g_mobiledata),
                                      ),
                                      IconButton(
                                        color: Colors.black,
                                        onPressed: () => SocialAuthService
                                            .instance
                                            .signInWithAppleWeb(),
                                        icon: const Icon(Icons.apple),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

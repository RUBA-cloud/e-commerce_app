// ignore_for_file: deprecated_member_use

import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/views/auth/login /login_form.dart';
import 'package:ecommerce_app/views/auth/register/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// ---------------------------
/// AUTH TABBED PAGE (CENTERED) - Custom
/// ---------------------------
class BasicAuth extends StatelessWidget {
  const BasicAuth({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mainColor = scheme.primary;
    final isAr =
        (Get.locale?.languageCode ?? Get.deviceLocale?.languageCode) == 'ar';

    return SafeArea(
      child: Scaffold(
        // Soft brand background with subtle gradient + shapes
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
          child: Stack(
            children: [
              // Decorative blurred circles
              Positioned(
                top: -60.h,
                left: -40.w,

                child: _blurBall(scheme.primary.withOpacity(.20), 180.r),
              ),
              Positioned(
                bottom: -80.h,
                right: -50.w,
                child: _blurBall(scheme.secondary.withOpacity(.18), 220.r),
              ),

              // Content
              Center(
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
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),

                            // Brand mark / icon
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

                            // Title & subtitle (AppTextStyles)
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

                            // Rounded Tab Switcher (pill)
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
                                    borderRadius: BorderRadius.circular(26.r),
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
                                        color: scheme.primary.withOpacity(.35),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  labelColor: scheme.onPrimary,

                                  unselectedLabelColor: scheme.onSurface
                                      .withOpacity(.75),
                                  labelStyle: AppTextStyles.body(context),
                                  unselectedLabelStyle: AppTextStyles.caption(
                                    context,
                                  ),

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

                            // Content
                            Expanded(
                              child: TabBarView(
                                children: const [
                                  LoginForm(), // Stateless + Cubit inside form
                                  RegisterForm(),
                                ],
                              ),
                            ),

                            // Footer actions
                            Align(
                              alignment: isAr
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () =>
                                    Get.toNamed(AppRoutes.forgetPassword),
                                child: Text(
                                  'forget_password'.tr,
                                  style: AppTextStyles.link(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blurBall(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 20)],
      ),
    );
  }
}

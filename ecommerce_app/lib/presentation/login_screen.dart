import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/presentation/widgets/basic_form_filed.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:ecommerce_app/services/login/login_cubit.dart';
import 'package:ecommerce_app/services/login/login_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with UiUtility {
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey      = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    LoginCubit.get(context).getCountryAndCity();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Rebuild whenever a Pusher event updates company info ──────────────
    return BlocBuilder<CompanyInfoCubit, CompanyInfoState>(
      buildWhen: (prev, curr) =>
          curr is CompanyInfoLoaded || curr is CompanyInfoUpdated,
      builder: (context, companyState) {
        // ✅ All colors from UiUtility — re-resolved on every Pusher event
        final c       = companyColors(companyState);
        final surface = Theme.of(context).colorScheme.surface;

        return BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginUnverified) {
              Navigator.pushNamed(context, '/verify-email');
              return;
            }
            if (state is LoginSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (_) => false);
              return;
            }
            if (state is LoginFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:         Text(state.message),
                  backgroundColor: Colors.red.shade700,
                  behavior:        SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<LoginCubit, LoginState>(
            buildWhen: (prev, curr) =>
                curr is LoginLoading ||
                curr is LoginSuccess  ||
                curr is LoginFailed   ||
                curr is LoginInitial,
            builder: (context, loginState) {
              final cubit = LoginCubit.get(context);

              return Scaffold(
                backgroundColor: c.card,
                body: Stack(
                  children: [
                    // ✅ backgroundBlobs from UiUtility
                    ...backgroundBlobs(c.main),

                    SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 56.h),

                              // ── Logo ─────────────────────────────────
                              Center(
                                child: Container(
                                  width:  72.r,
                                  height: 72.r,
                                  decoration: BoxDecoration(
                                    color:        c.main,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color:      c.main.withOpacity(0.35),
                                        blurRadius: 24,
                                        offset:     const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: c.buttonText,
                                    size:  36.r,
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),

                              // ── Headline ──────────────────────────────
                              Center(
                                child: Text(
                                  'welcome_back'.tr(),
                                  style: TextStyle(
                                    fontSize:      28.sp,
                                    fontWeight:    FontWeight.w800,
                                    color:         c.text,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Center(
                                child: Text(
                                  'login_subtitle'.tr(),
                                  style: TextStyle(
                                    fontSize:   14.sp,
                                    color:      c.hint,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.h),

                              // ✅ formCard from UiUtility
                              formCard(
                                surfaceColor: surface,
                                shadowColor:  c.main,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Email ──────────────────────────
                                    fieldLabel('email'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller:   emailCtrl,
                                      hintText:     'enter_email'.tr(),
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: c.main,
                                      ),
                                      isBorder: true,
                                      radius:   14,
                                      validator: (v) {
                                        final val = (v ?? '').trim();
                                        if (val.isEmpty) {
                                          return 'email_required'.tr();
                                        }
                                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                            .hasMatch(val)) {
                                          return 'enter_valid_email'.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20.h),

                                    // ── Password ───────────────────────
                                    fieldLabel('password'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller: passwordCtrl,
                                      hintText:   'enter_password'.tr(),
                                      isPassword: true,
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: c.main,
                                      ),
                                      isBorder: true,
                                      radius:   14,
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'password_is_required'.tr()
                                              : null,
                                    ),
                                    SizedBox(height: 10.h),

                                    // ── Forgot password ────────────────
                                    Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: TextButton(
                                        onPressed: () => Navigator.pushNamed(
                                            context, '/forgot-password'),
                                        style: TextButton.styleFrom(
                                          padding:       EdgeInsets.zero,
                                          minimumSize:   Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'forgot_password'.tr(),
                                          style: TextStyle(
                                            fontSize:   13.sp,
                                            color:      c.main,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 28.h),

                                    // ✅ primaryButton from UiUtility
                                    primaryButton(
                                      label:           'login'.tr(),
                                      loading:         loginState is LoginLoading,
                                      backgroundColor: c.button,
                                      foregroundColor: c.buttonText,
                                      onPressed: () {
                                        if (!formKey.currentState!.validate()) return;
                                        cubit.submit(
                                          loginRequest: LoginRequest(
                                            email:    emailCtrl.text.trim(),
                                            password: passwordCtrl.text,
                                            country:  cubit.country,
                                            city:     cubit.city,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 28.h),

                              // ── Divider ───────────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: c.sub.withOpacity(0.3)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    child: Text(
                                      'or'.tr(),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color:    c.hint,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: c.sub.withOpacity(0.3)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 28.h),

                              // ── Register CTA ──────────────────────────
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'no_account'.tr(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color:    c.hint,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                          context, '/register'),
                                      child: Text(
                                        'register'.tr(),
                                        style: TextStyle(
                                          fontSize:   14.sp,
                                          color:      c.main,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
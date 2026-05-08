import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/presentation/forgot_password_screen.dart';
import 'package:ecommerce_app/presentation/home_screen.dart';
import 'package:ecommerce_app/presentation/register_screen.dart';
import 'package:ecommerce_app/presentation/verify_email_screen.dart';
import 'package:ecommerce_app/presentation/widgets/basic_form_filed.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:ecommerce_app/services/login/login_cubit.dart';
import 'package:ecommerce_app/services/login/login_state.dart';
import 'package:ecommerce_app/services/register/register_cubit.dart';
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
  late LoginCubit loginCubit;

  @override
  void initState() {
    super.initState();
  loginCubit=  LoginCubit.get(context);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Outer: company info → colors ─────────────────────────
    return BlocBuilder<CompanyInfoCubit, CompanyInfoState>(
      buildWhen: (prev, curr) =>
          curr is CompanyInfoLoaded || curr is CompanyInfoUpdated,
      builder: (context, companyState) {
        final c       = companyColors(companyState);
        final surface = Theme.of(context).colorScheme.surface;

        // ── Navigation side-effects ───────────────────────────
        return BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {

              if (state is LoginUnverified) {
                navigateTo(
                  context: context,
                  page: BlocProvider(
                    create: (_) => RegisterCubit(),
                    child: VerifyEmailScreen(
                      email: emailCtrl.text.trim(),
                    ),
                  ),
                );
                return;

            }

            if (state is LoginSuccess) {
              navigateTo(context: context, page: HomeScreen()); return;
            }
            if (state is GoToForgotPassword) {
              navigateTo(context: context, page: BlocProvider.value(value: loginCubit,child: ForgotPassword(),)); return;
            }
            // ✅ goToRegister handled here — no phantom state needed
            if (state is GoToRegister) {
              navigateTo(
                context: context,
                page: BlocProvider(
                  create: (_) => RegisterCubit(),
                  child: const RegisterScreen(),
                ),
              );
              return;
            }
            if (state is LoginFailed) {
              showSnackBar(context: context, message: state.message,success: false);

            }
          },

          // ── Inner: login state → UI ───────────────────────────
          child: BlocBuilder<LoginCubit, LoginState>(
            buildWhen: (prev, curr) =>
                curr is LoginLoading ||
                curr is LoginSuccess ||
                curr is LoginFailed  ||
                curr is LoginInitial,
            builder: (context, loginState) {
              final cubit = LoginCubit.get(context);

              return Scaffold(
                backgroundColor: c.card,
                body: Stack(
                  children: [
                    ...backgroundBlobs(c.main),

                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Form(
                          key: formKey,
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 56.h),

                              // ── Brand logo ──────────────────────
                              Center(child: brandLogo(c: c)),
                              SizedBox(height: 32.h),

                              // ── Headline ────────────────────────
                              screenHeadline(
                                title:    'welcome_back'.tr(),
                                subtitle: 'login_subtitle'.tr(),
                                c:        c,
                              ),
                              SizedBox(height: 40.h),

                              // ── Form card ───────────────────────
                              formCard(
                                surfaceColor: surface,
                                shadowColor:  c.main,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Email
                                    fieldLabel('email'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller:   emailCtrl,
                                      hintText:     'enter_email'.tr(),
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: c.main),
                                      isBorder: false,
                                      radius:   14,
                                      validator: (v) {
                                        final val = (v ?? '').trim();
                                        if (val.isEmpty) {
                                          return 'email_required'.tr();
                                        }
                                        if (!RegExp(
                                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                            .hasMatch(val)) {
                                          return 'enter_valid_email'.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20.h),

                                    // Password
                                    fieldLabel('password'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller: passwordCtrl,
                                      hintText:   'enter_password'.tr(),
                                      isPassword: true,
                                      prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: c.main),
                                      isBorder: false,
                                      radius:   14,
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'password_is_required'.tr()
                                              : null,
                                    ),
                                    SizedBox(height: 10.h),

                                    // Forgot password
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerEnd,
                                      child: TextButton(
                                        onPressed: (){cubit.goToForgotPassword();},
                                          
                                        
                                        style: TextButton.styleFrom(
                                          padding:     EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
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

                                    // Submit
                                    primaryButton(
                                      label:           'login'.tr(),
                                      loading:
                                          loginState is LoginLoading,
                                      backgroundColor: c.button,
                                      foregroundColor: c.buttonText,
                                      onPressed: () {
                                        if (!formKey.currentState!
                                            .validate()) return;
                                        cubit.submit(
                                          loginRequest: LoginRequest(
                                            email:    emailCtrl.text
                                                .trim(),
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

                              // ── Divider ─────────────────────────
                              orDivider(c: c),
                              SizedBox(height: 28.h),

                              // ── Register CTA ────────────────────
                              Center(
                                child: authLink(
                                  question: 'no_account'.tr(),
                                  action:   'register'.tr(),
                                  c:    c,
                                  
                                  // ✅ push without named route —
                                  //    BlocProvider wraps RegisterScreen
                                  onTap: () => cubit.goToRegister(),
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
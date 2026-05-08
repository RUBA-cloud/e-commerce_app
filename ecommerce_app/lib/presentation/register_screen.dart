import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/presentation/home_screen.dart';
import 'package:ecommerce_app/presentation/login_screen.dart';

import 'package:ecommerce_app/presentation/widgets/basic_form_filed.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:ecommerce_app/services/register/register_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static void push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => RegisterCubit()..getCountryAndCity(),
            child: const RegisterScreen(),
          ),
        ),
      );

  static void pushReplacement(BuildContext context) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => RegisterCubit()..getCountryAndCity(),
            child: const RegisterScreen(),
          ),
        ),
      );

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with UiUtility {
  final nameCtrl     = TextEditingController();
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl    = TextEditingController();
  final formKey      = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ getCountryAndCity already called via ..getCountryAndCity() in push()
    // but also safe to call here if screen is built from elsewhere
    RegisterCubit.get(context).getCountryAndCity();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
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
        return BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              );
              return;
            }

            if (state is RegisterUnverified) {
              // ✅ pass real email — not placeholder "<EMAIL>"
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => BlocProvider(
              //       create: (_) => VerifyEmailCubit(),
              //       child: VerifyEmailScreen(
              //         email: emailCtrl.text.trim(),
              //       ),
              //     ),
              //   ),
              // );
              return;
            }

            if (state is RegisterFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:         Text(state.message),
                  backgroundColor: Colors.red.shade700,
                  behavior:        SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },

          // ── Inner: register state → UI ────────────────────────
          child: BlocBuilder<RegisterCubit, RegisterState>(
            buildWhen: (prev, curr) =>
                curr is RegisterLoading ||
                curr is RegisterSuccess  ||
                curr is RegisterFailed   ||
                curr is RegisterInitial,
            builder: (context, registerState) {
              final cubit = RegisterCubit.get(context);

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
                              SizedBox(height: 20.h),

                              // ── Back button ─────────────────────
                               backButton(c: c),
                              
                              SizedBox(height: 28.h),

                              // ── Brand logo ──────────────────────
                              Center(
                                child: brandLogo(
                                  c:    c,
                                  icon: Icons.person_add_outlined,
                                ),
                              ),
                              SizedBox(height: 28.h),

                              // ── Headline ────────────────────────
                              screenHeadline(
                                title:    'create_account'.tr(),
                                subtitle: 'register_subtitle'.tr(),
                                c:        c,
                              ),
                              SizedBox(height: 36.h),

                              // ── Form card ───────────────────────
                              formCard(
                                surfaceColor: surface,
                                shadowColor:  c.main,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    fieldLabel('name'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller: nameCtrl,
                                      hintText:   'enter_name'.tr(),
                                      prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: c.main),
                                    isBorder:false,
                                      radius:   14,
                                      validator: (v) {
                                        final val = (v ?? '').trim();
                                        if (val.isEmpty) {
                                          return 'name_required'.tr();
                                        }
                                        if (val.length < 2) {
                                          return 'name_too_short'.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20.h),

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
                                    isBorder:false,
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

                                    // Phone
                                    fieldLabel('phone'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller:   phoneCtrl,
                                      hintText:     'enter_phone'.tr(),
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: Icon(
                                          Icons.phone_outlined,
                                          color: c.main),
                                    isBorder:false,
                                      radius:   14,
                                      validator: (v) {
                                        if ((v ?? '').trim().isEmpty) {
                                          return 'phone_required'.tr();
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
                                    isBorder:false,
                                      radius:   14,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'password_is_required'
                                              .tr();
                                        }
                                        if (v.length < 8) {
                                          return 'password_too_short'
                                              .tr();
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 28.h),

                                    // Submit
                                    primaryButton(
                                      label: 'register'.tr(),
                                      loading:
                                          registerState is RegisterLoading,
                                      backgroundColor: c.button,
                                      foregroundColor: c.buttonText,
                                      onPressed: () {
                                        if (!formKey.currentState!
                                            .validate()) return;
                                        // ✅ submit reads from controllers
                                        //    inside cubit — no params needed
                                        cubit.submit();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 28.h),

                              // ── Divider ─────────────────────────
                              orDivider(c: c),
                              SizedBox(height: 28.h),

                              // ── Login CTA ───────────────────────
                              Center(
                                child: authLink(
                                  question:  'have_account'.tr(),
                                  action:    'login'.tr(),
                                  c:     c,
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
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
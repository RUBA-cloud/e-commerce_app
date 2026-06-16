import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/presentation/auth/login_screen.dart';
import 'package:ecommerce_app/presentation/auth/verify_email_screen.dart';

import 'package:ecommerce_app/presentation/widgets/basic_form_filed.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:ecommerce_app/services/login/login_cubit.dart';
import 'package:ecommerce_app/services/register/register_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with UiUtility {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  late RegisterCubit cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cubit = RegisterCubit.get(context);
    cubit.getCountryAndCity();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit(RegisterCubit cubit) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    cubit.submit(
      RegisterRequest(
        name:     _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        phone:    _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        country:  cubit.country,
        city:     cubit.city,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppMainCubit, AppMainState>(
      buildWhen: (prev, curr) =>
      curr is CompanyInfoLoaded || curr is CompanyInfoUpdated,
      builder: (context, companyState) {
        final c       = companyColors(companyState);
        final surface = Theme.of(context).colorScheme.surface;

        return BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterUnverified) {
              navigateTo(
                context: context,
                page: BlocProvider.value(
                  value: RegisterCubit.get(context),
                  child: VerifyEmailScreen(
                    email: _emailCtrl.text.trim(),
                  ),
                ),
              );
              return;
            }
            if (state is EmailAlreadyExist) {
              showSnackBar(context: context, success: false, message: "email_already_exists".tr());
              return;
            }
            if (state is PhoneAlreadyExist) {
              showSnackBar(context: context, success: false, message: "phone_already_exists".tr());
              return;
            }

            if (state is BackToLogin) {
              navigateTo(
                context: context,
                replace: true,
                page: BlocProvider(
                  create: (_) => LoginCubit(),
                  child:  const LoginScreen(),
                ),
              );
              return;
            }
            if (state is RegisterFailed) {
              showSnackBar(context: context, message: state.message, success: false);
            }
          },

          child: BlocBuilder<RegisterCubit, RegisterState>(
            buildWhen: (prev, curr) =>
            curr is RegisterLoading ||
                curr is RegisterSuccess  ||
                curr is RegisterFailed   ||
                curr is RegisterInitial,
            builder: (context, registerState) {
              final cubit     = RegisterCubit.get(context);
              final isLoading = registerState is RegisterLoading;

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
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),

                              backButton(
                                c:     c,
                                onTap: () => cubit.goToLogin(),
                              ),
                              SizedBox(height: 28.h),

                              Center(
                                child: brandLogo(
                                  c:    c,
                                  icon: Icons.person_add_outlined,
                                ),
                              ),
                              SizedBox(height: 28.h),

                              screenHeadline(
                                title:    'create_account'.tr(),
                                subtitle: 'register_subtitle'.tr(),
                                c:        c,
                              ),
                              SizedBox(height: 36.h),

                              formCard(
                                surfaceColor: surface,
                                shadowColor:  c.main,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    fieldLabel('name'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller: _nameCtrl,
                                      hintText:   'enter_name'.tr(),
                                      isBorder:   false,
                                      radius:     14,
                                      prefixIcon: Icon(Icons.person_outline, color: c.main),
                                      validator: (v) {
                                        final val = (v ?? '').trim();
                                        if (val.isEmpty) return 'name_required'.tr();
                                        if (val.length < 2) return 'name_too_short'.tr();
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20.h),

                                    // Email
                                    fieldLabel('email'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller:   _emailCtrl,
                                      hintText:     '${'enter'.tr()} ${'email'.tr()}',
                                      isBorder:     false,
                                      radius:       14,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icon(Icons.email_outlined, color: c.main),
                                      validator: (v) {
                                        final val = (v ?? '').trim();
                                        if (val.isEmpty) return 'email_required'.tr();
                                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val)) {
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
                                      controller:   _phoneCtrl,
                                      hintText:     'enter_phone'.tr(),
                                      isBorder:     false,
                                      radius:       14,
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: Icon(Icons.phone_outlined, color: c.main),
                                      validator:  (v) => cubit.validatePhone(v),
                                    ),
                                    SizedBox(height: 20.h),

                                    // Password
                                    fieldLabel('password'.tr(), c.label),
                                    SizedBox(height: 8.h),
                                    BasicInput(
                                      controller: _passwordCtrl,
                                      hintText:   'enter_password'.tr(),
                                      isBorder:   false,
                                      radius:     14,
                                      isPassword: true,
                                      prefixIcon: Icon(Icons.lock_outline, color: c.main),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'password_is_required'.tr();
                                        if (v.length < 8) return 'password_too_short'.tr();
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 28.h),

                                    // Submit button
                                    primaryButton(
                                      label:           'register'.tr(),
                                      loading:         cubit.state is RegisterLoading,
                                      backgroundColor: c.button,
                                      foregroundColor: c.buttonText,
                                      onPressed: isLoading ? null : () => _submit(cubit),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 28.h),
                              orDivider(c: c),
                              SizedBox(height: 28.h),

                              Center(
                                child: authLink(
                                  question: 'have_account'.tr(),
                                  action:   'login'.tr(),
                                  c:        c,
                                  onTap:    () => cubit.goToLogin(),
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
// forgot_password.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/login/login_cubit.dart';
import 'package:ecommerce_app/services/login/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with UiUtility {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _submitted = false;
  late LoginCubit loginCubit;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }
  @override @override
  void initState() {
    // TODO: implement initState
    loginCubit =LoginCubit.get(context);
    super.initState();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    loginCubit.forgetPassword(
      EmailRequest(email: _emailCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyState = context.watch<CompanyInfoCubit>().state;
    final c            = companyColors(companyState);

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is ForgetPasswordEmailSuccessToSend) {
          setState(() => _submitted = true);
        }

        if (state is ForgetPasswordEmailFailedToSend ||
            state is ForgetPasswordFail) {
          final msg = state is ForgetPasswordFail
              ? state.message
              : 'email_invalid'.tr();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(msg!),
              backgroundColor: Colors.redAccent,
              behavior:        SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final isLoading = state is ForgetPasswordLoading;

          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background ────────────────────────────────────────
                meshBackground(c: c),
                ...backgroundBlobs(c.main),

                // ── Content ───────────────────────────────────────────
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        backButton(c: c),
                        SizedBox(height: 32.h),

                        Center(
                          child: brandLogo(
                            c:    c,
                            icon: Icons.lock_reset_rounded,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        screenHeadline(
                          title:    'forgot_password'.tr(),
                          subtitle: 'forgot_password_subtitle'.tr(),
                          c:        c,
                        ),
                        SizedBox(height: 32.h),

                        // ── Form or Success ──────────────────────────
                        _submitted
                            ? SuccessCard(
                          c:     c,
                          onTap: ()=>loginCubit.resendForgetPassword(EmailRequest(email: _emailCtrl.text.trim())),
                          email: _emailCtrl.text.trim(),
                        )
                            : glassCard(
                          c: c,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                fieldLabel('email'.tr(), c.label),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller:   _emailCtrl,
                                  keyboardType:
                                  TextInputType.emailAddress,
                                  style: TextStyle(
                                      color:    c.text,
                                      fontSize: 14.sp),
                                  decoration: InputDecoration(
                                    hintText: 'enter_email'.tr(),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: c.hint,
                                      size:  20.r,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null ||
                                        v.trim().isEmpty) {
                                      return 'email_required'.tr();
                                    }
                                    final emailRx = RegExp(
                                        r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
                                    if (!emailRx.hasMatch(v.trim())) {
                                      return 'enter_valid_email'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 24.h),
                                primaryButton(
                                  label:           'send_reset_link'.tr(),
                                  onPressed:       isLoading
                                      ? null
                                      : _submit,
                                  backgroundColor: c.button,
                                  foregroundColor: c.buttonText,
                                  loading:         isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),
                        Center(
                          child: authLink(
                            question: 'remember_password'.tr(),
                            action:   'login'.tr(),
                            c:        c,
                            onTap:    () => Navigator.pop(context),
                          ),
                        ),

                        SizedBox(height: 24.h),
                        Center(child: trustBadges(c: c)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
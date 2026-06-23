import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/presentation/home/home_buttom_navigation.dart';

import 'package:ecommerce_app/services/company_info/app_main_cubit.dart';
import 'package:ecommerce_app/services/company_info/app_main_state.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:ecommerce_app/services/register/register_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with UiUtility, TickerProviderStateMixin {

  // ── Resend timer ──────────────────────────────────────────
  static const _resendSeconds = 60;
  int    _secondsLeft = _resendSeconds;
  bool   _canResend   = false;
  Timer? _timer;

  // ── Pulse animation ───────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────
  void _startTimer() {
    _secondsLeft = _resendSeconds;
    _canResend   = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  // ── Resend ────────────────────────────────────────────────
  void _resend(RegisterCubit cubit) {
    _startTimer();
    cubit.resendEmailVerify(email: widget.email);
  }

  // ── Check verification ────────────────────────────────────
  void _checkVerification(RegisterCubit cubit) {
    cubit.checkEmailVerified(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppMainCubit, AppMainState>(
      buildWhen: (p, c) =>
      c is CompanyInfoLoaded || c is CompanyInfoUpdated,
      builder: (context, companyState) {
        final c = companyColors(companyState,context);

        return BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            // ✅ Fixed: navigate to HomeScreen on success
            if (state is  CheckEmailVerifiedSuccess ) {
              if (state is BackToLogin) {
                navigateTo(
                  context: context,
                  replace: true,
                  page: BlocProvider(
                    create: (_) => HomeCubit(),
                    child:  const ButtonHomeNavigationScreen(),
                  ),
                );
                return;
              }
              return;
            }
            if (state is VerifyEmailFailed) {
              showSnackBar(context: context, message: state.message, success: false);
            }
            if (state is RegisterFailed) {
              showSnackBar(context: context, message: state.message, success: false);
            }
            if (state is RegisterUnverified) {
              showSnackBar(
                context: context,
                message: 'email_not_verified_yet'.tr(),
                success: false,
              );
            }
            if (state is VerifyEmailResendSuccess) {
              showSnackBar(context: context, message: 'resend_success'.tr(), success: true);
            }
          },

          child: BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) {
              final cubit        = context.read<RegisterCubit>();
              final isResending  = state is VerifyEmailResendLoading;
              final isChecking   = state is RegisterLoading;

              return Scaffold(
                backgroundColor: c.card,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    meshBackground(c: c),
                    ...backgroundBlobs(c.main),

                    SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.w, vertical: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: backButton(c: c),
                            ),
                            SizedBox(height: 48.h),

                            // ── Pulsing mail icon ──────────────
                            ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                width:  100.r,
                                height: 100.r,
                                decoration: BoxDecoration(
                                  color:        c.main,
                                  borderRadius: BorderRadius.circular(30.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color:      c.main.withOpacity(0.35),
                                      blurRadius: 32,
                                      offset:     const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mark_email_unread_outlined,
                                  color: c.buttonText,
                                  size:  48.r,
                                ),
                              ),
                            ),
                            SizedBox(height: 36.h),

                            // ── Title ──────────────────────────
                            Text(
                              'check_your_email'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:      26.sp,
                                fontWeight:    FontWeight.w800,
                                color:         c.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // ── Subtitle ───────────────────────
                            Text(
                              'verify_email_subtitle'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color:    c.hint,
                                height:   1.6,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // ── Email pill ─────────────────────
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color:        c.main.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: c.main.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.email_outlined,
                                      color: c.main, size: 16.r),
                                  SizedBox(width: 8.w),
                                  Text(
                                    widget.email,
                                    style: TextStyle(
                                      fontSize:   13.sp,
                                      color:      c.main,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.h),

                            // ── Card ───────────────────────────
                            glassCard(
                              c: c,
                              child: Column(
                                children: [
                                  _StepRow(
                                    icon:  Icons.touch_app_outlined,
                                    color: c.main,
                                    hint:  c.hint,
                                    text:  'verify_step_2'.tr(),
                                  ),
                                  SizedBox(height: 28.h),

                                  // ✅ Check Verification button
                                  primaryButton(
                                    label:           'check_verification'.tr(),
                                    loading:         isChecking,
                                    backgroundColor: c.button,
                                    foregroundColor: c.buttonText,
                                    onPressed: isChecking
                                        ? null
                                        : () => _checkVerification(cubit),
                                  ),
                                  SizedBox(height: 16.h),

                                  // ── Resend button / countdown ──
                                  _canResend
                                      ? primaryButton(
                                    label:           'resend_code'.tr(),
                                    loading:         isResending,
                                    backgroundColor: c.main.withOpacity(0.12),
                                    foregroundColor: c.main,
                                    onPressed: isResending
                                        ? null
                                        : () => _resend(cubit),
                                  )
                                      : Column(
                                    children: [
                                      primaryButton(
                                        label:           'resend_code'.tr(),
                                        loading:         false,
                                        backgroundColor: c.main.withOpacity(0.08),
                                        foregroundColor: c.hint,
                                        onPressed:       null,
                                      ),
                                      SizedBox(height: 12.h),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              color:    c.hint),
                                          children: [
                                            TextSpan(
                                                text: '${'resend_in'.tr()} '),
                                            TextSpan(
                                              text: '$_secondsLeft s',
                                              style: TextStyle(
                                                color:      c.main,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 32.h),
                            Center(child: trustBadges(c: c)),
                            SizedBox(height: 24.h),
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
      },
    );
  }
}

// ── Step row ──────────────────────────────────────────────────────────────────
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.color,
    required this.hint,
    required this.text,
  });
  final IconData icon;
  final Color    color;
  final Color    hint;
  final String   text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width:  36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color:  color.withOpacity(0.10),
            shape:  BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 18.r),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color:    hint,
              height:   1.5,
            ),
          ),
        ),
      ],
    );
  }
}
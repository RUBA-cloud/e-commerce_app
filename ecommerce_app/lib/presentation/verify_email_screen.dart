import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/presentation/home_screen.dart';
import 'package:ecommerce_app/services/company_info/company_info_cubit.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:ecommerce_app/services/register/register_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // ── OTP fields ────────────────────────────────────────────
  static const _otpLength = 6;
  final List<TextEditingController> _otpCtrl =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  // ── Resend timer ──────────────────────────────────────────
  static const _resendSeconds = 60;
  int  _secondsLeft  = _resendSeconds;
  bool _canResend    = false;
  Timer? _timer;

  // ── Shake animation ───────────────────────────────────────
  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _shakeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8),   weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0),    weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    for (final c in _otpCtrl)     { c.dispose(); }
    for (final f in _focusNodes)  { f.dispose(); }
    _timer?.cancel();
    _shakeCtrl.dispose();
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

  // ── OTP helpers ───────────────────────────────────────────
  String get _otpValue =>
      _otpCtrl.map((c) => c.text).join();

  bool get _otpComplete =>
      _otpCtrl.every((c) => c.text.isNotEmpty);

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste — distribute across fields
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _otpLength && i < digits.length; i++) {
        _otpCtrl[i].text = digits[i];
      }
      final nextEmpty = _otpCtrl.indexWhere((c) => c.text.isEmpty);
      final focus     = nextEmpty == -1 ? _otpLength - 1 : nextEmpty;
      FocusScope.of(context).requestFocus(_focusNodes[focus]);
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_otpCtrl[index].text.isEmpty && index > 0) {
      _otpCtrl[index - 1].clear();
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      setState(() {});
    }
  }

  void _clearOtp() {
    for (final c in _otpCtrl) { c.clear(); }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    setState(() {});
  }

  // ── Submit ────────────────────────────────────────────────
  void _submit(RegisterCubit cubit) {
    if (!_otpComplete) {
      _shakeCtrl.forward(from: 0);
      return;
    }
    cubit.verify(otp: _otpValue, email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyInfoCubit, CompanyInfoState>(
      buildWhen: (p, c) =>
          c is CompanyInfoLoaded || c is CompanyInfoUpdated,
      builder: (context, companyState) {
        final c       = companyColors(companyState);
        final surface = Theme.of(context).colorScheme.surface;

        return BlocListener<RegisterCubit,  RegisterState>(
          listener: (context, state) {
            if (state is VerifyEmailSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              );
              return;
            }
            if (state is VerifyEmailFailed) {
              _shakeCtrl.forward(from: 0);
              _clearOtp();
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
          child: BlocBuilder<RegisterCubit,   RegisterState>(
            builder: (context, verifyState) {
              final cubit   = context.read<RegisterCubit>();
              final loading = verifyState is RegisterLoading;

              return Scaffold(
                backgroundColor: c.card,
                body: Stack(
                  children: [
                    ...backgroundBlobs(c.main),

                    SafeArea(
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 28.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.h),

                            // ── Back button ───────────────────────
                            backButton(c: c),

                            SizedBox(height: 40.h),

                            // ── Icon ──────────────────────────────
                            Center(
                              child: _MailIcon(color: c.main,
                                  buttonText: c.buttonText),
                            ),
                            SizedBox(height: 28.h),

                            // ── Title ─────────────────────────────
                            Center(
                              child: Text(
                                'verify_email'.tr(),
                                style: TextStyle(
                                  fontSize:      26.sp,
                                  fontWeight:    FontWeight.w800,
                                  color:         c.text,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // ── Subtitle with masked email ─────────
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize:   14.sp,
                                    color:      c.hint,
                                    height:     1.5,
                                  ),
                                  children: [
                                    TextSpan(text: '${'otp_sent_to'.tr()} '),
                                    TextSpan(
                                      text: widget.email,
                                      style: TextStyle(
                                        color:      c.main,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),

                            // ── OTP card ──────────────────────────
                            formCard(
                              surfaceColor: surface,
                              shadowColor:  c.main,
                              child: Column(
                                children: [
                                  // OTP boxes with shake on error
                                  AnimatedBuilder(
                                    animation: _shakeAnim,
                                    builder: (_, child) => Transform.translate(
                                      offset: Offset(_shakeAnim.value, 0),
                                      child: child,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                        _otpLength,
                                        (i) => _OtpBox(
                                          controller:  _otpCtrl[i],
                                          focusNode:   _focusNodes[i],
                                          activeColor: c.main,
                                          textColor:   c.text,
                                          surfaceColor: surface,
                                          isFilled: _otpCtrl[i]
                                              .text
                                              .isNotEmpty,
                                          onChanged: (v) =>
                                              _onOtpChanged(i, v),
                                          onBackspace: () =>
                                              _onBackspace(i),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 28.h),

                                  // Verify button
                                  primaryButton(
                                    label:           'verify'.tr(),
                                    loading:         loading,
                                    backgroundColor: c.button,
                                    foregroundColor: c.buttonText,
                                    onPressed:
                                        loading ? null : () => _submit(cubit),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 28.h),

                            // ── Resend row ────────────────────────
                            Center(
                              child: _canResend
                                  ? GestureDetector(
                                      onTap: () {
                                        _startTimer();
                                        cubit.resendEmailVerify(email: widget.email);
                                      },
                                      child: Text(
                                        'resend_code'.tr(),
                                        style: TextStyle(
                                          fontSize:   14.sp,
                                          color:      c.main,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color:    c.hint,
                                        ),
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
                            ),

                            SizedBox(height: 32.h),
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

class _MailIcon extends StatelessWidget {
  const _MailIcon({required this.color, required this.buttonText});
  final Color color;
  final Color buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  80.r,
      height: 80.r,
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color:      color.withOpacity(0.35),
            blurRadius: 28,
            offset:     const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.mark_email_unread_outlined,
        color: buttonText,
        size:  38.r,
      ),
    );
  }
}

/// Single OTP input box.
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.activeColor,
    required this.textColor,
    required this.surfaceColor,
    required this.isFilled,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode             focusNode;
  final Color                 activeColor;
  final Color                 textColor;
  final Color                 surfaceColor;
  final bool                  isFilled;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onBackspace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  46.w,
      height: 56.h,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextFormField(
          controller:  controller,
          focusNode:   focusNode,
          textAlign:   TextAlign.center,
          maxLength:   1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged:   onChanged,
          style: TextStyle(
            fontSize:   20.sp,
            fontWeight: FontWeight.w800,
            color:      textColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled:      true,
            fillColor: isFilled
                ? activeColor.withOpacity(0.1)
                : surfaceColor,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide:   BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: isFilled
                    ? activeColor.withOpacity(0.6)
                    : activeColor.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide:
                  BorderSide(color: activeColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
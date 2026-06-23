// ============================================================
//  forgot_password_screen.dart
// ============================================================

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/presentation/auth/login_screen.dart';
import 'package:ecommerce_app/presentation/widgets/animated_blob.dart';
import 'package:ecommerce_app/services/company_info/app_main_cubit.dart';
import 'package:ecommerce_app/services/company_info/app_main_state.dart';
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

class _ForgotPasswordState extends State<ForgotPassword>
    with UiUtility, SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _submitted = false;

  late LoginCubit          _cubit;
  late AppMainCubit        _appCubit;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _cubit    = LoginCubit.get(context);
    _appCubit = AppMainCubit.get(context);
    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchLocale(String code) => context.setLocale(Locale(code));

  void _submit() => _cubit.forgetPassword(
      EmailRequest(email: _emailCtrl.text.trim()));

  void _resend() => _cubit.resendForgetPassword(
      EmailRequest(email: _emailCtrl.text.trim()));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppMainCubit, AppMainState>(
      // ✅ rebuild on theme toggle AND company info changes
      buildWhen: (_, s) =>
      s is ThemeChangedState  ||
          s is CompanyInfoLoaded  ||
          s is CompanyInfoUpdated,
      builder: (ctx, companyState) {

        // ✅ isDark from cubit directly — Theme.of() lags one frame
        final isDark = companyState is ThemeChangedState
            ? companyState.isDark
            : _appCubit.isDark;

        // ✅ ThemeChangedState carries no company data —
        //    fall back to last loaded state from cubit,
        //    only when cubit actually has real company data
        final colorState = (companyState is ThemeChangedState)
            ? ((_appCubit.state is CompanyInfoLoaded ||
            _appCubit.state is CompanyInfoUpdated)
            ? _appCubit.state   // ✅ safe — has real company data
            : companyState)     // ✅ no data yet — keep fallback defaults
            : companyState;

        final c    = companyColors(colorState, ctx);
        final r    = c.resolved(isDark);  // ✅ picks dark fields when isDark
        final p    = ColorHelper.fromCompany(c, isDark);
        final isAr = ctx.locale.languageCode == 'ar';

        return AnimatedTheme(
          // ✅ smooth 300ms color transition on theme toggle
          data:     buildTheme(c, brightness: isDark ? Brightness.dark : Brightness.light),
          duration: const Duration(milliseconds: 300),
          child: BlocListener<LoginCubit, LoginState>(
            listener: (ctx2, state) {
              if (state is ForgetPasswordEmailSuccessToSend) {
                setState(() => _submitted = true);
              }
              if (state is ForgetPasswordEmailFailedToSend ||
                  state is ForgetPasswordFail) {
                final msg = state is ForgetPasswordFail
                    ? state.message
                    : 'email_invalid'.tr();
                showSnackBar(
                  context: ctx2,
                  message: msg ?? 'email_invalid'.tr(),
                  success: false,
                );
              }
            },
            child: BlocBuilder<LoginCubit, LoginState>(
              builder: (ctx2, loginState) {
                final isLoading = loginState is ForgetPasswordLoading;

                return Scaffold(
                  backgroundColor: p.bg,
                  body: Stack(
                    children: [

                      // ── Blobs ────────────────────────────────
                      Positioned(
                        top: -80.r, right: -60.r,
                        child: AnimatedBlob(
                          color:    p.primary,
                          size:     320.r,
                          opacity:  isDark ? 0.18 : 0.12,
                          duration: const Duration(seconds: 4),
                        ),
                      ),
                      Positioned(
                        bottom: -100.r, left: -80.r,
                        child: AnimatedBlob(
                          color:    p.blob2,
                          size:     260.r,
                          opacity:  isDark ? 0.14 : 0.09,
                          duration: const Duration(seconds: 5),
                        ),
                      ),

                      // ── Content ──────────────────────────────
                      SafeArea(
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20.h),

                                // ── Top bar ─────────────────────
                                // ✅ uses sharedTopBar with p colors
                                sharedTopBar(
                                  p:              p,
                                  isAr:           isAr,
                                  isDark:         isDark,
                                  onLang:         _switchLocale,
                                  onBack:         () => navigateTo(context: context, page:BlocProvider.value(value: _cubit,child: LoginScreen(),)),
                                  showBackButton: true,
                                ),
                                SizedBox(height: 32.h),

                                // ── Logo ────────────────────────
                                // ✅ uses sharedLogo with resolved r colors
                                Center(
                                  child: sharedLogo(
                                    p:       p,
                                    c:       r,
                                    icon:    Icons.lock_reset_rounded,
                                    appName: 'ShopNow',
                                  ),
                                ),
                                SizedBox(height: 24.h),

                                // ── Headline ────────────────────
                                // ✅ uses sharedHeadline with p colors
                                sharedHeadline(
                                  title:    'forgot_password'.tr(),
                                  subtitle: 'forgot_password_subtitle'.tr(),
                                  p:        p,
                                ),
                                SizedBox(height: 32.h),

                                // ── Form / success card ──────────
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                        opacity: anim,
                                        child:   ScaleTransition(
                                          scale: Tween<double>(
                                              begin: 0.96, end: 1.0)
                                              .animate(anim),
                                          child: child,
                                        ),
                                      ),
                                  child: _submitted
                                      ? _SuccessCard(
                                    key:      const ValueKey('success'),
                                    p:        p,
                                    email:    _emailCtrl.text.trim(),
                                    onResend: _resend,
                                    onBack:   () => Navigator.maybePop(ctx2),
                                  )
                                      : _EmailFormCard(
                                    key:       const ValueKey('form'),
                                    p:         p,
                                    formKey:   _formKey,
                                    emailCtrl: _emailCtrl,
                                    isLoading: isLoading,
                                    onSubmit:  _submit,
                                  ),
                                ),
                                SizedBox(height: 28.h),

                                // ── Back to login link ───────────
                                sharedAuthLinkRow(
                                  question:    'remember_password'.tr(),
                                  actionLabel: 'login'.tr(),
                                  p:           p,
                                  onTap:       () => Navigator.maybePop(ctx2),
                                ),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Loading overlay ──────────────────────
                      // ✅ driven ONLY by LoginCubit — never AppMainCubit
                      if (isLoading) _LoadingOverlay(p: p),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Email form card ───────────────────────────────────────────

class _EmailFormCard extends StatelessWidget with UiUtility {
  final ColorHelper           p;
  final GlobalKey<FormState>  formKey;
  final TextEditingController emailCtrl;
  final bool                  isLoading;
  final VoidCallback          onSubmit;

  const _EmailFormCard({
    super.key,
    required this.p,
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ AnimatedContainer — smooth bg color transition on theme change
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding:    EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color:        p.card,
        borderRadius: BorderRadius.circular(24.r),
        border:       Border.all(color: p.border),
        boxShadow: [
          BoxShadow(
            color:      p.primary.withOpacity(0.07),
            blurRadius: 32,
            offset:     const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            sharedFieldLabel(label: 'email'.tr(), p: p),
            SizedBox(height: 8.h),
            sharedInputField(
              controller:   emailCtrl,
              hintText:     'enter_email'.tr(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon:   Icons.email_outlined,
              p:            p,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'email_required'.tr();
                }
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                    .hasMatch(v.trim())) {
                  return 'enter_valid_email'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 10.h),

            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14.r, color: p.subText),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'reset_link_hint'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    p.subText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            sharedSubmitButton(
              p:       p,
              loading: isLoading,
              label:   'send_reset_link'.tr(),
              onTap:   onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success card ──────────────────────────────────────────────

class _SuccessCard extends StatelessWidget with UiUtility {
  final ColorHelper  p;
  final String       email;
  final VoidCallback onResend;
  final VoidCallback onBack;

  const _SuccessCard({
    super.key,
    required this.p,
    required this.email,
    required this.onResend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ AnimatedContainer — smooth bg color transition on theme change
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding:    EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color:        p.card,
        borderRadius: BorderRadius.circular(24.r),
        border:       Border.all(color: p.border),
        boxShadow: [
          BoxShadow(
            color:      p.primary.withOpacity(0.07),
            blurRadius: 32,
            offset:     const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [

          // ── Icon ──────────────────────────────────────────
          Container(
            width:  68.r, height: 68.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [p.primary, p.blob2],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      p.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset:     const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              color: p.buttonText, size: 32.r,
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            'check_your_email'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:      20.sp,
              fontWeight:    FontWeight.w800,
              color:         p.text,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 8.h),

          Text(
            '${'reset_link_sent_to'.tr()} ',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp,
                color:    p.subText,
                height:   1.5),
          ),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:   13.sp,
              fontWeight: FontWeight.w700,
              color:      p.primary,
            ),
          ),
          SizedBox(height: 28.h),

          // ── Spam hint ────────────────────────────────────
          Container(
            padding:    EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color:        p.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14.r),
              border:       Border.all(color: p.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.inbox_rounded,
                    color: p.primary, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'check_spam_hint'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    p.subText,
                      height:   1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          sharedSubmitButton(
            p:       p,
            loading: false,
            label:   'back_to_login'.tr(),
            onTap:   onBack,
          ),
          SizedBox(height: 14.h),

          GestureDetector(
            onTap: onResend,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded,
                    size: 16.r, color: p.primary),
                SizedBox(width: 6.w),
                Text(
                  'resend_email'.tr(),
                  style: TextStyle(
                    fontSize:   13.sp,
                    color:      p.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading overlay ───────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  final ColorHelper p;
  const _LoadingOverlay({required this.p});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
        width:  72.r, height: 72.r,
        decoration: BoxDecoration(
          color:        p.card,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.12),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
            color:       p.primary,
            strokeWidth: 3,
          ),
        ),
      ),
    ),
  );
}
// ============================================================
//  forgot_password_screen.dart
// ============================================================

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/email_request.dart';
import 'package:ecommerce_app/presentation/widgets/animated_blob.dart';
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
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _cubit    = LoginCubit.get(context);
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
  void _submit()  => _cubit.forgetPassword(
      EmailRequest(email: _emailCtrl.text.trim()));
  void _resend()  => _cubit.resendForgetPassword(
      EmailRequest(email: _emailCtrl.text.trim()));

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final isAr    = context.locale.languageCode == 'ar';

    return BlocListener<LoginCubit, LoginState>(
      listener: (ctx, state) {
        if (state is ForgetPasswordEmailSuccessToSend) {
          setState(() => _submitted = true);
        }
        if (state is ForgetPasswordEmailFailedToSend ||
            state is ForgetPasswordFail) {
          final msg = state is ForgetPasswordFail
              ? state.message
              : 'email_invalid'.tr();
          showSnackBar(
            context: ctx,
            message: msg ?? 'email_invalid'.tr(),
            success: false,
          );
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (ctx, state) {
          final isLoading = state is ForgetPasswordLoading;

          return Scaffold(
            body: Stack(
              children: [

                // ── Blobs ──────────────────────────────────────
                Positioned(
                  top: -80.r, right: -60.r,
                  child: AnimatedBlob(
                    color:    primary,
                    size:     320.r,
                    opacity:  isDark ? 0.18 : 0.12,
                    duration: const Duration(seconds: 4),
                  ),
                ),
                Positioned(
                  bottom: -100.r, left: -80.r,
                  child: AnimatedBlob(
                    color:    cs.secondary,
                    size:     260.r,
                    opacity:  isDark ? 0.14 : 0.09,
                    duration: const Duration(seconds: 5),
                  ),
                ),

                // ── Content ────────────────────────────────────
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

                          // ── Top bar ──────────────────────────
                          _TopBar(
                            isAr:   isAr,
                            onLang: _switchLocale,
                            onBack: () => Navigator.maybePop(ctx),
                          ),
                          SizedBox(height: 32.h),

                          // ── Logo ─────────────────────────────
                          Center(
                            child: _Logo(
                                icon: Icons.lock_reset_rounded),
                          ),
                          SizedBox(height: 24.h),

                          // ── Headline ──────────────────────────
                          _Headline(
                            title:    'forgot_password'.tr(),
                            subtitle: 'forgot_password_subtitle'.tr(),
                          ),
                          SizedBox(height: 32.h),

                          // ── Form / success card ───────────────
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(
                                  opacity: anim,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                        begin: 0.96, end: 1.0)
                                        .animate(anim),
                                    child: child,
                                  ),
                                ),
                            child: _submitted
                                ? _SuccessCard(
                              key:      const ValueKey('success'),
                              email:    _emailCtrl.text.trim(),
                              onResend: _resend,
                              onBack:   () => Navigator.maybePop(ctx),
                            )
                                : _EmailFormCard(
                              key:       const ValueKey('form'),
                              formKey:   _formKey,
                              emailCtrl: _emailCtrl,
                              isLoading: isLoading,
                              onSubmit:  _submit,
                            ),
                          ),
                          SizedBox(height: 28.h),

                          // ── Back to login link ────────────────
                          _AuthLinkRow(
                            question:    'remember_password'.tr(),
                            actionLabel: 'login'.tr(),
                            onTap:       () => Navigator.maybePop(ctx),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Loading overlay ─────────────────────────────
                if (isLoading) const _LoadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool                 isAr;
  final ValueChanged<String> onLang;
  final VoidCallback?        onBack;

  const _TopBar({
    required this.isAr,
    required this.onLang,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        if (onBack != null)
          GestureDetector(
            onTap: onBack,
            child: Container(
              width:  40.r, height: 40.r,
              decoration: BoxDecoration(
                color:        cs.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: cs.outline.withOpacity(0.3)),
              ),
              child: Icon(
                isAr
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: primary, size: 16.r,
              ),
            ),
          ),
        const Spacer(),

        // Language pills
        Container(
          padding:    EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color:        cs.surface,
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(
                color: cs.outline.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              _LangPill(label: 'EN', active: !isAr,
                  onTap: () => onLang('en')),
              SizedBox(width: 4.w),
              _LangPill(label: 'AR', active: isAr,
                  onTap: () => onLang('ar')),
            ],
          ),
        ),
        SizedBox(width: 10.w),

        Container(
          width:  40.r, height: 40.r,
          decoration: BoxDecoration(
            color:        cs.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: cs.outline.withOpacity(0.3)),
          ),
          child: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: primary, size: 20.r,
          ),
        ),
      ],
    );
  }
}

class _LangPill extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;

  const _LangPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color:        active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   13.sp,
            fontWeight: FontWeight.w700,
            color: active
                ? cs.onPrimary
                : cs.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  final IconData icon;
  const _Logo({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return Column(
      children: [
        Container(
          width:  72.r, height: 72.r,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, cs.secondary],
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color:      primary.withOpacity(0.38),
                blurRadius: 20,
                offset:     const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: cs.onPrimary, size: 36.r),
        ),
        SizedBox(height: 10.h),
        Text(
          'ShopNow',
          style: TextStyle(
            fontSize:      20.sp,
            fontWeight:    FontWeight.w800,
            color:         cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ── Headline ──────────────────────────────────────────────────────────────────
class _Headline extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Headline({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize:      26.sp,
            fontWeight:    FontWeight.w800,
            color:         cs.onSurface,
            letterSpacing: -0.8,
            height:        1.2,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width:  48.w, height: 3.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [cs.primary, cs.secondary]),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize:   14.sp,
            color:      cs.onSurface.withOpacity(0.5),
            height:     1.5,
          ),
        ),
      ],
    );
  }
}

// ── Email form card ───────────────────────────────────────────────────────────
class _EmailFormCard extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController emailCtrl;
  final bool                  isLoading;
  final VoidCallback          onSubmit;

  const _EmailFormCard({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return Container(
      padding:    EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(24.r),
        border:       Border.all(color: cs.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color:      primary.withOpacity(0.07),
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
            _FieldLabel(label: 'email'.tr()),
            SizedBox(height: 8.h),
            _InputField(
              controller:   emailCtrl,
              hint:         'enter_email'.tr(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon:   Icons.email_outlined,
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
                    size: 14.r,
                    color: cs.onSurface.withOpacity(0.4)),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'reset_link_hint'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _SubmitButton(
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

// ── Success card ──────────────────────────────────────────────────────────────
class _SuccessCard extends StatelessWidget {
  final String       email;
  final VoidCallback onResend;
  final VoidCallback onBack;

  const _SuccessCard({
    super.key,
    required this.email,
    required this.onResend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return Container(
      padding:    EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(24.r),
        border:       Border.all(color: cs.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color:      primary.withOpacity(0.07),
            blurRadius: 32,
            offset:     const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [

          // ── Icon ────────────────────────────────────────────
          Container(
            width:  68.r, height: 68.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, cs.secondary],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset:     const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              color: cs.onPrimary, size: 32.r,
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            'check_your_email'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:      20.sp,
              fontWeight:    FontWeight.w800,
              color:         cs.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${'reset_link_sent_to'.tr()} ',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp,
                color: cs.onSurface.withOpacity(0.5),
                height: 1.5),
          ),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:   13.sp,
              fontWeight: FontWeight.w700,
              color:      primary,
            ),
          ),
          SizedBox(height: 28.h),

          // ── Spam hint ──────────────────────────────────────
          Container(
            padding:    EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color:        primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                  color: primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.inbox_rounded,
                    color: primary, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'check_spam_hint'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    cs.onSurface.withOpacity(0.5),
                      height:   1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          _SubmitButton(
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
                    size: 16.r, color: primary),
                SizedBox(width: 6.w),
                Text(
                  'resend_email'.tr(),
                  style: TextStyle(
                    fontSize:   13.sp,
                    color:      primary,
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

// ── Auth link row ─────────────────────────────────────────────────────────────
class _AuthLinkRow extends StatelessWidget {
  final String       question;
  final String       actionLabel;
  final VoidCallback onTap;

  const _AuthLinkRow({
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question,
            style: TextStyle(
                fontSize: 14.sp,
                color: cs.onSurface.withOpacity(0.5))),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: TextStyle(
              fontSize:   14.sp,
              color:      cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Loading overlay ───────────────────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Colors.black.withOpacity(0.25),
      child: Center(
        child: Container(
          width:  72.r, height: 72.r,
          decoration: BoxDecoration(
            color:        cs.surface,
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
              color:       cs.primary,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared field label ────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize:      13.sp,
      fontWeight:    FontWeight.w700,
      color:         Theme.of(context).colorScheme.onSurface,
      letterSpacing: 0.2,
    ),
  );
}

// ── Shared input field ────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController       controller;
  final String                      hint;
  final TextInputType               keyboardType;
  final IconData                    prefixIcon;
  final bool                        obscure;
  final Widget?                     suffix;
  final FormFieldValidator<String>? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.prefixIcon,
    this.obscure  = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return TextFormField(
      controller:   controller,
      keyboardType: keyboardType,
      obscureText:  obscure,
      style: TextStyle(fontSize: 14.sp, color: cs.onSurface),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(
            color: cs.onSurface.withOpacity(0.4), fontSize: 14.sp),
        filled:    true,
        fillColor: cs.surfaceContainerHighest,
        prefixIcon: Icon(prefixIcon, color: primary, size: 20.r),
        suffixIcon: suffix,
        contentPadding:
        EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: cs.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: cs.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: cs.error, width: 1.5),
        ),
        errorStyle: TextStyle(
          color:      cs.error,
          fontSize:   11.5.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }
}

// ── Shared submit button ──────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final bool         loading;
  final String       label;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.loading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:    double.infinity,
        height:   52.h,
        decoration: BoxDecoration(
          gradient: loading
              ? null
              : LinearGradient(
            colors: [primary, cs.secondary],
            begin:  Alignment.centerLeft,
            end:    Alignment.centerRight,
          ),
          color:        loading ? primary.withOpacity(0.55) : null,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: loading
              ? []
              : [
            BoxShadow(
              color:      primary.withOpacity(0.38),
              blurRadius: 18,
              offset:     const Offset(0, 7),
            ),
          ],
        ),
        child: loading
            ? Center(
          child: SizedBox(
            width: 22.r, height: 22.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color:       cs.onPrimary,
            ),
          ),
        )
            : Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize:      15.sp,
              fontWeight:    FontWeight.w700,
              color:         cs.onPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================================
//  login_screen.dart
// ============================================================

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/presentation/auth/forgot_password_screen.dart';
import 'package:ecommerce_app/presentation/auth/register_screen.dart';
import 'package:ecommerce_app/presentation/auth/verify_email_screen.dart';
import 'package:ecommerce_app/presentation/home/home_buttom_navigation.dart';
import 'package:ecommerce_app/presentation/widgets/animated_blob.dart';
import 'package:ecommerce_app/services/company_info/app_main_cubit.dart';
import 'package:ecommerce_app/services/company_info/app_main_state.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with UiUtility, SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

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
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchLocale(String code) =>
      EasyLocalization.of(context)!.setLocale(Locale(code));

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    _cubit.submit(
      loginRequest: LoginRequest(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        country:  _cubit.country,
        city:     _cubit.city,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppMainCubit, AppMainState>(
      // ✅ rebuild ONLY on theme toggle or company info —
      //    never on loading/auth states so spinner never appears
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
            listener: _handleState,
            child: Scaffold(
              backgroundColor: p.bg,
              body: Stack(
                children: [

                  // ── Blobs ────────────────────────────────────
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

                  // ── Content ──────────────────────────────────
                  SafeArea(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Form(
                          key:              _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),

                              // ── Top bar ─────────────────────
                              sharedTopBar(
                                p:              p,
                                isAr:           isAr,
                                isDark:         isDark,
                                onLang:         _switchLocale,
                                onBack:         null,
                                showBackButton: false,
                              ),
                              SizedBox(height: 32.h),

                              // ── Logo ────────────────────────
                              // ✅ pass resolved `r` — dark-aware gradient
                              Center(
                                child: sharedLogo(
                                  p:       p,
                                  c:       r,
                                  icon:    Icons.storefront_rounded,
                                  appName: 'ShopNow',
                                ),
                              ),
                              SizedBox(height: 28.h),

                              // ── Headline ────────────────────
                              sharedHeadline(
                                title:    'welcome_back'.tr(),
                                subtitle: 'login_subtitle'.tr(),
                                p:        p,
                              ),
                              SizedBox(height: 32.h),

                              // ── Form card ───────────────────
                              // rebuilds ONLY when obscure toggles
                              BlocBuilder<LoginCubit, LoginState>(
                                buildWhen: (_, s) => s is LoginObscureToggled,
                                builder: (context, state) => _LoginFormCard(
                                  p:            p,
                                  emailCtrl:    _emailCtrl,
                                  passwordCtrl: _passwordCtrl,
                                  obscure:      _cubit.passwordIsObscure,
                                  onTogglePass: _cubit.toggleObscure,
                                  onForgot:     () => _cubit.goToForgotPassword(),
                                  onSubmit:     _onSubmit,
                                ),
                              ),
                              SizedBox(height: 32.h),

                              // ── Or divider ──────────────────
                              sharedOrDivider(p: p),
                              SizedBox(height: 24.h),

                              // ── Register link ───────────────
                              _RegisterRow(
                                p:     p,
                                onTap: () => _cubit.goToRegister(),
                              ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Loading overlay ──────────────────────────
                  // ✅ driven ONLY by LoginCubit — never by AppMainCubit
                  //    so theme changes NEVER trigger the loading spinner
                  BlocBuilder<LoginCubit, LoginState>(
                    buildWhen: (_, s) =>
                    s is LoginLoading ||
                        s is LoginInitial ||
                        s is LoginFailed,
                    builder: (_, s) => s is LoginLoading
                        ? sharedLoadingOverlay(p: p)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleState(BuildContext ctx, LoginState state) {
    if (state is LoginUnverified) {
      navigateTo(
        context: ctx,
        page: BlocProvider(
          create: (_) => RegisterCubit(),
          child: VerifyEmailScreen(email: _emailCtrl.text.trim()),
        ),
      );
      return;
    }
    if (state is LoginSuccess) {
      navigateTo(
        context: ctx,
        replace: true,
        page: BlocProvider(
          create: (_) => HomeCubit(),
          child: const ButtonHomeNavigationScreen(),
        ),
      );
      return;
    }
    if (state is GoToForgotPassword) {
      navigateTo(
        context: ctx,
        page: BlocProvider.value(
          value: _cubit,
          child: const ForgotPassword(),
        ),
      );
      return;
    }
    if (state is GoToRegister) {
      navigateTo(
        context: ctx,
        page: BlocProvider(
          create: (_) => RegisterCubit(),
          child: const RegisterScreen(),
        ),
      );
      return;
    }
    if (state is LoginFailed) {
      showSnackBar(
        context: ctx,
        message: state.message ?? 'something_went_wrong'.tr(),
        success: false,
      );
    }
  }
}

// ── Login form card ───────────────────────────────────────────

class _LoginFormCard extends StatelessWidget with UiUtility {
  const _LoginFormCard({
    required this.p,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onTogglePass,
    required this.onForgot,
    required this.onSubmit,
  });

  final ColorHelper           p;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool                  obscure;
  final VoidCallback          onTogglePass;
  final VoidCallback          onForgot;
  final VoidCallback          onSubmit;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Email ──────────────────────────────────────
          sharedFieldLabel(label: 'email'.tr(), p: p),
          SizedBox(height: 8.h),
          sharedInputField(
            controller:   emailCtrl,
            hintText:     'enter_email'.tr(),
            keyboardType: TextInputType.emailAddress,
            prefixIcon:   Icons.email_outlined,
            p:            p,
            validator: (v) {
              final val = (v ?? '').trim();
              if (val.isEmpty) return 'email_required'.tr();
              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(val)) {
                return 'enter_valid_email'.tr();
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),

          // ── Password ───────────────────────────────────
          sharedFieldLabel(label: 'password'.tr(), p: p),
          SizedBox(height: 8.h),
          sharedInputField(
            controller: passwordCtrl,
            hintText:   'enter_password'.tr(),
            prefixIcon: Icons.lock_outline_rounded,
            obscure:    obscure,
            p:          p,
            suffix: GestureDetector(
              onTap: onTogglePass,
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: p.subText,
                  size:  20.r,
                ),
              ),
            ),
            validator: (v) =>
            (v == null || v.isEmpty) ? 'password_is_required'.tr() : null,
          ),
          SizedBox(height: 10.h),

          // ── Forgot password ────────────────────────────
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onForgot,
              style: TextButton.styleFrom(
                padding:       EdgeInsets.zero,
                minimumSize:   Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'forgot_password'.tr(),
                style: TextStyle(
                  fontSize:   13.sp,
                  color:      p.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // ── Submit ─────────────────────────────────────
          BlocBuilder<LoginCubit, LoginState>(
            buildWhen: (_, s) =>
            s is LoginLoading ||
                s is LoginInitial ||
                s is LoginFailed  ||
                s is LoginSuccess,
            builder: (_, state) => sharedSubmitButton(
              p:       p,
              loading: state is LoginLoading,
              label:   'login'.tr(),
              onTap:   onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Register row ──────────────────────────────────────────────

class _RegisterRow extends StatelessWidget {
  const _RegisterRow({required this.p, required this.onTap});

  final ColorHelper  p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'no_account'.tr(),
        style: TextStyle(fontSize: 14.sp, color: p.subText),
      ),
      SizedBox(width: 4.w),
      GestureDetector(
        onTap: onTap,
        child: Text(
          'register'.tr(),
          style: TextStyle(
            fontSize:   14.sp,
            color:      p.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
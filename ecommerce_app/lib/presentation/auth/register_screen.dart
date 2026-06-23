// ============================================================
//  register_screen.dart
// ============================================================

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/register_request.dart';
import 'package:ecommerce_app/presentation/auth/login_screen.dart';
import 'package:ecommerce_app/presentation/auth/verify_email_screen.dart';
import 'package:ecommerce_app/presentation/widgets/animated_blob.dart';
import 'package:ecommerce_app/services/company_info/app_main_cubit.dart';
import 'package:ecommerce_app/services/company_info/app_main_state.dart';
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

class _RegisterScreenState extends State<RegisterScreen>
    with UiUtility, SingleTickerProviderStateMixin {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  bool _obscure = true;

  late RegisterCubit       _cubit;
  late AppMainCubit        _appCubit;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _appCubit = AppMainCubit.get(context);
    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = RegisterCubit.get(context);
    _cubit.getCountryAndCity();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _cubit.submit(
      RegisterRequest(
        name:     _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        phone:    _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        country:  _cubit.country,
        city:     _cubit.city,
      ),
    );
  }

  void _switchLocale(String code) => context.setLocale(Locale(code));

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
          child: BlocListener<RegisterCubit, RegisterState>(
            listener: (ctx2, state) => _handleState(ctx2, state),
            child: Scaffold(
              backgroundColor: p.bg,
              body: Stack(
                children: [

                  // ── Blobs ──────────────────────────────────
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

                  // ── Content ────────────────────────────────
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

                              // ── Top bar ───────────────────
                              sharedTopBar(
                                p:              p,
                                isAr:           isAr,
                                isDark:         isDark,
                                onLang:         _switchLocale,
                                onBack:         () => navigateTo(context: context, page:BlocProvider(create: (_)=>LoginCubit(),child: LoginScreen(),)),
                                showBackButton: true,
                              ),
                              SizedBox(height: 28.h),

                              // ── Logo ──────────────────────
                              // ✅ pass resolved `r` — dark-aware gradient
                              Center(
                                child: sharedLogo(
                                  p:       p,
                                  c:       r,
                                  icon:    Icons.person_add_outlined,
                                  appName: 'ShopNow',
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // ── Headline ──────────────────
                              sharedHeadline(
                                title:    'create_account'.tr(),
                                subtitle: 'register_subtitle'.tr(),
                                p:        p,
                              ),
                              SizedBox(height: 28.h),

                              // ── Form card ─────────────────
                              _RegisterFormCard(
                                p:            p,
                                nameCtrl:     _nameCtrl,
                                emailCtrl:    _emailCtrl,
                                phoneCtrl:    _phoneCtrl,
                                passwordCtrl: _passwordCtrl,
                                obscure:      _obscure,
                                onTogglePass: () =>
                                    setState(() => _obscure = !_obscure),
                                cubit:    _cubit,
                                onSubmit: _submit,
                              ),
                              SizedBox(height: 28.h),

                              // ── Or divider ────────────────
                              sharedOrDivider(p: p),
                              SizedBox(height: 20.h),

                              // ── Login link ────────────────
                              sharedAuthLinkRow(
                                question:    'have_account'.tr(),
                                actionLabel: 'login'.tr(),
                                p:           p,
                                onTap:       () => _cubit.goToLogin(),
                              ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Loading overlay ────────────────────────
                  // ✅ driven ONLY by RegisterCubit — never AppMainCubit
                  //    so theme changes never trigger the spinner
                  BlocBuilder<RegisterCubit, RegisterState>(
                    buildWhen: (_, s) =>
                    s is RegisterLoading ||
                        s is RegisterInitial  ||
                        s is RegisterFailed,
                    builder: (_, s) => s is RegisterLoading
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

  void _handleState(BuildContext ctx, RegisterState state) {
    if (state is RegisterUnverified) {
      navigateTo(
        context: ctx,
        page: BlocProvider.value(
          value: _cubit,
          child: VerifyEmailScreen(email: _emailCtrl.text.trim()),
        ),
      );
      return;
    }
    if (state is EmailAlreadyExist) {
      showSnackBar(
          context: ctx, success: false,
          message: 'email_already_exists'.tr());
      return;
    }
    if (state is PhoneAlreadyExist) {
      showSnackBar(
          context: ctx, success: false,
          message: 'phone_already_exists'.tr());
      return;
    }
    if (state is BackToLogin) {
      navigateTo(
        context: ctx,
        replace: true,
        page: BlocProvider(
          create: (_) => LoginCubit(),
          child:  const LoginScreen(),
        ),
      );
      return;
    }
    if (state is RegisterFailed) {
      showSnackBar(context: ctx, message: state.message, success: false);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Register form card
// ─────────────────────────────────────────────────────────────
class _RegisterFormCard extends StatelessWidget with UiUtility {
  final ColorHelper           p;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final bool                  obscure;
  final VoidCallback          onTogglePass;
  final RegisterCubit         cubit;
  final VoidCallback          onSubmit;

  const _RegisterFormCard({
    required this.p,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onTogglePass,
    required this.cubit,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Name ────────────────────────────────────────
          sharedFieldLabel(label: 'name'.tr(), p: p),
          SizedBox(height: 8.h),
          sharedInputField(
            controller: nameCtrl,
            hintText:   'enter_name'.tr(),
            prefixIcon: Icons.person_outline,
            p:          p,
            validator: (v) {
              final val = (v ?? '').trim();
              if (val.isEmpty)    return 'name_required'.tr();
              if (val.length < 2) return 'name_too_short'.tr();
              return null;
            },
          ),
          SizedBox(height: 18.h),

          // ── Email ────────────────────────────────────────
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

          // ── Phone ────────────────────────────────────────
          sharedFieldLabel(label: 'phone'.tr(), p: p),
          SizedBox(height: 8.h),
          sharedInputField(
            controller:   phoneCtrl,
            hintText:     'enter_phone'.tr(),
            keyboardType: TextInputType.phone,
            prefixIcon:   Icons.phone_outlined,
            p:            p,
            validator:    (v) => cubit.validatePhone(v),
          ),
          SizedBox(height: 18.h),

          // ── Password ─────────────────────────────────────
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
            validator: (v) {
              if (v == null || v.isEmpty) return 'password_is_required'.tr();
              if (v.length < 8)           return 'password_too_short'.tr();
              return null;
            },
          ),
          SizedBox(height: 28.h),

          // ── Submit ───────────────────────────────────────
          BlocBuilder<RegisterCubit, RegisterState>(
            buildWhen: (_, s) =>
            s is RegisterLoading ||
                s is RegisterInitial  ||
                s is RegisterFailed   ||
                s is RegisterSuccess,
            builder: (_, state) => sharedSubmitButton(
              p:       p,
              loading: state is RegisterLoading,
              label:   'register'.tr(),
              onTap:   onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
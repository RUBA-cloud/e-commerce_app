// lib/presentation/screens/change_password_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/data/model/request/profile/change_password_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ecommerce_app/services/profile/profile_cubit.dart';
import 'package:ecommerce_app/services/profile/profile_state.dart';

// ─────────────────────────────────────────────────────────────
// Screen  — zero setState calls, all state lives in ProfileCubit
// ─────────────────────────────────────────────────────────────
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late ProfileCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl     = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit.get(context);
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _cubit.submitChangePassword(
      ChangePasswordRequest(
        currentPassword:      _currentPasswordCtrl.text.trim(),
        password:             _newPasswordCtrl.text.trim(),
        passwordConfirmation: _confirmPasswordCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final cs   = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (_, state) {
          if (state is ChangePasswordUpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:         Text('password_changed'.tr()),
                backgroundColor: Colors.green.shade600,
                behavior:        SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            );
            Navigator.maybePop(context);
          }
          if (state is ChangePasswordUpdateFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:         Text(state.message ?? 'something_went_wrong'.tr()),
                backgroundColor: cs.error,
                behavior:        SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            );
          }
        },
        // ── BlocBuilder rebuilds the whole screen on any state ──
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {

            // ── Derive UI values from state ──────────────────
            final isLoading = state is ChangePasswordLoadingState;

            // visibility — from ChangePasswordVisibilityState,
            // fall back to false on all other states
            final bool showCurrent = state is ChangePasswordVisibilityState
                ? state.showCurrent : false;
            final bool showNew     = state is ChangePasswordVisibilityState
                ? state.showNew     : false;
            final bool showConfirm = state is ChangePasswordVisibilityState
                ? state.showConfirm : false;

            // strength — only present when ChangePasswordStrengthState
            final double  strength = state is ChangePasswordStrengthState
                ? state.strength : 0;
            final String  strengthLabel = state is ChangePasswordStrengthState
                ? state.label    : '';
            final Color   strengthColor = state is ChangePasswordStrengthState
                ? state.color    : Colors.transparent;
            final String  strengthPwd   = state is ChangePasswordStrengthState
                ? state.password : '';

            return Column(
              children: [
                // ── App bar ────────────────────────────────
                _AppBar(
                  isAr:      isAr,
                  onSave:    isLoading ? null : _save,
                  isLoading: isLoading,
                ),

                // ── Form ───────────────────────────────────
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 40.h),
                      children: [
                        _InfoBanner(),
                        SizedBox(height: 20.h),

                        _SectionCard(
                          icon:  Icons.lock_outline_rounded,
                          title: 'change_password'.tr(),
                          children: [

                            // Current password
                            _PasswordField(
                              ctrl:         _currentPasswordCtrl,
                              label:        'current_password'.tr(),
                              showPassword: showCurrent,
                              onToggle:     _cubit.toggleCurrentPasswordVisibility,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'field_required'.tr();
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 14.h),

                            // New password
                            _PasswordField(
                              ctrl:         _newPasswordCtrl,
                              label:        'new_password'.tr(),
                              showPassword: showNew,
                              onToggle:     _cubit.toggleNewPasswordVisibility,
                              onChanged:    _cubit.evaluatePasswordStrength,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'field_required'.tr();
                                }
                                if (v.trim().length < 8) {
                                  return 'password_min_length'.tr();
                                }
                                if (v.trim() == _currentPasswordCtrl.text.trim()) {
                                  return 'password_same_as_current'.tr();
                                }
                                return null;
                              },
                            ),

                            // Strength bar
                            if (strength > 0) ...[
                              SizedBox(height: 10.h),
                              _StrengthBar(
                                strength: strength,
                                label:    strengthLabel,
                                color:    strengthColor,
                                password: strengthPwd,
                              ),
                            ],

                            SizedBox(height: 14.h),

                            // Confirm password
                            _PasswordField(
                              ctrl:         _confirmPasswordCtrl,
                              label:        'confirm_password'.tr(),
                              showPassword: showConfirm,
                              onToggle:     _cubit.toggleConfirmPasswordVisibility,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'field_required'.tr();
                                }
                                if (v.trim() != _newPasswordCtrl.text.trim()) {
                                  return 'passwords_do_not_match'.tr();
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 28.h),
                        _SaveButton(isLoading: isLoading, onTap: _save),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Info Banner
// ─────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border:       Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width:  40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color:        primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.lock_person_outlined, size: 20.r, color: primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'update_your_password'.tr(),
                  style: TextStyle(
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w700,
                    color:      cs.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'password_tip'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:    cs.onSurface.withOpacity(0.55),
                    height:   1.4,
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

// ─────────────────────────────────────────────────────────────
// Custom App Bar
// ─────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final bool          isAr;
  final VoidCallback? onSave;
  final bool          isLoading;

  const _AppBar({
    required this.isAr,
    required this.onSave,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color:   cs.surface,
      padding: EdgeInsets.only(top: top),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Row(
              children: [
                _IconBtn(
                  icon:  isAr
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'change_password'.tr(),
                    style: TextStyle(
                      fontSize:      18.sp,
                      fontWeight:    FontWeight.w700,
                      color:         cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSave,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isLoading
                          ? cs.primary.withOpacity(0.50)
                          : cs.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: isLoading
                        ? SizedBox(
                      width:  15.r,
                      height: 15.r,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: cs.onPrimary),
                    )
                        : Text(
                      'save'.tr(),
                      style: TextStyle(
                        fontSize:   13.sp,
                        fontWeight: FontWeight.w700,
                        color:      cs.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1,
              color: cs.outline.withOpacity(0.10)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color:        cs.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: cs.primary.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 15.r, color: cs.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section card
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final List<Widget> children;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return Container(
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color:      primary.withOpacity(0.06),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topCenter,
                    end:    Alignment.bottomCenter,
                    colors: [primary, primary.withOpacity(0.6)],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width:  32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color:        primary.withOpacity(0.09),
                              borderRadius: BorderRadius.circular(9.r),
                            ),
                            child: Icon(icon, size: 16.r, color: primary),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize:   14.sp,
                              fontWeight: FontWeight.w700,
                              color:      cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Container(height: 1, color: cs.outline.withOpacity(0.10)),
                      SizedBox(height: 16.h),
                      ...children,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Password field
// ─────────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController      ctrl;
  final String                     label;
  final bool                       showPassword;
  final VoidCallback               onToggle;
  final ValueChanged<String>?      onChanged;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.ctrl,
    required this.label,
    required this.showPassword,
    required this.onToggle,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return TextFormField(
      controller:  ctrl,
      obscureText: !showPassword,
      onChanged:   onChanged,
      validator:   validator,
      style: TextStyle(fontSize: 13.sp, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12.sp,
          color:    cs.onSurface.withOpacity(0.55),
        ),
        floatingLabelStyle: TextStyle(
          fontSize:   12.sp,
          color:      primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Icon(Icons.lock_outline_rounded,
              size: 17.r, color: primary.withOpacity(0.75)),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 44.w),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size:  18.r,
              color: cs.onSurface.withOpacity(0.40),
            ),
          ),
        ),
        filled:    true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.45),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.outline.withOpacity(0.20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.outline.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.error, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Strength bar
// ─────────────────────────────────────────────────────────────
class _StrengthBar extends StatelessWidget {
  final double strength;
  final String label;
  final Color  color;
  final String password;

  const _StrengthBar({
    required this.strength,
    required this.label,
    required this.color,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'password_strength'.tr(),
              style: TextStyle(
                fontSize:   11.sp,
                color:      cs.onSurface.withOpacity(0.50),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label.tr(),
              style: TextStyle(
                fontSize:   11.sp,
                color:      color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value:           strength,
            minHeight:       5,
            backgroundColor: cs.outline.withOpacity(0.15),
            valueColor:      AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _Hint(met: password.length >= 8,                text: '8+ chars'),
            SizedBox(width: 8.w),
            _Hint(met: RegExp(r'[A-Z]').hasMatch(password), text: 'A–Z'),
            SizedBox(width: 8.w),
            _Hint(met: RegExp(r'[0-9]').hasMatch(password), text: '0–9'),
            SizedBox(width: 8.w),
            _Hint(
              met:  RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password),
              text: '#@!',
            ),
          ],
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  final bool   met;
  final String text;
  const _Hint({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = met
        ? const Color(0xFF43A047)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.30);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size:  12.r,
          color: color,
        ),
        SizedBox(width: 3.w),
        Text(
          text,
          style: TextStyle(
            fontSize:   10.sp,
            color:      color,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Save button
// ─────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool         isLoading;
  final VoidCallback onTap;
  const _SaveButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height:   50.h,
        decoration: BoxDecoration(
          color: isLoading
              ? cs.primary.withOpacity(0.55)
              : cs.primary,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: isLoading
              ? []
              : [
            BoxShadow(
              color:      cs.primary.withOpacity(0.30),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
            width:  22.r,
            height: 22.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color:       cs.onPrimary,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_reset_rounded,
                  size: 18.r, color: cs.onPrimary),
              SizedBox(width: 8.w),
              Text(
                'update_password'.tr(),
                style: TextStyle(
                  fontSize:   15.sp,
                  fontWeight: FontWeight.w700,
                  color:      cs.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
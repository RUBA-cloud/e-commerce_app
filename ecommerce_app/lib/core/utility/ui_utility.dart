import 'dart:math' as math;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:flutter_screenutil/flutter_screenutil.dart';

mixin UiUtility {

  // ════════════════════════════════════════════════════════════════
  // COLOR HELPERS
  // ════════════════════════════════════════════════════════════════

  Color hexColor(String? hex, [String fallback = '#1D5D9B']) {
    try {
      final raw =
      (hex?.isNotEmpty == true ? hex! : fallback).replaceAll('#', '');
      return Color(int.parse('FF$raw', radix: 16));
    } catch (_) {
      final raw = fallback.replaceAll('#', '');
      return Color(int.parse('FF$raw', radix: 16));
    }
  }

  void navigateTo({
    required BuildContext context,
    required Widget page,
    bool replace = false,
  }) {
    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // COMPANY INFO
  // ════════════════════════════════════════════════════════════════

  CompanyColors companyColors(AppMainState state) {
    final company = state is CompanyInfoLoaded
        ? state.company.company
        : state is CompanyInfoUpdated
        ? state.company.company
        : null;

    return CompanyColors(
      main:       hexColor(company?.mainColor,       '#1D5D9B'),
      sub:        hexColor(company?.subColor,        '#1D5D9B'),
      button:     hexColor(company?.buttonColor,     '#1D5D9B'),
      buttonText: hexColor(company?.buttonTextColor, '#FFFFFF'),
      text:       hexColor(company?.textColor,       '#1A1A2E'),
      hint:       hexColor(company?.hintColor,       '#9E9E9E'),
      card:       hexColor(company?.cardColor,       '#F5F5F5'),
      label:      hexColor(company?.labelColor,      '#1A1A2E'),
      textField:  hexColor(company?.textFiledColor,  '#F5F5F5'),
      icon:       hexColor(company?.iconColor,       '#1D5D9B'),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // THEME BUILDER
  // ════════════════════════════════════════════════════════════════

  ThemeData buildTheme(CompanyColors c,
      {Brightness brightness = Brightness.light}) {
    return ThemeData(
      useMaterial3: true,
      brightness:   brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor:  c.main,
        brightness: brightness,
        primary:    c.main,
        secondary:  c.sub,
        surface:    c.card,
      ),
      scaffoldBackgroundColor: c.card,
      appBarTheme: AppBarTheme(
        backgroundColor: c.main,
        foregroundColor: c.buttonText,
        iconTheme:       IconThemeData(color: c.icon),
        titleTextStyle:  TextStyle(
            color: c.buttonText, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.button,
          foregroundColor: c.buttonText,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:     true,
        fillColor:  c.textField,
        hintStyle:  TextStyle(color: c.hint),
        labelStyle: TextStyle(color: c.label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   BorderSide(color: c.sub),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   BorderSide(color: c.sub),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   BorderSide(color: c.main, width: 2),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge:   TextStyle(color: c.text),
        bodyMedium:  TextStyle(color: c.text),
        bodySmall:   TextStyle(color: c.text),
        labelLarge:  TextStyle(color: c.label),
        labelMedium: TextStyle(color: c.label),
        titleLarge:  TextStyle(color: c.text),
        titleMedium: TextStyle(color: c.text),
      ),
      iconTheme: IconThemeData(color: c.icon),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BASE WIDGETS
  // ════════════════════════════════════════════════════════════════

  Widget fieldLabel(String text, Color color) =>
      _FieldLabel(text: text, color: color);

  Widget blob({required double size, required Color color}) =>
      _Blob(size: size, color: color);

  Widget primaryButton({
    required String        label,
    required VoidCallback? onPressed,
    required Color         backgroundColor,
    required Color         foregroundColor,
    bool   loading = false,
    double height  = 54,
    double radius  = 14,
  }) =>
      _PrimaryButton(
        label:           label,
        onPressed:       onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        loading:         loading,
        height:          height,
        radius:          radius,
      );

  Widget formCard({
    required Widget child,
    required Color  surfaceColor,
    required Color  shadowColor,
    double padding = 24,
    double radius  = 24,
  }) =>
      _FormCard(
        child:        child,
        surfaceColor: surfaceColor,
        shadowColor:  shadowColor,
        padding:      padding,
        radius:       radius,
      );

  List<Widget> backgroundBlobs(Color primary) => [
    Positioned(
      top: -80.r, right: -60.r,
      child: blob(size: 260.r, color: primary.withOpacity(0.12)),
    ),
    Positioned(
      top: 60.r, right: 40.r,
      child: blob(size: 100.r, color: primary.withOpacity(0.07)),
    ),
    Positioned(
      bottom: -100.r, left: -80.r,
      child: blob(size: 300.r, color: primary.withOpacity(0.08)),
    ),
  ];

  // ════════════════════════════════════════════════════════════════
  // AUTH WIDGETS — delegates to top-level widget classes
  // ════════════════════════════════════════════════════════════════

  Widget brandLogo({
    required CompanyColors c,
    IconData icon = Icons.shopping_bag_outlined,
  }) =>
      _AnimatedBrandLogo(c: c, icon: icon);

  Widget screenHeadline({
    required String        title,
    required String        subtitle,
    required CompanyColors c,
  }) =>
      _ScreenHeadline(title: title, subtitle: subtitle, c: c);

  Widget orDivider({required CompanyColors c}) => _OrDivider(c: c);

  // FIX: backButton was inlined with widget/context/animation references
  // that don't exist in a mixin — replaced with delegation to _AuthBackButton
  Widget backButton({
    required CompanyColors c,
    VoidCallback?          onTap,
  }) =>
      _AuthBackButton(color: c.main, onTap: onTap);

  // FIX: authLink now delegates to AuthLink (public top-level widget)
  Widget authLink({
    required String        question,
    required String        action,
    required CompanyColors c,
    required VoidCallback  onTap,
  }) =>
      AuthLink(
        question:  question,
        action:    action,
        color:     c.main,
        hintColor: c.hint,
        onTap:     onTap,
      );

  Widget stepBadge({
    required int           step,
    required int           total,
    required CompanyColors c,
  }) =>
      _StepBadge(step: step, total: total, color: c.main);

  Widget sectionDivider({
    required CompanyColors c,
    String?    label,
    TextStyle? labelStyle,
  }) =>
      _SectionDivider(color: c.sub, label: label, labelStyle: labelStyle);

  Widget infoChip({
    required String        label,
    required IconData      icon,
    required CompanyColors c,
  }) =>
      _InfoChip(label: label, icon: icon, color: c.main);

  Widget meshBackground({required CompanyColors c}) => _MeshBackground(c: c);

  Widget glassCard({
    required Widget        child,
    required CompanyColors c,
    double padding = 24,
    double radius  = 28,
  }) =>
      _GlassCard(child: child, c: c, padding: padding, radius: radius);

  Widget shimmerText({
    required String        text,
    required CompanyColors c,
    double     fontSize = 14,
    FontWeight weight   = FontWeight.w600,
  }) =>
      _ShimmerText(text: text, c: c, fontSize: fontSize, weight: weight);

  Widget stepProgress({
    required int           current,
    required int           total,
    required CompanyColors c,
  }) =>
      _StepProgress(current: current, total: total, c: c);

  Widget hexBackground({required Color color}) => _HexBackground(color: color);

  Widget trustBadges({required CompanyColors c}) => _TrustBadges(c: c);

  // FIX: successCard now delegates to SuccessCard (public top-level widget)
  Widget successCard({
    required CompanyColors c,
    required String        email,
    required VoidCallback  onTap,
  }) =>
      SuccessCard(c: c, email: email, onTap: onTap);
}

// ════════════════════════════════════════════════════════════════════════════
// DATA CLASS
// ════════════════════════════════════════════════════════════════════════════

class CompanyColors {
  final Color main;
  final Color sub;
  final Color button;
  final Color buttonText;
  final Color text;
  final Color hint;
  final Color card;
  final Color label;
  final Color textField;
  final Color icon;

  const CompanyColors({
    required this.main,
    required this.sub,
    required this.button,
    required this.buttonText,
    required this.text,
    required this.hint,
    required this.card,
    required this.label,
    required this.textField,
    required this.icon,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// PRIVATE SUB-WIDGETS  (file-private, used only by the mixin above)
// ════════════════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.color});
  final String text;
  final Color  color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize:      13.sp,
      fontWeight:    FontWeight.w600,
      color:         color,
      letterSpacing: 0.2,
    ),
  );
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
    width:  size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ── Primary Button ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.loading,
    required this.height,
    required this.radius,
  });

  final String        label;
  final VoidCallback? onPressed;
  final Color         backgroundColor;
  final Color         foregroundColor;
  final bool          loading;
  final double        height;
  final double        radius;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onPressed?.call(); },
      onTapCancel: ()  => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width:  double.infinity,
          height: widget.height.h,
          decoration: BoxDecoration(
            gradient: widget.loading
                ? null
                : LinearGradient(
              colors: [
                widget.backgroundColor,
                Color.lerp(widget.backgroundColor, Colors.white, 0.15)!,
              ],
              begin: Alignment.centerLeft,
              end:   Alignment.centerRight,
            ),
            color: widget.loading
                ? widget.backgroundColor.withOpacity(0.6)
                : null,
            borderRadius: BorderRadius.circular(widget.radius.r),
            boxShadow: widget.loading
                ? []
                : [
              BoxShadow(
                color:      widget.backgroundColor.withOpacity(0.38),
                blurRadius: 20,
                offset:     const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? SizedBox(
            width:  22,
            height: 22,
            child: CircularProgressIndicator(
                color: widget.foregroundColor, strokeWidth: 2.5),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize:      16.sp,
                  fontWeight:    FontWeight.w700,
                  color:         widget.foregroundColor,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.arrow_forward_rounded,
                  color: widget.foregroundColor, size: 18.r),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.child,
    required this.surfaceColor,
    required this.shadowColor,
    required this.padding,
    required this.radius,
  });

  final Widget child;
  final Color  surfaceColor;
  final Color  shadowColor;
  final double padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding.r),
    decoration: BoxDecoration(
      color:        surfaceColor,
      borderRadius: BorderRadius.circular(radius.r),
      border: Border.all(
          color: shadowColor.withOpacity(0.08), width: 1.2),
      boxShadow: [
        BoxShadow(
          color:      shadowColor.withOpacity(0.06),
          blurRadius: 32,
          offset:     const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

// ════════════════════════════════════════════════════════════════════════════
// AUTH WIDGETS — private implementations
// ════════════════════════════════════════════════════════════════════════════

// ── Animated Brand Logo ──────────────────────────────────────────────────────

class _AnimatedBrandLogo extends StatefulWidget {
  const _AnimatedBrandLogo({required this.c, required this.icon});
  final CompanyColors c;
  final IconData      icon;

  @override
  State<_AnimatedBrandLogo> createState() => _AnimatedBrandLogoState();
}

class _AnimatedBrandLogoState extends State<_AnimatedBrandLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width:  (72 + 24 * _pulse.value).r,
            height: (72 + 24 * _pulse.value).r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.c.main.withOpacity(0.08 * _pulse.value),
            ),
          ),
          Container(
            width:  (72 + 10 * _pulse.value).r,
            height: (72 + 10 * _pulse.value).r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.c.main.withOpacity(0.12 * _pulse.value),
            ),
          ),
          child!,
        ],
      ),
      child: Container(
        width:  72.r,
        height: 72.r,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.c.main,
              Color.lerp(widget.c.main, widget.c.sub, 0.5)!,
            ],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color:      widget.c.main.withOpacity(0.4),
              blurRadius: 24,
              offset:     const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(widget.icon, color: widget.c.buttonText, size: 34.r),
      ),
    );
  }
}

// ── Screen Headline ──────────────────────────────────────────────────────────

class _ScreenHeadline extends StatelessWidget {
  const _ScreenHeadline({
    required this.title,
    required this.subtitle,
    required this.c,
  });
  final String        title;
  final String        subtitle;
  final CompanyColors c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:      28.sp,
              fontWeight:    FontWeight.w800,
              color:         c.text,
              letterSpacing: -0.5,
              height:        1.2,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: Container(
            width:  48.w,
            height: 3.h,
            decoration: BoxDecoration(
              gradient:     LinearGradient(colors: [c.main, c.sub]),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:   14.sp,
              color:      c.hint,
              fontWeight: FontWeight.w400,
              height:     1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Or Divider ────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.c});
  final CompanyColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, c.sub.withOpacity(0.3)]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color:        c.main.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: c.main.withOpacity(0.15), width: 1),
            ),
            child: Text(
              'or',
              style: TextStyle(
                  fontSize: 12.sp,
                  color:    c.hint,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [c.sub.withOpacity(0.3), Colors.transparent]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Back Button ───────────────────────────────────────────────────────────────
// FIX: was inlined inside the mixin using widget/context/_ctrl/_scale which
// don't exist there. Now a proper StatefulWidget with its own animation state.

class _AuthBackButton extends StatefulWidget {
  const _AuthBackButton({required this.color, this.onTap});
  final Color        color;
  final VoidCallback? onTap;

  @override
  State<_AuthBackButton> createState() => _AuthBackButtonState();
}

class _AuthBackButtonState extends State<_AuthBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) {
        _ctrl.reverse();
        // FIX: use custom onTap if provided, otherwise default to maybePop
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          Navigator.maybePop(context);
        }
      },
      onTapCancel: ()  => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width:  42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color:        widget.color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
                color: widget.color.withOpacity(0.25), width: 1.2),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: widget.color,
            size:  16.r,
          ),
        ),
      ),
    );
  }
}

// ── Auth Link — PUBLIC top-level widget ──────────────────────────────────────
// FIX: promoted from private _AuthLink to public AuthLink so it can be
// used directly in screens (e.g. ForgotPassword) without going through
// the mixin, while still being accessible via mixin's authLink() helper.

class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.question,
    required this.action,
    required this.color,
    required this.hintColor,
    required this.onTap,
  });

  final String       question;
  final String       action;
  final Color        color;
  final Color        hintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(question,
            style: TextStyle(fontSize: 14.sp, color: hintColor)),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action,
                style: TextStyle(
                  fontSize:   14.sp,
                  color:      color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                height: 1.5,
                width:  action.length * 8.0.w,
                decoration: BoxDecoration(
                  color:        color,
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step Badge ────────────────────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  const _StepBadge(
      {required this.step, required this.total, required this.color});
  final int   step;
  final int   total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color:        color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.28), width: 1),
          ),
          child: Text(
            '$step / $total',
            style: TextStyle(
                fontSize: 12.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        SizedBox(width: 8.w),
        Row(
          children: List.generate(total, (i) {
            final isActive = i == step - 1;
            final isDone   = i < step;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin:   EdgeInsets.only(right: 4.w),
              width:    isActive ? 16.w : 6.w,
              height:   6.h,
              decoration: BoxDecoration(
                color: isDone || isActive
                    ? color
                    : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Section Divider ───────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider(
      {required this.color, this.label, this.labelStyle});
  final Color      color;
  final String?    label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Divider(color: color.withOpacity(0.2), height: 1);
    }
    return Row(
      children: [
        Expanded(child: Divider(color: color.withOpacity(0.2))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child:   Text(label!, style: labelStyle),
        ),
        Expanded(child: Divider(color: color.withOpacity(0.2))),
      ],
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.label, required this.icon, required this.color});
  final String   label;
  final IconData icon;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: color.withOpacity(0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13.r),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize:      11.sp,
              fontWeight:    FontWeight.w600,
              color:         color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mesh Background ───────────────────────────────────────────────────────────

class _MeshBackground extends StatelessWidget {
  const _MeshBackground({required this.c});
  final CompanyColors c;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
              colors: [
                c.card,
                Color.lerp(c.card, c.main, 0.04)!,
                Color.lerp(c.card, c.sub,  0.03)!,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: _MeshPainter(color: c.main)),
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  const _MeshPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color.withOpacity(0.04)
      ..strokeWidth = 0.8
      ..style       = PaintingStyle.stroke;
    const step = 40.0;
    for (double x = 0; x < size.width + step; x += step) {
      canvas.drawLine(
          Offset(x, 0), Offset(x - size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_MeshPainter o) => o.color != color;
}

// ── Glass Card ────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    required this.c,
    required this.padding,
    required this.radius,
  });
  final Widget        child;
  final CompanyColors c;
  final double        padding;
  final double        radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding.r),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: c.main.withOpacity(0.10), width: 1.5),
        boxShadow: [
          BoxShadow(
            color:      c.main.withOpacity(0.07),
            blurRadius: 40,
            offset:     const Offset(0, 12),
          ),
          BoxShadow(
            color:      Colors.white.withOpacity(0.8),
            blurRadius: 1,
            offset:     const Offset(0, -1),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Shimmer Text ──────────────────────────────────────────────────────────────

class _ShimmerText extends StatefulWidget {
  const _ShimmerText({
    required this.text,
    required this.c,
    required this.fontSize,
    required this.weight,
  });
  final String        text;
  final CompanyColors c;
  final double        fontSize;
  final FontWeight    weight;

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            widget.c.main,
            Color.lerp(widget.c.main, Colors.white, 0.6)!,
            widget.c.main,
          ],
          stops: [
            (_ctrl.value - 0.3).clamp(0.0, 1.0),
            _ctrl.value.clamp(0.0,       1.0),
            (_ctrl.value + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize:   widget.fontSize.sp,
            fontWeight: widget.weight,
            color:      Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Step Progress ─────────────────────────────────────────────────────────────

class _StepProgress extends StatelessWidget {
  const _StepProgress(
      {required this.current, required this.total, required this.c});
  final int           current;
  final int           total;
  final CompanyColors c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $current of $total',
              style: TextStyle(
                  fontSize: 12.sp, color: c.hint, fontWeight: FontWeight.w500),
            ),
            Text(
              '${((current / total) * 100).toInt()}%',
              style: TextStyle(
                  fontSize: 12.sp, color: c.main, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Stack(
            children: [
              Container(height: 6.h, color: c.main.withOpacity(0.12)),
              AnimatedFractionallySizedBox(
                duration:    const Duration(milliseconds: 500),
                curve:       Curves.easeInOutCubic,
                widthFactor: current / total,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    gradient:     LinearGradient(colors: [c.main, c.sub]),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Hex Background ────────────────────────────────────────────────────────────

class _HexBackground extends StatelessWidget {
  const _HexBackground({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _HexPainter(color: color), size: Size.infinite);
}

class _HexPainter extends CustomPainter {
  const _HexPainter({required this.color});
  final Color color;

  void _drawHex(Canvas canvas, Paint paint, double cx, double cy, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = math.pi / 3 * i - math.pi / 6;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color.withOpacity(0.035)
      ..strokeWidth = 0.8
      ..style       = PaintingStyle.stroke;
    const r     = 22.0;
    const hStep = r * 2 * 0.866;
    const vStep = r * 1.5;
    for (double y = -r; y < size.height + r; y += vStep) {
      final row  = (y / vStep).round();
      final xOff = row.isOdd ? hStep / 2 : 0.0;
      for (double x = -r + xOff; x < size.width + r; x += hStep) {
        _drawHex(canvas, paint, x, y, r);
      }
    }
  }

  @override
  bool shouldRepaint(_HexPainter o) => o.color != color;
}

// ── Trust Badges ──────────────────────────────────────────────────────────────

class _TrustBadges extends StatelessWidget {
  const _TrustBadges({required this.c});
  final CompanyColors c;

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.verified_user_outlined, label: 'Secure'),
      (icon: Icons.lock_outline_rounded,   label: 'Private'),
      (icon: Icons.flash_on_rounded,       label: 'Fast'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              Container(
                width:  32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color:  c.main.withOpacity(0.08),
                  shape:  BoxShape.circle,
                  border: Border.all(
                      color: c.main.withOpacity(0.2), width: 1),
                ),
                child: Icon(item.icon, color: c.main, size: 15.r),
              ),
              SizedBox(height: 4.h),
              Text(
                item.label,
                style: TextStyle(
                    fontSize:   10.sp,
                    color:      c.hint,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
void showSnackBar({required BuildContext context, required String message, bool success =true}){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:         Text(message),
      backgroundColor:success?Colors.green: Colors.red.shade700,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
  );
}
// ════════════════════════════════════════════════════════════════════════════
// PUBLIC WIDGETS — usable directly in screens OR via mixin helpers
// ════════════════════════════════════════════════════════════════════════════

// ── Auth Link — PUBLIC ────────────────────────────────────────────────────────
// (implementation above — AuthLink class)

// ── Success Card — PUBLIC ─────────────────────────────────────────────────────

class SuccessCard extends StatelessWidget with UiUtility {
  const SuccessCard({
    super.key,
    required this.c,
    required this.email,
    required this.onTap,
  });

  final CompanyColors c;
  final String        email;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      c:       c,
      padding: 24,
      radius:  28,
      child: Column(
        children: [
          Container(
            width:  64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color:  c.main.withOpacity(0.10),
              shape:  BoxShape.circle,
              border: Border.all(color: c.main.withOpacity(0.25)),
            ),
            child: Icon(Icons.mark_email_read_outlined,
                color: c.main, size: 30.r),
          ),
          SizedBox(height: 16.h),
          Text(
            'check_your_email'.tr(),
            style: TextStyle(
              fontSize:   18.sp,
              fontWeight: FontWeight.w700,
              color:      c.text,
            ),
          ),
          SizedBox(height: 8.h),
          InkWell(
            onTap: onTap,
            child: Text(
              '${'reset_link_sent_to'.tr()} $email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:      13.sp,
                color:         c.hint,
                height:        1.5,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _PrimaryButton(
            label:           'back_to_login'.tr(),
            onPressed:       () => Navigator.pop(context),
            backgroundColor: c.button,
            foregroundColor: c.buttonText,
            loading:         false,
            height:          54,
            radius:          14,
          ),
        ],
      ),
    );
  }
}
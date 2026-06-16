import 'dart:math' as math;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/data/model/response/PromoSlide.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../presentation/home/widgets/home_shared.dart';

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
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
        scaffoldBackgroundColor: Colors.transparent,
      // ── Color Scheme ──────────────────────────────────────────
      colorScheme: ColorScheme.fromSeed(
        seedColor:   Colors.white,
        brightness:  brightness,
        primary:     c.main,
        secondary:   c.sub,
        surface:     c.card,
        onPrimary:   c.buttonText,
        onSecondary: c.buttonText,
        onSurface:   c.text,
        error:       isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A),
      ),

      // ── Scaffold & Canvas ─────────────────────────────────────

      canvasColor:             c.card,
      cardColor:               c.card,
      dialogBackgroundColor:   c.card,

      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:  c.main,
        foregroundColor:  c.buttonText,
        surfaceTintColor: Colors.transparent,
        shadowColor:      c.main.withOpacity(0.3),
        elevation:        0,
        centerTitle:      true,
        iconTheme:        IconThemeData(color: c.buttonText),
        actionsIconTheme: IconThemeData(color: c.buttonText),
        titleTextStyle: TextStyle(
          color:      c.buttonText,
          fontSize:   18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      c.card,
        selectedItemColor:    c.main,
        unselectedItemColor:  c.hint,
        selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.main),
        unselectedLabelStyle: TextStyle(fontSize: 11, color: c.hint),
        showSelectedLabels:   true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── Navigation Bar (Material 3) ───────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:       c.card,
        indicatorColor:        c.main.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.main, size: 24);
          }
          return IconThemeData(color: c.hint, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.main);
          }
          return TextStyle(fontSize: 11, color: c.hint);
        }),
        elevation: 8,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Tab Bar ───────────────────────────────────────────────

      // ── Elevated Button ───────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.button,
          foregroundColor: c.buttonText,
          disabledBackgroundColor: c.button.withOpacity(0.4),
          disabledForegroundColor: c.buttonText.withOpacity(0.6),
          elevation:   0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.main,
          disabledForegroundColor: c.hint,
          side:    BorderSide(color: c.main, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.main,
          disabledForegroundColor: c.hint,
          padding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor:   c.button,
        foregroundColor:   c.buttonText,
        elevation:         4,
        focusElevation:    6,
        hoverElevation:    6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Input Decoration ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: c.textField,
        hintStyle:  TextStyle(color: c.hint, fontSize: 14),
        labelStyle: TextStyle(color: c.label, fontSize: 14),
        floatingLabelStyle: TextStyle(color: c.main, fontSize: 13, fontWeight: FontWeight.w600),
        prefixIconColor: c.icon,
        suffixIconColor: c.hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: c.sub.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: c.sub.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: c.main, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A), width: 1.8),
        ),
        errorStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A),
        ),
      ),

      // ── Text Theme ────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  TextStyle(color: c.text,  fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(color: c.text,  fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall:  TextStyle(color: c.text,  fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge:  TextStyle(color: c.text,  fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: c.text,  fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall:  TextStyle(color: c.text,  fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge:  TextStyle(color: c.text,  fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: c.text,  fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall:  TextStyle(color: c.text,  fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge:   TextStyle(color: c.text,  fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium:  TextStyle(color: c.text,  fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall:   TextStyle(color: c.hint,  fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge:  TextStyle(color: c.label, fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: c.label, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall:  TextStyle(color: c.hint,  fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // ── Icons ─────────────────────────────────────────────────
      iconTheme: IconThemeData(color: c.icon, size: 24),
      primaryIconTheme: IconThemeData(color: c.buttonText, size: 24),

      // ── Card ──────────────────────────────────────────────────
cardTheme: CardThemeData(color:Colors.white),


      // ── Chip ──────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:    c.textField,
        selectedColor:      c.main.withOpacity(0.15),
        disabledColor:      c.hint.withOpacity(0.1),
        labelStyle:         TextStyle(color: c.text,  fontSize: 13),
        secondaryLabelStyle: TextStyle(color: c.main, fontSize: 13, fontWeight: FontWeight.w600),
        side:          BorderSide(color: c.sub.withOpacity(0.3)),
        shape:         RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding:       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        checkmarkColor: c.main,
        iconTheme:     IconThemeData(color: c.icon, size: 18),
      ),



      // ── Bottom Sheet ──────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(

        surfaceTintColor:     Colors.transparent,
        modalBackgroundColor: c.card,
        elevation:            0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: c.hint.withOpacity(0.4),
        dragHandleSize:  const Size(40, 4),
      ),

      // ── Snack Bar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:  isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A2E),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor:  c.sub,
        behavior:         SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     c.sub.withOpacity(0.2),
        thickness: 1,
        space:     1,
      ),

      // ── List Tile ─────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor:         Colors.transparent,
        selectedTileColor: c.main.withOpacity(0.08),
        iconColor:         c.icon,
        textColor:         c.text,
        subtitleTextStyle: TextStyle(color: c.hint, fontSize: 13),
        titleTextStyle:    TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w500),
        selectedColor:     c.main,
        contentPadding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Switch ────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.button;
          return c.hint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.main.withOpacity(0.4);
          return c.hint.withOpacity(0.2);
        }),
      ),

      // ── Checkbox ─────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.main;
          return Colors.transparent;
        }),
        checkColor:   WidgetStateProperty.all(c.buttonText),
        side:         BorderSide(color: c.sub, width: 1.5),
        shape:        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        overlayColor: WidgetStateProperty.all(c.main.withOpacity(0.08)),
      ),

      // ── Radio ─────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.main;
          return c.hint;
        }),
        overlayColor: WidgetStateProperty.all(c.main.withOpacity(0.08)),
      ),

      // ── Slider ───────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor:   c.main,
        inactiveTrackColor: c.main.withOpacity(0.2),
        thumbColor:         c.main,
        overlayColor:       c.main.withOpacity(0.12),
        valueIndicatorColor: c.main,
        valueIndicatorTextStyle: TextStyle(color: c.buttonText, fontSize: 12),
      ),

      // ── Progress Indicator ───────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color:            c.main,
        linearTrackColor: c.main.withOpacity(0.15),
        circularTrackColor: c.main.withOpacity(0.15),
        linearMinHeight: 4,
      ),

      // ── Tooltip ──────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color:        isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color:    isDark ? const Color(0xFF1A1A2E) : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        preferBelow: false,
      ),

      // ── Search Bar ───────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(c.textField),
        shadowColor:     WidgetStateProperty.all(Colors.transparent),
        overlayColor:    WidgetStateProperty.all(c.main.withOpacity(0.05)),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: c.main, width: 1.8);
          }
          return BorderSide(color: c.sub.withOpacity(0.3));
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: WidgetStateProperty.all(TextStyle(color: c.text, fontSize: 14)),
        hintStyle: WidgetStateProperty.all(TextStyle(color: c.hint, fontSize: 14)),
      ),

      // ── Badge ────────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: c.button,
        textColor:       c.buttonText,
        textStyle:       const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        padding:         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),

      // ── Popup Menu ───────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color:            c.card,
        surfaceTintColor: Colors.transparent,
        elevation:        8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.sub.withOpacity(0.15)),
        ),
        textStyle:   TextStyle(color: c.text, fontSize: 14),
        labelTextStyle: WidgetStateProperty.all(TextStyle(color: c.text, fontSize: 14)),
      ),

      // ── Drawer ───────────────────────────────────────────────
      drawerTheme: DrawerThemeData(
        backgroundColor:  c.card,
        surfaceTintColor: Colors.transparent,
        elevation:        16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
      ),
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
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
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
    required Color surfaceColor,
    required Color shadowColor,
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
  // AUTH WIDGETS  (original)
  // ════════════════════════════════════════════════════════════════

  Widget brandLogo({
    required CompanyColors c,
    IconData icon = Icons.shopping_bag_outlined,
  }) =>
      _AnimatedBrandLogo(c: c, icon: icon);

  Widget screenHeadline({
    required String title,
    required String subtitle,
    required CompanyColors c,
  }) =>
      _ScreenHeadline(title: title, subtitle: subtitle, c: c);

  Widget orDivider({required CompanyColors c}) => _OrDivider(c: c);

  Widget backButton({
    required CompanyColors c,
    VoidCallback? onTap,
  }) =>
      _AuthBackButton(color: c.main, onTap: onTap);

  Widget authLink({
    required String question,
    required String action,
    required CompanyColors c,
    required VoidCallback onTap,
  }) =>
      AuthLink(
        question:  question,
        action:    action,
        color:     c.main,
        hintColor: c.hint,
        onTap:     onTap,
      );

  Widget stepBadge({
    required int step,
    required int total,
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
    required String label,
    required IconData icon,
    required CompanyColors c,
  }) =>
      _InfoChip(label: label, icon: icon, color: c.main);

  Widget meshBackground({required CompanyColors c}) => _MeshBackground(c: c);

  Widget glassCard({
    required Widget child,
    required CompanyColors c,
    double padding = 24,
    double radius  = 28,
  }) =>
      _GlassCard(child: child, c: c, padding: padding, radius: radius);

  Widget shimmerText({
    required String text,
    required CompanyColors c,
    double     fontSize = 14,
    FontWeight weight   = FontWeight.w600,
  }) =>
      _ShimmerText(text: text, c: c, fontSize: fontSize, weight: weight);

  Widget stepProgress({
    required int current,
    required int total,
    required CompanyColors c,
  }) =>
      _StepProgress(current: current, total: total, c: c);

  Widget hexBackground({required Color color}) => _HexBackground(color: color);

  Widget trustBadges({required CompanyColors c}) => _TrustBadges(c: c);

  Widget successCard({
    required CompanyColors c,
    required String email,
    required VoidCallback onTap,
  }) =>
      SuccessCard(c: c, email: email, onTap: onTap);

  // ════════════════════════════════════════════════════════════════
  // SHARED AUTH SCREEN WIDGETS
  // Replaces private _TopBar, _Logo, _Headline, _InputField,
  // _FieldLabel, _SubmitButton, _OrDivider, _LoginRow,
  // _LoadingOverlay, _LangPill duplicated across every auth screen.
  // ════════════════════════════════════════════════════════════════

  /// Top bar: optional back button + language pills + theme toggle.
  /// Pass [showBackButton: false] on the login screen.
  Widget sharedTopBar({
    required ColorHelper p,
    required bool isAr,
    required bool isDark,
    required ValueChanged<String> onLang,
    VoidCallback? onBack,
    bool showBackButton = true,
  }) =>
      _SharedTopBar(
        p:              p,
        isAr:           isAr,
        isDark:         isDark,
        onLang:         onLang,
        onBack:         onBack,
        showBackButton: showBackButton,
      );

  /// Gradient icon + app-name logo tile.
  Widget sharedLogo({
    required ColorHelper p,
    required CompanyColors c,
    required IconData icon,
    required String appName,
  }) =>
      _SharedLogo(p: p, c: c, icon: icon, appName: appName);

  /// Left-aligned headline with accent underline bar + subtitle.
  Widget sharedHeadline({
    required String title,
    required String subtitle,
    required ColorHelper p,
  }) =>
      _SharedHeadline(title: title, subtitle: subtitle, p: p);

  /// Styled TextFormField matching the auth design system.
  Widget sharedInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required IconData prefixIcon,
    bool obscure = false,
    Widget? suffix,
    required ColorHelper p,
    FormFieldValidator<String>? validator,
  }) =>
      _SharedInputField(
        controller:   controller,
        hintText:     hintText,
        keyboardType: keyboardType,
        prefixIcon:   prefixIcon,
        obscure:      obscure,
        suffix:       suffix,
        p:            p,
        validator:    validator,
      );

  /// Bold label above an input field.
  Widget sharedFieldLabel({
    required String label,
    required ColorHelper p,
  }) =>
      _SharedFieldLabel(label: label, p: p);

  /// Gradient submit / action button with loading state.
  Widget sharedSubmitButton({
    required ColorHelper p,
    required bool loading,
    required String label,
    required VoidCallback onTap,
  }) =>
      _SharedSubmitButton(p: p, loading: loading, label: label, onTap: onTap);

  /// "── or ──" divider row.
  Widget sharedOrDivider({required ColorHelper p}) =>
      _SharedOrDivider(p: p);

  /// Two-text tap row ("Already have an account? Login").
  Widget sharedAuthLinkRow({
    required String question,
    required String actionLabel,
    required ColorHelper p,
    required VoidCallback onTap,
  }) =>
      _SharedAuthLinkRow(
        question:    question,
        actionLabel: actionLabel,
        p:           p,
        onTap:       onTap,
      );

  /// Full-screen semi-transparent loading overlay with centred spinner card.
  Widget sharedLoadingOverlay({required ColorHelper p}) =>
      _SharedLoadingOverlay(p: p);

  // ════════════════════════════════════════════════════════════════
  // PROMO SLIDE
  // ════════════════════════════════════════════════════════════════

  Widget promoSlide({
    required BuildContext context,
    required PromoSlideData data,
  }) {
    const buttonText = Colors.white;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color:      data.gradient.first.withOpacity(0.40),
            blurRadius: 20,
            offset:     const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 120.r, height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonText.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -30,
            child: Container(
              width: 100.r, height: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonText.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color:        buttonText.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          data.badge,
                          style: TextStyle(
                              fontSize: 10.sp,
                              color:    buttonText.withOpacity(0.85)),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize:   20.sp,
                          fontWeight: FontWeight.w600,
                          color:      buttonText,
                          height:     1.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        data.subtitle,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color:    buttonText.withOpacity(0.70)),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color:        buttonText.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'shop_now'.tr(),
                              style: TextStyle(
                                fontSize:   12.sp,
                                color:      buttonText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_forward,
                                size: 14.r, color: buttonText),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color:        buttonText.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Text('up_to'.tr(),
                          style: TextStyle(
                              fontSize: 10.sp,
                              color:    buttonText.withOpacity(0.75))),
                      Text(
                        data.discount,
                        style: TextStyle(
                          fontSize:   28.sp,
                          fontWeight: FontWeight.w700,
                          color:      buttonText,
                        ),
                      ),
                      Text('off'.tr(),
                          style: TextStyle(
                              fontSize:   10.sp,
                              color:      buttonText,
                              fontWeight: FontWeight.w600)),
                    ],
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

// ════════════════════════════════════════════════════════════════════════════
// ColorHelper  — replaces the private _P class duplicated in every auth screen
// ════════════════════════════════════════════════════════════════════════════

class ColorHelper {
  final Color bg;
  final Color card;
  final Color input;
  final Color border;
  final Color primary;
  final Color blob2;
  final Color text;
  final Color subText;
  final Color label;
  final Color buttonText;
  final Color divider;
  final Color error;
  final Color icon;

  const ColorHelper({
    required this.bg,
    required this.card,
    required this.input,
    required this.border,
    required this.primary,
    required this.blob2,
    required this.text,
    required this.subText,
    required this.label,
    required this.buttonText,
    required this.divider,
    required this.error,
    required this.icon,
  });

  factory ColorHelper.fromCompany(CompanyColors c, bool isDark) => ColorHelper(
    bg: isDark
        ? Color.lerp(c.card, Colors.black, 0.3)!
        : Color.lerp(c.card, Colors.white, 0.6)!,
    card:       c.card,
    input:      c.textField,
    border:     Color.lerp(c.sub, Colors.grey, 0.5)!.withOpacity(0.3),
    primary:    c.main,
    blob2:      c.sub,
    text:       c.text,
    subText:    c.hint,
    label:      c.label,
    buttonText: c.buttonText,
    divider:    c.sub.withOpacity(0.2),
    error: isDark
        ? const Color(0xFFFF7675)
        : const Color(0xFFE24B4A),
    icon: c.icon,
  );
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
// SHARED AUTH SCREEN PRIVATE WIDGETS
// ════════════════════════════════════════════════════════════════════════════

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _SharedTopBar extends StatelessWidget {
  final ColorHelper          p;
  final bool                 isAr;
  final bool                 isDark;
  final ValueChanged<String> onLang;
  final VoidCallback?        onBack;
  final bool                 showBackButton;

  const _SharedTopBar({
    required this.p,
    required this.isAr,
    required this.isDark,
    required this.onLang,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button (optional)
        if (showBackButton)
          GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
            child: Container(
              width:  40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color:        p.card,
                borderRadius: BorderRadius.circular(12.r),
                border:       Border.all(color: p.border),
              ),
              child: Icon(
                isAr
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: p.primary,
                size:  16.r,
              ),
            ),
          ),

        const Spacer(),

        // Language pills
        Container(
          padding:    EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color:        p.card,
            borderRadius: BorderRadius.circular(32.r),
            border:       Border.all(color: p.border),
          ),
          child: Row(
            children: [
              _SharedLangPill(
                  label: 'EN', active: !isAr, p: p,
                  onTap: () => onLang('en')),
              SizedBox(width: 4.w),
              _SharedLangPill(
                  label: 'AR', active: isAr, p: p,
                  onTap: () => onLang('ar')),
            ],
          ),
        ),
        SizedBox(width: 10.w),

        // Theme toggle
        Container(
          width:  40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color:        p.card,
            borderRadius: BorderRadius.circular(12.r),
            border:       Border.all(color: p.border),
          ),
          child: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: p.primary,
            size:  20.r,
          ),
        ),
      ],
    );
  }
}

class _SharedLangPill extends StatelessWidget {
  final String       label;
  final bool         active;
  final ColorHelper  p;
  final VoidCallback onTap;

  const _SharedLangPill({
    required this.label,
    required this.active,
    required this.p,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding:  EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color:        active ? p.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   13.sp,
          fontWeight: FontWeight.w700,
          color:      active ? p.buttonText : p.subText,
        ),
      ),
    ),
  );
}

// ── Logo ──────────────────────────────────────────────────────────────────────

class _SharedLogo extends StatelessWidget {
  final ColorHelper   p;
  final CompanyColors c;
  final IconData      icon;
  final String        appName;

  const _SharedLogo({
    required this.p,
    required this.c,
    required this.icon,
    required this.appName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width:  72.r,
          height: 72.r,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.main, c.sub],
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color:      c.main.withOpacity(0.38),
                blurRadius: 20,
                offset:     const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: p.buttonText, size: 36.r),
        ),
        SizedBox(height: 10.h),
        Text(
          appName,
          style: TextStyle(
            fontSize:      20.sp,
            fontWeight:    FontWeight.w800,
            color:         p.text,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ── Headline ──────────────────────────────────────────────────────────────────

class _SharedHeadline extends StatelessWidget {
  final String      title;
  final String      subtitle;
  final ColorHelper p;

  const _SharedHeadline({
    required this.title,
    required this.subtitle,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize:      26.sp,
            fontWeight:    FontWeight.w800,
            color:         p.text,
            letterSpacing: -0.8,
            height:        1.2,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width:  48.w,
          height: 3.h,
          decoration: BoxDecoration(
            gradient:     LinearGradient(colors: [p.primary, p.blob2]),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize:   14.sp,
            color:      p.subText,
            fontWeight: FontWeight.w400,
            height:     1.5,
          ),
        ),
      ],
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _SharedFieldLabel extends StatelessWidget {
  final String      label;
  final ColorHelper p;

  const _SharedFieldLabel({required this.label, required this.p});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize:      13.sp,
      fontWeight:    FontWeight.w700,
      color:         p.label,
      letterSpacing: 0.2,
    ),
  );
}

// ── Input Field ───────────────────────────────────────────────────────────────

class _SharedInputField extends StatelessWidget {
  final TextEditingController       controller;
  final String                      hintText;
  final TextInputType               keyboardType;
  final IconData                    prefixIcon;
  final bool                        obscure;
  final Widget?                     suffix;
  final ColorHelper                 p;
  final FormFieldValidator<String>? validator;

  const _SharedInputField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    required this.prefixIcon,
    this.obscure  = false,
    this.suffix,
    required this.p,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller:     controller,
    keyboardType:   keyboardType,
    obscureText:    obscure,
    style: TextStyle(fontSize: 14.sp, color: p.text),
    decoration: InputDecoration(
      hintText:  hintText,
      hintStyle: TextStyle(color: p.subText, fontSize: 14.sp),
      filled:    true,
      fillColor: p.input,
      prefixIcon: Icon(prefixIcon, color: p.primary, size: 20.r),
      suffixIcon: suffix,
      contentPadding:
      EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:   BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:   BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:   BorderSide(color: p.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:   BorderSide(color: p.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:   BorderSide(color: p.error, width: 1.5),
      ),
      errorStyle: TextStyle(
        color:      p.error,
        fontSize:   11.5.sp,
        fontWeight: FontWeight.w500,
      ),
    ),
    validator: validator,
  );
}

// ── Submit Button ─────────────────────────────────────────────────────────────

class _SharedSubmitButton extends StatelessWidget {
  final ColorHelper  p;
  final bool         loading;
  final String       label;
  final VoidCallback onTap;

  const _SharedSubmitButton({
    required this.p,
    required this.loading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width:    double.infinity,
      height:   52.h,
      decoration: BoxDecoration(
        gradient: loading
            ? null
            : LinearGradient(
          colors: [p.primary, p.blob2],
          begin:  Alignment.centerLeft,
          end:    Alignment.centerRight,
        ),
        color:        loading ? p.primary.withOpacity(0.55) : null,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: loading
            ? []
            : [
          BoxShadow(
            color:      p.primary.withOpacity(0.38),
            blurRadius: 18,
            offset:     const Offset(0, 7),
          ),
        ],
      ),
      child: loading
          ? Center(
        child: SizedBox(
          width:  22.r,
          height: 22.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color:       p.buttonText,
          ),
        ),
      )
          : Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize:      15.sp,
            fontWeight:    FontWeight.w700,
            color:         p.buttonText,
            letterSpacing: 0.3,
          ),
        ),
      ),
    ),
  );
}

// ── Or Divider ────────────────────────────────────────────────────────────────

class _SharedOrDivider extends StatelessWidget {
  final ColorHelper p;
  const _SharedOrDivider({required this.p});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: p.divider, thickness: 1)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Text(
          'or'.tr(),
          style: TextStyle(
            fontSize:   13.sp,
            color:      p.subText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(child: Divider(color: p.divider, thickness: 1)),
    ],
  );
}

// ── Auth Link Row ─────────────────────────────────────────────────────────────

class _SharedAuthLinkRow extends StatelessWidget {
  final String       question;
  final String       actionLabel;
  final ColorHelper  p;
  final VoidCallback onTap;

  const _SharedAuthLinkRow({
    required this.question,
    required this.actionLabel,
    required this.p,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(question,
          style: TextStyle(fontSize: 14.sp, color: p.subText)),
      SizedBox(width: 4.w),
      GestureDetector(
        onTap: onTap,
        child: Text(
          actionLabel,
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

// ── Loading Overlay ───────────────────────────────────────────────────────────

class _SharedLoadingOverlay extends StatelessWidget {
  final ColorHelper p;
  const _SharedLoadingOverlay({required this.p});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
        width:  72.r,
        height: 72.r,
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

// ════════════════════════════════════════════════════════════════════════════
// ORIGINAL PRIVATE SUB-WIDGETS  (unchanged)
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

// ── Animated Brand Logo ───────────────────────────────────────────────────────

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

// ── Screen Headline ───────────────────────────────────────────────────────────

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

// ── Or Divider (CompanyColors variant) ───────────────────────────────────────

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
                  fontSize:   12.sp,
                  color:      c.hint,
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

class _AuthBackButton extends StatefulWidget {
  const _AuthBackButton({required this.color, this.onTap});
  final Color         color;
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
        widget.onTap != null
            ? widget.onTap!()
            : Navigator.maybePop(context);
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

// ── Auth Link ─────────────────────────────────────────────────────────────────

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

// ════════════════════════════════════════════════════════════════════════════
// TOP-LEVEL HELPERS
// ════════════════════════════════════════════════════════════════════════════

Widget emptyWidget({required AppColors c}) => Padding(
  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
  child: Column(
    children: [
      Icon(Icons.inventory_2_outlined, size: 48.r, color: c.hint),
      SizedBox(height: 12.h),
      Text(
        'no_products'.tr(),
        style: TextStyle(fontSize: 14.sp, color: c.hint),
      ),
    ],
  ),
);

void showSnackBar({
  required BuildContext context,
  required String       message,
  bool success = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:         Text(message),
      backgroundColor: success ? Colors.green : Colors.red.shade700,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Widget brandWidget({
  required BuildContext context,
  required BrandDataDataEntity brand,
  required AppColors c,
}) {
  final name = localizedEnAr(
    context: context,
    nameEn:  brand.nameEn,
    nameAr:  brand.nameAr,
  );

  return Container(
    width: 108.w,
    decoration: BoxDecoration(
      color:        c.card,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color:      c.main.withOpacity(0.08),
          blurRadius: 14,
          offset:     const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        Expanded(
          child: Container(
            width:  double.infinity,
            margin: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color:        c.textField,
              borderRadius: BorderRadius.circular(14.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: brandNetworkImage(brand, c),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 10.h),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:   11.sp,
              fontWeight: FontWeight.w700,
              color:      c.bodyText,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget getErrorView({
  required BuildContext context,
  required String?      message,
  required AppColors    c,
  required VoidCallback onRetry,
}) =>
    Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: c.hint),
          SizedBox(height: 12.h),
          Text(
            message ?? 'something_went_wrong'.tr(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: c.hint),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );

// ── Success Card ──────────────────────────────────────────────────────────────

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
              style: TextStyle(fontSize: 13.sp, color: c.hint, height: 1.5),
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
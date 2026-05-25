// lib/core/theme/app_theme.dart


import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColors — holds every CompanyColors token as a ThemeExtension so any
// widget can reach it via  Theme.of(context).appColors
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.main,
    required this.sub,
    required this.button,
    required this.buttonText,
    required this.bodyText,
    required this.hint,
    required this.card,
    required this.label,
    required this.textField,
    required this.icon,
  });

  /// Primary brand color  (e.g. #1D5D9B)
  final Color main;

  /// Secondary brand color (e.g. #1D5D9B)
  final Color sub;

  /// CTA / button background color
  final Color button;

  /// Text / icon color that sits ON a button
  final Color buttonText;

  /// Primary body text color  (e.g. #1A1A2E)
  final Color bodyText;

  /// Muted / hint / placeholder text (e.g. #9E9E9E)
  final Color hint;

  /// Card / surface / scaffold background (e.g. #F5F5F5)
  final Color card;

  /// Label text color  (e.g. #1A1A2E)
  final Color label;

  /// Input field / chip background color (e.g. #F5F5F5)
  final Color textField;

  /// Icon tint color  (e.g. #1D5D9B)
  final Color icon;

  // ── ThemeExtension boilerplate ────────────────────────────────────────────

  @override
  AppColors copyWith({
    Color? main,
    Color? sub,
    Color? button,
    Color? buttonText,
    Color? bodyText,
    Color? hint,
    Color? card,
    Color? label,
    Color? textField,
    Color? icon,
  }) {
    return AppColors(
      main:        main        ?? this.main,
      sub:         sub         ?? this.sub,
      button:      button      ?? this.button,
      buttonText:  buttonText  ?? this.buttonText,
      bodyText:    bodyText    ?? this.bodyText,
      hint:        hint        ?? this.hint,
      card:        card        ?? this.card,
      label:       label       ?? this.label,
      textField:   textField   ?? this.textField,
      icon:        icon        ?? this.icon,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      main:       Color.lerp(main,       other.main,       t)!,
      sub:        Color.lerp(sub,        other.sub,        t)!,
      button:     Color.lerp(button,     other.button,     t)!,
      buttonText: Color.lerp(buttonText, other.buttonText, t)!,
      bodyText:   Color.lerp(bodyText,   other.bodyText,   t)!,
      hint:       Color.lerp(hint,       other.hint,       t)!,
      card:       Color.lerp(card,       other.card,       t)!,
      label:      Color.lerp(label,      other.label,      t)!,
      textField:  Color.lerp(textField,  other.textField,  t)!,
      icon:       Color.lerp(icon,       other.icon,       t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience extension — Theme.of(context).appColors
// ─────────────────────────────────────────────────────────────────────────────

extension AppColorsX on ThemeData {
  AppColors get appColors =>
      extension<AppColors>() ??
          const AppColors(
            main:       Color(0xFF1D5D9B),
            sub:        Color(0xFF1D5D9B),
            button:     Color(0xFF1D5D9B),
            buttonText: Color(0xFFFFFFFF),
            bodyText:   Color(0xFF1A1A2E),
            hint:       Color(0xFF9E9E9E),
            card:       Color(0xFFF5F5F5),
            label:      Color(0xFF1A1A2E),
            textField:  Color(0xFFF5F5F5),
            icon:       Color(0xFF1D5D9B),
          );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — builds a ThemeData from a CompanyColors instance
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData fromCompanyColors(CompanyColors c) {
    final appColors = AppColors(
      main:       c.main,
      sub:        c.sub,
      button:     c.button,
      buttonText: c.buttonText,
      bodyText:   c.text,
      hint:       c.hint,
      card:       c.card,
      label:      c.label,
      textField:  c.textField,
      icon:       c.icon,
    );

    return ThemeData(
      useMaterial3: true,

      // ── color scheme ──────────────────────────────────────────────────────
      colorScheme: ColorScheme.fromSeed(
        seedColor:   c.main,
        brightness:  Brightness.light,
        primary:     c.main,
        secondary:   c.sub,
        surface:     c.card,
        onPrimary:   c.buttonText,
        onSecondary: c.buttonText,
        onSurface:   c.text,
      ),

      // ── scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: c.card,

      // ── app bar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:  c.main,
        foregroundColor:  c.buttonText,
        elevation:        0,
        iconTheme:        IconThemeData(color: c.buttonText),
        titleTextStyle: TextStyle(
          color:      c.buttonText,
          fontSize:   18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── elevated button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.button,
          foregroundColor: c.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── text button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.button),
      ),

      // ── outlined button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.button,
          side:            BorderSide(color: c.button),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── input decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:     true,
        fillColor:  c.textField,
        hintStyle:  TextStyle(color: c.hint),
        labelStyle: TextStyle(color: c.label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: c.sub.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: c.sub.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: c.main, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: Colors.red),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),

      // ── text theme ────────────────────────────────────────────────────────
      textTheme: TextTheme(
        // display
        displayLarge:  TextStyle(color: c.text, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: c.text, fontWeight: FontWeight.w700),
        displaySmall:  TextStyle(color: c.text, fontWeight: FontWeight.w600),
        // headline
        headlineLarge:  TextStyle(color: c.text, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: c.text, fontWeight: FontWeight.w600),
        headlineSmall:  TextStyle(color: c.text, fontWeight: FontWeight.w500),
        // title
        titleLarge:  TextStyle(color: c.text, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: c.text, fontWeight: FontWeight.w500),
        titleSmall:  TextStyle(color: c.text, fontWeight: FontWeight.w500),
        // body
        bodyLarge:   TextStyle(color: c.text),
        bodyMedium:  TextStyle(color: c.text),
        bodySmall:   TextStyle(color: c.hint),
        // label
        labelLarge:  TextStyle(color: c.label, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: c.label),
        labelSmall:  TextStyle(color: c.hint),
      ),

      // ── icon theme ────────────────────────────────────────────────────────
      iconTheme:         IconThemeData(color: c.icon),
      primaryIconTheme:  IconThemeData(color: c.buttonText),

      // ── card theme ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:     c.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.hint.withOpacity(0.12)),
        ),
      ),

      // ── chip theme ────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:  c.textField,
        labelStyle:       TextStyle(color: c.hint, fontSize: 12),
        side:             BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),

      // ── divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     c.hint.withOpacity(0.2),
        thickness: 1,
        space:     1,
      ),

      // ── progress indicator ────────────────────────────────────────────────
      progressIndicatorTheme:
      ProgressIndicatorThemeData(color: c.main),

      // ── floating action button ────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.button,
        foregroundColor: c.buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── snack bar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.main,
        contentTextStyle: TextStyle(color: c.buttonText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── bottom navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      c.card,
        selectedItemColor:    c.main,
        unselectedItemColor:  c.hint,
        selectedLabelStyle:   TextStyle(color: c.main,   fontSize: 11),
        unselectedLabelStyle: TextStyle(color: c.hint,   fontSize: 11),
        elevation: 8,
      ),

      // ── navigation bar (M3) ───────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:           c.card,
        indicatorColor:            c.main.withOpacity(0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.main);
          }
          return IconThemeData(color: c.hint);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: c.main, fontSize: 11,
                fontWeight: FontWeight.w600);
          }
          return TextStyle(color: c.hint, fontSize: 11);
        }),
      ),

      // ── tab bar ───────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor:         c.main,
        unselectedLabelColor: c.hint,
        indicatorColor:     c.main,
        indicatorSize:      TabBarIndicatorSize.label,
        labelStyle:   const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),

      // ── dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
            color: c.text, fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: c.hint, fontSize: 14),
      ),

      // ── list tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        iconColor:   c.icon,
        textColor:   c.text,
        tileColor:   c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? c.buttonText
            : c.hint),
        trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? c.main
            : c.hint.withOpacity(0.3)),
      ),

      // ── checkbox ──────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? c.main : Colors.transparent),
        checkColor: WidgetStateProperty.all(c.buttonText),
        side: BorderSide(color: c.hint, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ── radio ─────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? c.main : c.hint),
      ),

      // ── custom extension — accessible via Theme.of(context).appColors ─────
      extensions: [appColors],
    );
  }
}
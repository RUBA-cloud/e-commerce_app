// ════════════════════════════════════════════════════════════════
// app_theme.dart — FULL FILE
// ════════════════════════════════════════════════════════════════

import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:flutter/material.dart';

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

  final Color main, sub, button, buttonText, bodyText, hint, card, label, textField, icon;

  @override
  AppColors copyWith({
    Color? main, Color? sub, Color? button, Color? buttonText,
    Color? bodyText, Color? hint, Color? card, Color? label,
    Color? textField, Color? icon,
  }) => AppColors(
    main:       main       ?? this.main,
    sub:        sub        ?? this.sub,
    button:     button     ?? this.button,
    buttonText: buttonText ?? this.buttonText,
    bodyText:   bodyText   ?? this.bodyText,
    hint:       hint       ?? this.hint,
    card:       card       ?? this.card,
    label:      label      ?? this.label,
    textField:  textField  ?? this.textField,
    icon:       icon       ?? this.icon,
  );

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

class AppTheme {
  AppTheme._();

  /// Call for both theme and darkTheme:
  ///   theme:     AppTheme.fromCompanyColors(colors, isDark: false)
  ///   darkTheme: AppTheme.fromCompanyColors(colors, isDark: true)
  static ThemeData fromCompanyColors(CompanyColors c, {bool isDark = false}) {
    final r          = c.resolved(isDark); // ✅ picks dark fields automatically
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final appColors = AppColors(
      main:       r.main,
      sub:        r.sub,
      button:     r.button,
      buttonText: r.buttonText,
      bodyText:   r.text,
      hint:       r.hint,
      card:       r.card,
      label:      r.label,
      textField:  r.textField,
      icon:       r.icon,
    );

    return ThemeData(
      useMaterial3: true,
      brightness:   brightness,
      extensions:   [appColors], // ✅ Theme.of(context).appColors works everywhere

      scaffoldBackgroundColor: isDark
          ? Color.lerp(r.card, Colors.black, 0.25)!
          : Color.lerp(r.card, Colors.white, 0.6)!,

      colorScheme: ColorScheme.fromSeed(
        seedColor:   r.main,
        brightness:  brightness,
        primary:     r.main,
        secondary:   r.sub,
        surface:     r.card,
        onPrimary:   r.buttonText,
        onSecondary: r.buttonText,
        onSurface:   r.text,
        error: isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A),
      ),

      canvasColor:           r.card,
      cardColor:             r.card,
      dialogBackgroundColor: r.card,

      appBarTheme: AppBarTheme(
        backgroundColor:  r.main,
        foregroundColor:  r.buttonText,
        surfaceTintColor: Colors.transparent,
        elevation:        0,
        centerTitle:      true,
        iconTheme:        IconThemeData(color: r.buttonText),
        actionsIconTheme: IconThemeData(color: r.buttonText),
        titleTextStyle: TextStyle(
          color: r.buttonText, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:         r.button,
          foregroundColor:         r.buttonText,
          disabledBackgroundColor: r.button.withOpacity(0.4),
          disabledForegroundColor: r.buttonText.withOpacity(0.6),
          elevation:   0,
          shadowColor: Colors.transparent,
          padding:     const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:   const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: r.main,
          side:    BorderSide(color: r.main, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: r.main,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: r.button,
        foregroundColor: r.buttonText,
        elevation:       4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: r.textField,
        hintStyle:  TextStyle(color: r.hint,  fontSize: 14),
        labelStyle: TextStyle(color: r.label, fontSize: 14),
        floatingLabelStyle: TextStyle(color: r.main, fontSize: 13, fontWeight: FontWeight.w600),
        prefixIconColor: r.icon,
        suffixIconColor: r.hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: r.sub.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: r.sub.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: r.main, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A),
            width: 1.8,
          ),
        ),
        errorStyle: TextStyle(
          color: isDark ? const Color(0xFFFF7675) : const Color(0xFFE24B4A),
          fontSize: 11.5, fontWeight: FontWeight.w500,
        ),
      ),

      textTheme: TextTheme(
        displayLarge:   TextStyle(color: r.text,  fontWeight: FontWeight.w700),
        displayMedium:  TextStyle(color: r.text,  fontWeight: FontWeight.w700),
        displaySmall:   TextStyle(color: r.text,  fontWeight: FontWeight.w600),
        headlineLarge:  TextStyle(color: r.text,  fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: r.text,  fontWeight: FontWeight.w600),
        headlineSmall:  TextStyle(color: r.text,  fontWeight: FontWeight.w500),
        titleLarge:     TextStyle(color: r.text,  fontWeight: FontWeight.w500),
        titleMedium:    TextStyle(color: r.text,  fontWeight: FontWeight.w500),
        titleSmall:     TextStyle(color: r.text,  fontWeight: FontWeight.w500),
        bodyLarge:      TextStyle(color: r.text),
        bodyMedium:     TextStyle(color: r.text),
        bodySmall:      TextStyle(color: r.hint),
        labelLarge:     TextStyle(color: r.label, fontWeight: FontWeight.w600),
        labelMedium:    TextStyle(color: r.label),
        labelSmall:     TextStyle(color: r.hint),
      ),

      iconTheme:        IconThemeData(color: r.icon,       size: 24),
      primaryIconTheme: IconThemeData(color: r.buttonText, size: 24),

      // ✅ fixed: was Colors.white
      cardTheme: CardThemeData(
        color:     r.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: r.hint.withOpacity(0.12)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: r.textField,
        selectedColor:   r.main.withOpacity(0.15),
        labelStyle: TextStyle(color: r.hint, fontSize: 12),
        side:  BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),

      dividerTheme: DividerThemeData(
        color: r.hint.withOpacity(0.2), thickness: 1, space: 1,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color:            r.main,
        linearTrackColor: r.main.withOpacity(0.15),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A2E),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor:  r.sub,
        behavior:  SnackBarBehavior.floating,
        shape:     RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      r.card,
        selectedItemColor:    r.main,
        unselectedItemColor:  r.hint,
        selectedLabelStyle:   TextStyle(color: r.main, fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(color: r.hint, fontSize: 11),
        elevation: 8,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:  r.card,
        indicatorColor:   r.main.withOpacity(0.12),
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? IconThemeData(color: r.main,  size: 24)
            : IconThemeData(color: r.hint,  size: 24)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? TextStyle(color: r.main, fontSize: 11, fontWeight: FontWeight.w600)
            : TextStyle(color: r.hint, fontSize: 11)),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor:           r.main,
        unselectedLabelColor: r.hint,
        indicatorColor:       r.main,
        indicatorSize:        TabBarIndicatorSize.label,
        labelStyle:           const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: r.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle:   TextStyle(color: r.text, fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: r.hint, fontSize: 14),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor:     Colors.transparent,
        modalBackgroundColor: r.card,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: r.hint.withOpacity(0.4),
      ),

      listTileTheme: ListTileThemeData(
        tileColor:         Colors.transparent,
        selectedTileColor: r.main.withOpacity(0.08),
        iconColor:         r.icon,
        textColor:         r.text,
        selectedColor:     r.main,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? r.buttonText : r.hint),
        trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? r.main : r.hint.withOpacity(0.3)),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? r.main : Colors.transparent),
        checkColor: WidgetStateProperty.all(r.buttonText),
        side: BorderSide(color: r.hint, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? r.main : r.hint),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color:            r.card,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: r.sub.withOpacity(0.15)),
        ),
        textStyle: TextStyle(color: r.text, fontSize: 14),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor:  r.card,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          fontSize: 12, fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        preferBelow: false,
      ),

      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(r.textField),
        shadowColor:     WidgetStateProperty.all(Colors.transparent),
        overlayColor:    WidgetStateProperty.all(r.main.withOpacity(0.05)),
        side: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.focused)
            ? BorderSide(color: r.main, width: 1.8)
            : BorderSide(color: r.sub.withOpacity(0.3))),
        shape:     WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        textStyle: WidgetStateProperty.all(TextStyle(color: r.text, fontSize: 14)),
        hintStyle: WidgetStateProperty.all(TextStyle(color: r.hint, fontSize: 14)),
      ),

      badgeTheme: BadgeThemeData(
        backgroundColor: r.button,
        textColor:       r.buttonText,
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        padding:   const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    );
  }
}
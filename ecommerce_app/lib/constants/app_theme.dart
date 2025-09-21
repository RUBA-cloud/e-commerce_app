// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Your brand colors (edit as needed)
  static const _primary = Color(0xFF1D5D9B);
  static const _secondary = Color(0xFFFF9149);

  static final ColorScheme _lightScheme = const ColorScheme.light().copyWith(
    primary: _primary,
    secondary: _secondary,
    surface: Colors.white,
    error: const Color(0xFFE53935),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFF1A1C1E),
    // ignore: deprecated_member_use
    onBackground: const Color(0xFF1A1C1E),
    onError: Colors.white,
  );

  static final ColorScheme _darkScheme = const ColorScheme.dark().copyWith(
    primary: _primary,
    secondary: _secondary,
    surface: const Color(0xFF121417),
    error: const Color(0xFFEF5350),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFFE6E8EB),
    onError: Colors.black,
  );

  static ThemeData get light => _base(_lightScheme);
  static ThemeData get dark => _base(_darkScheme);

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        // ignore: deprecated_member_use
        selectionColor: scheme.primary.withOpacity(.25),
        selectionHandleColor: scheme.primary,
      ),
    );
  }
}

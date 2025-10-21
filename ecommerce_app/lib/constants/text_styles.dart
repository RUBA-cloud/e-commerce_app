// app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// All styles scale with .sp and use ColorScheme, so they work in light & dark.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(BuildContext context) => TextStyle(
        fontSize: 34.sp, // big headers
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headline(BuildContext context) => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle title(BuildContext context) => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        height: 1.35,
        // ignore: deprecated_member_use
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.90),
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.45,
        // ignore: deprecated_member_use
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.90),
      );

  static TextStyle bodyMuted(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.45,
        // ignore: deprecated_member_use
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        height: 1.35,
        // ignore: deprecated_member_use
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.60),
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: .2,
        color: Theme.of(context).colorScheme.onPrimary,
      );

  static TextStyle link(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        color: Theme.of(context).colorScheme.primary,
      );

  static TextStyle success(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2E7D32), // optional fixed positive
      );

  static TextStyle error(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.error,
      );
}

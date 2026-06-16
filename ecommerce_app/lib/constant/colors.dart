import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/utility/ui_utility.dart'; // needed for Colors.black/white/grey

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

  factory ColorHelper.fromCompany(CompanyColors c, bool isDark) =>
      ColorHelper(
        bg: isDark
            ? Color.lerp(c.card, Colors.black, 0.3)!
            : Color.lerp(c.card, Colors.white, 0.6)!,
        card: c.card,
        input: c.textField,
        border: Color.lerp(c.sub, Colors.grey, 0.5)!.withOpacity(0.3),
        primary: c.main,
        blob2: c.sub,
        text: c.text,
        subText: c.hint,
        label: c.label,
        buttonText: c.buttonText,
        divider: c.sub.withOpacity(0.2),
        error: isDark
            ? const Color(0xFFFF7675)
            : const Color(0xFFE24B4A),
        icon: c.icon,
      );
}
import 'package:flutter/material.dart';

/// أيقونة مع دائرة فوقها فيها عدد العناصر
class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool selected;

  const BadgeIcon({
    super.key,
    required this.icon,
    required this.count,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // لو ما في عناصر، نرجع الأيقونة عادي بدون دائرة
    if (count <= 0) {
      return Icon(
        icon,
        color: selected
            ? theme.colorScheme.primary
            : theme.iconTheme.color,
      );
    }

    final String display =
        count > 99 ? '99+' : count.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          color: selected
              ? theme.colorScheme.primary
              : theme.iconTheme.color,
        ),
        Positioned(
          // فوق الأيقونة على اليمين
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Center(
              child: Text(
                display,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

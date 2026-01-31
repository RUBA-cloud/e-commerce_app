import 'package:ecommerce_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class CircleActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
     

  const CircleActionIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);

      final colorScheme = theme.colorScheme;

    final Color searchBackground = Get.isDarkMode
        // ignore: deprecated_member_use
        ? colorScheme.surfaceContainerHighest.withOpacity(0.35)
        : colorScheme.surface;
    return Material(
      color: searchBackground,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: redColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}

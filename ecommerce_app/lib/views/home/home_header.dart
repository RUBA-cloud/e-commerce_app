

import 'package:ecommerce_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeHeader extends StatelessWidget {

  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final hiText = 'home_hi'.tr;
    final subText = 'home_subtitle'.tr;
        final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

final Color searchBackground = Get.isDarkMode
        // ignore: deprecated_member_use
        ? colorScheme.surfaceContainerHighest.withOpacity(0.35)
        : colorScheme.surface;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                 CrossAxisAlignment.start,
            children: [
              Text(
                hiText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: searchBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: const BoxDecoration(
                        color: redColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
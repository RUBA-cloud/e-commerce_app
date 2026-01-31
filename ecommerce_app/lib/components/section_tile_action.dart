
import 'package:ecommerce_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectionTitleWithAction extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onTap;

  const SectionTitleWithAction({super.key, 
    required this.title,
    required this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 12,
                color: redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:ecommerce_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OffersHeader extends StatelessWidget {
  final bool isArabic;

  const OffersHeader({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final title = 'home_promo_title'.tr;
    final subtitle = 'home_promo_subtitle'.tr;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [redColor, Color(0xFFFF8A80)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            // ignore: deprecated_member_use
            color: redColor.withOpacity(0.3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        'home_shop_now'.tr,
                        style: const TextStyle(
                          color: redColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: SizedBox.expand(
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }}
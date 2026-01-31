
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyWidget extends StatelessWidget {
  final IconData iconData;
final String? titleText;
  const EmptyWidget({super.key, this.titleText,required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              Get.locale!.languageCode =="ar" ? CrossAxisAlignment.end : CrossAxisAlignment.center,
          children: [
            Icon(iconData, size: 64),
            const SizedBox(height: 12),
            Text(titleText!,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('browse_products_hint'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

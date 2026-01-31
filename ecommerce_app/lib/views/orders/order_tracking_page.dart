// lib/pages/orders/order_page_tracking.dart
// ignore_for_file: deprecated_member_use

import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/constants/shared_decorations.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/order_status_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ✅ MAIN PAGE (Stateless)
class OrderPageTracking extends StatelessWidget {
  const OrderPageTracking({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel order = Get.arguments as OrderModel;
    final theme = Theme.of(context);
    final isArabic = Get.locale?.languageCode == 'ar';
    final accent = theme.colorScheme.primary;

    final int rawStatus = order.status ;
    final int status = rawStatus.clamp(0, 3); // 0..3

    final steps = [
      'order_step_placed'.tr,
      'order_step_processing'.tr,
      'order_step_out_for_delivery'.tr,
      'order_step_delivered'.tr,
    ];

    // ✅ shipped value in your backend (عدلها حسب الباك اند)
    final bool isShipped = rawStatus == 3;

    // ✅ transpartation object (key: trnasparation / transpartation)
    final tp = order.transpartation; // عدّليها لو اسم الحقل مختلف

    final countryName = pickName(isArabic, tp?.country);
    final cityName = pickName(isArabic, tp?.city);
    final typeName = pickName(isArabic, tp?.type);

    final wayName = isArabic
        ? (tp?.nameAr ?? tp?.nameEn ?? '-')
        : (tp?.nameEn ?? tp?.nameAr ?? '-');

    final daysCount = tp?.daysCount?.toInt();

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: whiteColor,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      elevation: 0,
    );

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ======= HEADER + STEPPER =======
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment:
                      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'order_tracking_title'.tr,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    trackingStepper(context: context, currentStep: status),
                  ],
                ),
              ),

              // ======= BODY =======
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---- Summary card ----
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: setBoxDecoration(
                              color: accent,
                              boxShape: BoxShape.rectangle,
                              radius: 22,
                              opacity: 1,
                            ).copyWith(
                              color: whiteColor,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 52,
                                  width: 52,
                                  decoration: setBoxDecoration(
                                    color: accent,
                                    boxShape: BoxShape.circle,
                                    opacity: 0.12,
                                  ),
                                  child: Icon(
                                    iconFromCodePoint(order.orderStatusModel!.iconData),
                                  
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${'order_number'.tr} #${order.id}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'order_step_desc_$status'.tr,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                statusPill(
                                  context: context,
                                  status: order.orderStatusModel,
                                ),
                              ],
                            ),
                          ),

                          // ✅ Shipment details (ONLY when shipped)
                          if (isShipped) ...[
                            const SizedBox(height: 16),
                            shipmentCard(
                              accent: accent,
                              theme: theme,
                              isArabic: isArabic,
                              wayName: wayName,
                              countryName: countryName,
                              cityName: cityName,
                              typeName: typeName,
                              daysCount: daysCount,
                            ),
                          ],

                          const SizedBox(height: 24),

                          Text(
                            'order_tracking_title'.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'order_placed_subtitle'.trParams({'id': '#${order.id ?? ''}'}),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ---- Vertical timeline steps ----
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: steps.length,
                            itemBuilder: (context, index) {
                              final bool isActive = index <= status;
                              final bool isCurrent = index == status;
                              final bool isLast = index == steps.length - 1;

                              return trackingStepItem(
                                index: index,
                                title: steps[index],
                                description: 'order_step_desc_$index'.tr,
                                isActive: isActive,
                                isCurrent: isCurrent,
                                isLast: isLast,
                                accent: accent,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ======= BOTTOM BUTTON =======
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () => Get.back(),
                    child: Text(
                      status >= 3
                          ? 'order_continue_shopping'.tr
                          : 'order_tracking_button'.tr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ helper: pick name_en/name_ar from either Model or Map
String pickName(bool isArabic, dynamic obj) {
  if (obj == null) return '-';

  // If it's a Map
  if (obj is Map<String, dynamic>) {
    final en = obj['name_en']?.toString();
    final ar = obj['name_ar']?.toString();
    return isArabic ? (ar ?? en ?? '-') : (en ?? ar ?? '-');
  }

  // If it's a model with fields nameEn/nameAr
  try {
    final en = (obj.nameEn ?? obj.name_en)?.toString();
    final ar = (obj.nameAr ?? obj.name_ar)?.toString();
    return isArabic ? (ar ?? en ?? '-') : (en ?? ar ?? '-');
  } catch (_) {
    return obj.toString();
  }
}

/// ===============================
/// Widgets (pure functions)
/// ===============================

Widget trackingStepper({required BuildContext context, required int currentStep}) {
  final theme = Theme.of(context);
  final accent = theme.colorScheme.primary;
  final grey = Colors.grey[400];

  Widget dot(bool active) => Container(
        height: 18,
        width: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? accent : Colors.transparent,
          border: Border.all(
            color: active ? accent : (grey ?? Colors.grey),
            width: 1.4,
          ),
        ),
        child: active ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
      );

  Widget step(String label, bool active) => Expanded(
        child: Column(
          children: [
            dot(active),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  return Row(
    children: [
      step('order_step_placed'.tr, currentStep >= 0),
      Container(height: 1, width: 16, color: grey, margin: const EdgeInsets.symmetric(horizontal: 4)),
      step('order_step_processing'.tr, currentStep >= 1),
      Container(height: 1, width: 16, color: grey, margin: const EdgeInsets.symmetric(horizontal: 4)),
      step('order_step_out_for_delivery'.tr, currentStep >= 2),
      Container(height: 1, width: 16, color: grey, margin: const EdgeInsets.symmetric(horizontal: 4)),
      step('order_step_delivered'.tr, currentStep >= 3),
    ],
  );
}

Widget shipmentCard({
  required Color accent,
  required ThemeData theme,
  required bool isArabic,
  required String wayName,
  required String countryName,
  required String cityName,
  required String typeName,
  required int? daysCount,
}) {
  Widget chip({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: setBoxDecoration(
        color: accent,
        boxShape: BoxShape.rectangle,
        radius: 16,
        opacity: 0.06,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: setBoxDecoration(
      color: accent,
      boxShape: BoxShape.rectangle,
      radius: 22,
      opacity: 1,
      border: Border.all(color: accent.withOpacity(0.14)),
    ).copyWith(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withOpacity(0.10),
          Colors.white,
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: setBoxDecoration(
                color: accent,
                boxShape: BoxShape.circle,
                opacity: 0.14,
              ),
              child: Icon(Icons.route_rounded, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'shipment_details'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            chip(icon: Icons.local_shipping_rounded, title: 'transportation_way'.tr, value: wayName),
            chip(icon: Icons.public_rounded, title: 'country'.tr, value: countryName),
            chip(icon: Icons.location_city_rounded, title: 'city'.tr, value: cityName),
            chip(icon: Icons.category_rounded, title: 'type'.tr, value: typeName),
            chip(icon: Icons.timelapse_rounded, title: 'days'.tr, value: daysCount?.toString() ?? '-'),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          isArabic
              ? 'سيتم توصيل طلبك حسب بيانات الشحن أعلاه.'
              : 'Your order will be delivered based on the shipment info above.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[700],
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget trackingStepItem({
  required int index,
  required String title,
  required String description,
  required bool isActive,
  required bool isCurrent,
  required bool isLast,
  required Color accent,
}) {
  return Builder(builder: (context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive ? accent : Colors.grey.shade300,
              child: Icon(
                isActive ? Icons.check : Icons.circle,
                size: 14,
                color: isActive ? Colors.white : Colors.grey[500],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isActive ? accent : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: setBoxDecoration(
              color: accent,
              boxShape: BoxShape.rectangle,
              radius: 14,
              opacity: isCurrent ? 0.06 : 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                    color: isActive ? accent : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  });
}

Widget statusPill({
  required BuildContext context,
  required OrderStatusModel? status,
}) {
  final theme = Theme.of(context);

  if (status == null) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: setBoxDecoration(
        color: Colors.grey,
        boxShape: BoxShape.rectangle,
        radius: 30,
        opacity: 0.08,
      ).copyWith(color: Colors.grey.shade300),
      child: Text(
        '-',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  final color = parseHexColor(status.color);
  final isArabic = Get.locale?.languageCode == 'ar';

  final label = isArabic
      ? (status.nameAr ?? status.nameEn ?? '-')
      : (status.nameEn ?? status.nameAr ?? '-');

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: setBoxDecoration(
      color: color,
      boxShape: BoxShape.rectangle,
      radius: 30,
      opacity: 0.08,
    ).copyWith(color: color),
    child: Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    ),
  );
}

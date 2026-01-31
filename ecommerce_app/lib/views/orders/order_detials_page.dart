// lib/pages/orders/order_details_page.dart
// ignore_for_file: deprecated_member_use

import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/constants/shared_decorations.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/order_status_model.dart';
import 'package:ecommerce_app/views/orders/cubit/orders_cubit.dart';
import 'package:ecommerce_app/views/orders/cubit/orders_state.dart';
import 'package:ecommerce_app/views/orders/order_invoice.dart';
import 'package:ecommerce_app/views/orders/order_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// ✅ Main page: StatelessWidget
class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel order = Get.arguments as OrderModel;

    final theme = Theme.of(context);
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    final items = order.items;
    final createdAtText = order.createdAt.toString();

    final bool isCompleted = (order.status) == 2;
    final bool isDraft = (order.status) == -1;

    final Color accent = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: BlocProvider(
          create: (_) => OrdersCubit(),
          child: BlocConsumer<OrdersCubit, OrdersState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (_, __) {},
            builder: (context, state) {
              return Column(
                children: [
                  // ========= TOP BAR + STEPPER =========
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
                              'order_details_title'.tr,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        checkoutStepper(context: context, status: order.status),
                      ],
                    ),
                  ),

                  // ========= BODY =========
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
                              // ----- Hero status card -----
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: setBoxDecoration(
                                  color: accent,
                                  boxShape: BoxShape.rectangle,
                                  radius: 24,
                                  opacity: 1,
                                  border: Border.all(
                                    color: accent.withOpacity(0.3),
                                    width: 1.2,
                                  ),
                                ).copyWith(
                                  gradient: LinearGradient(
                                    colors: [
                                      accent.withOpacity(isDark ? 0.35 : 0.12),
                                      accent.withOpacity(isDark ? 0.15 : 0.02),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 72,
                                      width: 72,
                                      decoration: setBoxDecoration(
                                        color: theme.colorScheme.onPrimary,
                                        boxShape: BoxShape.circle,
                                        opacity: 0.08,
                                      ),
                                      child: Icon(
                                        isCompleted
                                            ? Icons.check_circle_rounded
                                            : Icons.schedule_rounded,
                                        color: theme.colorScheme.onPrimaryContainer,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      isCompleted
                                          ? 'order_placed_title'.tr
                                          : 'order_in_progress_title'.tr,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'order_placed_subtitle'.trParams({
                                        'id': '#${order.id ?? ''}',
                                      }),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),

                                    // ✅ guard: orderStatusModel nullable
                                    if (order.orderStatusModel != null)
                                      statusChip(
                                        context: context,
                                        canContinue: !isCompleted && !isDraft,
                                        status: order.orderStatusModel!,
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ----- Order info card -----
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: setBoxDecoration(
                                  color: theme.colorScheme.outline,
                                  boxShape: BoxShape.rectangle,
                                  radius: 20,
                                  opacity: 0.04,
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.15),
                                  ),
                                  boxShadow: isDark
                                      ? const []
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ).copyWith(
                                  color: isDark
                                      ? theme.colorScheme.surfaceContainerHigh
                                      : theme.colorScheme.surface,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${'order_number_label'.tr} #${order.id}',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  createdAtText,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          (order.totalPrice ).toStringAsFixed(2),
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: accent,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),
                                    const Divider(height: 18),

                                    addressSection(order: order, context: context),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        const Icon(Icons.credit_card_outlined, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'order_payment_method_value'.tr,
                                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ----- Items List -----
                              Row(
                                children: [
                                  const Icon(Icons.shopping_bag_outlined),
                                  const SizedBox(width: 6),
                                  Text(
                                    'order_items_title'.tr,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'order_items_count'.trParams({'count': '${items.length}'}),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              if (items.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text('order_items_empty'.tr,
                                      style: theme.textTheme.bodyMedium),
                                )
                              else
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final productName =
                                        item.product?.nameAr ??
                                        item.product?.nameEn ??
                                        '${'order_item_product'.tr} #${item.productId}';

                                    return orderItemRow(
                                      context: context,
                                      item: item,
                                      productName: productName,
                                    );
                                  },
                                ),

                              const SizedBox(height: 24),

                              // ----- Bottom actions -----
                              Row(
                                children: [
                                order.status==0?   Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: () {
                                        context.read<OrdersCubit>().sendOrder(order,order.cartId??0, context,);
                                      },
                                      child: Text(
                                        'order_continue_shopping'.tr,
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ):SizedBox(),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accent,
                                        foregroundColor: whiteColor,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        if (isDraft) {
                                          context.read<OrdersCubit>().sendOrder(order,order.cartId??0 ,context);
                                        } else {
                                          Get.to(
                                            () => const OrderPageTracking(),
                                            arguments: order,
                                          );
                                        }
                                      },
                                      child: Text(
                                        'order_track'.tr,
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          color: whiteColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Get.to(
                                      () => const OrderInvoicePdfPage(),
                                      arguments: order,
                                    );
                                  },
                                  icon: const Icon(Icons.picture_as_pdf_outlined),
                                  label: Text('order_invoice_button'.tr),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// =========================
/// ✅ PURE widget functions (no Stateful/Stateless)
/// =========================

Widget addressSection({required OrderModel order, required BuildContext context}) {
  final theme = Theme.of(context);

  final String address = order.address;
  final String street = order.streetName ;
  final String building = order.buildingNumber ;

  final bool hasAddress = address.isNotEmpty;

  if (!hasAddress && street.isEmpty && building.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: setBoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      boxShape: BoxShape.rectangle,
      radius: 16,
      opacity: 0.40,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: setBoxDecoration(
            color: theme.colorScheme.primary,
            boxShape: BoxShape.circle,
            opacity: 0.12,
          ),
          child: Icon(
            Icons.location_on_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'address'.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (building.isNotEmpty)
                    addressChip(
                      label: '${'order_building_number'.tr} $building',
                      icon: Icons.home_outlined,
                      context: context,
                    ),
                  if (street.isNotEmpty)
                    addressChip(
                      label: '${'order_street_name'.tr} $street',
                      icon: Icons.route_outlined,
                      context: context,
                    ),
                ],
              ),
              if (hasAddress) ...[
                const SizedBox(height: 8),
                Text(
                  address,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget addressChip({
  required String label,
  required IconData icon,
  required BuildContext context,
}) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: setBoxDecoration(
      color: theme.colorScheme.surface,
      boxShape: BoxShape.rectangle,
      radius: 999,
      opacity: 0.80,
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.30),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget orderItemRow({
  required OrderItemModel item,
  required String productName,
  required BuildContext context,
}) {
  final theme = Theme.of(context);
  final accent = theme.colorScheme.primary;
  final isDark = theme.brightness == Brightness.dark;

  final Color? colorValue =
      item.convertedColor ?? convertColorsFromStringToHex(item.color);

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: setBoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      boxShape: BoxShape.rectangle,
      radius: 16,
      opacity: isDark ? 0.35 : 0.70,
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.25),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: accent.withOpacity(0.12),
          child: Text(
            'x${item.quantity}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(productName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              if (colorValue != null)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    itemInfoChip(
                      label: '${'order_item_color'.tr}:',
                      icon: Icons.palette_outlined,
                      context: context,
                    ),
                    Container(
                      height: 26,
                      width: 26,
                      decoration: setBoxDecoration(
                        color: Colors.transparent,
                        boxShape: BoxShape.circle,
                        opacity: 1,
                        border: Border.all(
                          color: isDark
                              ? whiteColor.withOpacity(0.85)
                              : blackColor.withOpacity(0.15),
                          width: 1.4,
                        ),
                      ).copyWith(color: colorValue),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${'order_item_price'.tr}: ${item.price}',
                    style: theme.textTheme.bodySmall,
                  ),
            item.size!=null?       Text(
                   '${'order_item_size'.tr}: ${item.size!.nameEn}',
                    style: theme.textTheme.bodySmall,
                  ):SizedBox(),
   if (item.additionalModel != null && item.additionalModel!.isNotEmpty)
 if (item.additionalModel != null && item.additionalModel!.isNotEmpty)
  Wrap(
    spacing: 6,
    runSpacing: 6,
    children: (item.product?.productsAdditonal ?? [])
        .map((e) {
          final isArabic = Get.locale?.languageCode == 'ar';

          final name = isArabic
              ? (e.nameAr ?? e.nameEn ?? '-')
              : (e.nameEn ?? e.nameAr ?? '-');

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: setBoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
            ),
            child: Text(
              name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          );
        })
        .toList(),
  ),



                
                   SizedBox(),
                  const SizedBox(width: 10),
                  Text(
                    '${'order_item_total'.tr}: ${item.totalPrice}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget itemInfoChip({
  required String label,
  required IconData icon,
  required BuildContext context,
}) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: setBoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      boxShape: BoxShape.rectangle,
      radius: 999,
      opacity: 0.60,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// ------- Stepper helpers -------
Widget dot({required bool active, required BuildContext context}) {
  final theme = Theme.of(context);
  final accent = theme.colorScheme.primary;

  return Container(
    height: 18,
    width: 18,
    decoration: setBoxDecoration(
      color: active ? accent : Colors.transparent,
      boxShape: BoxShape.circle,
      opacity: 1,

    ),
    child: active ? const Icon(Icons.check, size: 12, color:whiteColor) : null,
  );
}

Widget step({
  required String label,
  required bool active,
  required BuildContext context,
}) {
  final theme = Theme.of(context);

  return Expanded(
    child: Column(
      children: [
        dot(active: active, context: context),
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
}

Widget checkoutStepper({required BuildContext context, required int? status}) {
  final theme = Theme.of(context);
  final grey = theme.colorScheme.outline.withOpacity(0.5);

  final int s = status ?? -1;
  final bool addressDone = s >= 0;
  final bool paymentDone = s >= 1;
  final bool placedDone = s >= 2;

  return Row(
    children: [
      step(label: 'checkout_step_address'.tr, active: addressDone, context: context),
      Container(
        height: 1,
        width: 20,
        color: grey,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
      step(label: 'checkout_step_payment'.tr, active: paymentDone, context: context),
      Container(
        height: 1,
        width: 20,
        color: grey,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
      step(label: 'checkout_step_placed'.tr, active: placedDone, context: context),
    ],
  );
}

Widget statusChip({
  required bool canContinue,
  required OrderStatusModel status,
  required BuildContext context,
}) {
  final theme = Theme.of(context);

  final Color fg = parseHexColor(status.color);

  final String label = canContinue
      ? 'order_incomplete'.tr
      : (Get.locale?.languageCode == 'ar'
          ? (status.nameAr ?? '—')
          : (status.nameEn ?? '—'));

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: setBoxDecoration(
      color: fg,
      boxShape: BoxShape.rectangle,
      radius: 30,
      opacity: 0.10,
    ).copyWith(color: fg),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconFromCodePoint(status.iconData),
          size: 14,
          color: fg,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

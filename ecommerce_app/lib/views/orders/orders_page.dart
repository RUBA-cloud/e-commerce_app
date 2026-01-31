// ignore_for_file: deprecated_member_use

import 'package:ecommerce_app/components/empty_widget.dart';
import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/constants/shared_decorations.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/views/orders/cubit/orders_cubit.dart';
import 'package:ecommerce_app/views/orders/cubit/orders_state.dart';
import 'package:ecommerce_app/views/orders/order_detials_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// ✅ Main page stays StatelessWidget
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel? args = Get.arguments;

    return BlocProvider(
      create: (_) => OrdersCubit()..load(order: args),
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final isArabic = Get.locale?.languageCode == 'ar';
          final isDark = theme.brightness == Brightness.dark;

          final List<OrderModel> orders = state.orders;
          final double totalAllOrders =
              orders.fold(0.0, (sum, o) => sum + o.totalPrice);

          // ===== حالات تحميل / خطأ بسيطة =====
          if (state.status == OrderStatus.loading) {
            return Scaffold(
              appBar: AppBar(
                title: Text('my_orders_title'.tr),
                centerTitle: true,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == OrderStatus.error) {
            return Scaffold(
              appBar: AppBar(
                title: Text('my_orders_title'.tr),
                centerTitle: true,
              ),
              body: Center(
                child: Text(
                  state.error ?? 'error'.tr,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
            body: Container(
              decoration: setBoxDecoration(
                color: theme.colorScheme.primary,
                boxShape: BoxShape.rectangle,
                radius: 0,
                opacity: 0.0,
              ).copyWith(
                gradient: LinearGradient(
                  begin: isArabic ? Alignment.topRight : Alignment.topLeft,
                  end: isArabic ? Alignment.bottomLeft : Alignment.bottomRight,
                  colors: [
                    
                    theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.16),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ======= TOP BAR & SUMMARY CARD =======
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // AppBar style row
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'my_orders_title'.tr,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Summary card
                          Container(
                            width: double.infinity,
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
                                        color: blackColor.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ).copyWith(
                              color: isDark
                                  ? theme.colorScheme.surfaceContainerHigh
                                  : theme.colorScheme.surface,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // leading icon
                                Container(
                                  height: 52,
                                  width: 52,
                                  decoration: setBoxDecoration(
                                    color: theme.colorScheme.primary,
                                    boxShape: BoxShape.rectangle,
                                    radius: 18,
                                    opacity: 0.12,
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // title + count
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'my_orders_title'.tr,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${orders.length} ${'orders'.tr}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // total amount (optional)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'order_total'.tr,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      totalAllOrders.toStringAsFixed(2),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======= LIST SECTION =======
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(26),
                          topRight: Radius.circular(26),
                        ),
                        child: Container(
                          color: theme.colorScheme.surface,
                          child: orders.isEmpty
                              ? EmptyWidget(
                                  iconData: Icons.cabin,
                                  titleText: "empty_carts".tr,
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    return orderCardItem(order: order,context: context); // ✅ sub widget (Widget)
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ✅ other classes are Widget (not Stateless/Stateful)

  // ignore: non_constant_identifier_names
  Widget orderCardItem({ required  OrderModel order ,required BuildContext context}){

    final theme = Theme.of(context);
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    final canContinue = order.status == -1;
    final createdAtText = order.createdAt; // عندك string جاهز human
    final orderIdText = '#${order.id ?? ''}';
    final itemCount = order.items.length;

    // ✅ لون من orderStatusModel.color (Hex String)
    final statusColor = parseHexColor(
      order.orderStatusModel?.color,
      fallback: theme.colorScheme.primary,
    );

    final icon = iconFromCodePoint(order.orderStatusModel!.iconData) ;

    final cardBg = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surface;

    final borderColor = statusColor.withOpacity(isDark ? 0.55 : 0.35);
    final iconBg = statusColor.withOpacity(isDark ? 0.18 : 0.12);

    return GestureDetector(
      onTap: () => Get.to(() => const OrderDetailsPage(), arguments: order),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Card(
          color: cardBg,
          elevation: isDark ? 0 : 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: setBoxDecoration(
              color: cardBg,
              boxShape: BoxShape.rectangle,
              radius: 24,
              opacity: 1.0,
              border: Border.all(
                color: borderColor,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // ===== Header =====
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: setBoxDecoration(
                        color: statusColor,
                        boxShape: BoxShape.circle,
                        opacity: 0.0,
                      ).copyWith(
                        color: iconBg,
                      ),
                      child: Icon(
                        icon,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'order_number'.tr} $orderIdText',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            createdAtText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // badge status (اختياري)
                    if (order.orderStatusModel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(isDark ? 0.18 : 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          isArabic
                              ? (order.orderStatusModel!.nameAr ?? '')
                              : (order.orderStatusModel!.nameEn ?? ''),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ===== Total row =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          'order_total'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.totalPrice.toStringAsFixed(2),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                        child: Text(
                          'order_items_count'.trParams({'count': '$itemCount'}),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: isArabic ? TextAlign.left : TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ===== Actions =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.4),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => const OrderDetailsPage(), arguments: order);
                        },
                        child: Text(
                          'order_view_details'.tr,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: setButtonStyle(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          if (canContinue) {
                            context.read<OrdersCubit>().sendOrder(order,order.cartId??0, context);
                          } else {
                            Get.to(() => const OrderDetailsPage(), arguments: order);
                          }
                        },
                        child: Text(
                          canContinue ? 'order_continue'.tr : 'order_track'.tr,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


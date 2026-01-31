// lib/views/cartItemPage/summary_total_bar/summary_total_bar.dart
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_cubit.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SummaryBar extends StatelessWidget {
  final CartCubit cartCubit;

  const SummaryBar({
    super.key,
    required this.cartCubit,
  });

  double _unitPrice(CartModel line) {
    // نفس منطق الكارد: سعر الحجم إن وجد، وإلا سعر المنتج
    if (line.sizeData.price != null) {
      return line.sizeData.price!;
    }
    return line.unitPrice;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CartCubit, CartState>(
      // نعيد البناء عند تغيّر العناصر أو حالة التحديد
      buildWhen: (prev, curr) =>
          prev.items != curr.items ||
          prev.allSelected != curr.allSelected,
      builder: (context, state) {
        if (state.items.isEmpty) {
          // لا تعرض البار إذا السلة فاضية
          return const SizedBox.shrink();
        }

        // ✅ العناصر المحددة فقط
        final selectedLines =
            state.items.where((e) => e.selected == true).toList();

        // ✅ مجموع التوتال للعناصر المحددة فقط
        final double total = selectedLines.fold<double>(
          0.0,
          (sum, line) => sum + _unitPrice(line) * line.quantity,
        );

        final int selectedCount = selectedLines.length;
        final bool hasSelection = selectedCount > 0;

        return Material(
          elevation: 8,
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // معلومات التوتال
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'total'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total.toStringAsFixed(2),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // مثلاً: "3 items selected"
                        'selected_items'
                            .trArgs([selectedCount.toString()]),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // زر إتمام الطلب (فقط عند وجود عناصر محددة)
                  FilledButton.icon(
                    onPressed: hasSelection
                        ? () =>
                            Get.toNamed(AppRoutes.addressPage,arguments: state.items)
                          
                        : null,
                    icon: const Icon(Icons.payments_outlined),
                    label: Text('checkout'.tr),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

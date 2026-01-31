import 'package:ecommerce_app/components/empty_widget.dart';
import 'package:ecommerce_app/components/error_widegt.dart';
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/constants/shared_decorations.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_cubit.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_state.dart';
import 'package:ecommerce_app/views/cartItemPage/summary_total_bar/summary_total_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      appBar: AppBar(
        elevation: 0,
        title: Text("cart_item".tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<CartCubit, CartState>(
          listenWhen: (previous, current) =>
              previous.status != current.status,
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.items != current.items ||
              previous.allSelected != current.allSelected ||
              previous.error != current.error,
          listener: (context, state) {
            if (state.status == CartStatus.newItemAdded) {
              // يمكنكِ إضافة Toast أو SnackBar هنا لو حبيتي
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case CartStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case CartStatus.error:
                return ErrorWidegt(
                  message: state.error ?? 'error'.tr,
                  onRetry: () => context.read<CartCubit>().load(),
                );

              case CartStatus.idle:
              case CartStatus.loaded:
              case CartStatus.removeItem:
              case CartStatus.newItemAdded:
              case CartStatus.success:
                final hasItems = state.items.isNotEmpty;
                return _bodyList(context, state, hasItems, isAr);
            }
          },
        ),
      ),
    );
  }

  Widget _bodyList(
    BuildContext context,
    CartState state,
    bool hasItems,
    bool isAr,
  ) {
    final theme = Theme.of(context);
    final cartCubit = context.read<CartCubit>();

    return Column(
      children: [
        // ===== الجزء العلوي (Select All + عدد العناصر) =====
        if (hasItems)
          Material(
            color: theme.colorScheme.surface,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: state.allSelected,
                    onChanged: (v) =>
                        cartCubit.toggleSelectAll(v ?? false),
                  ),
                  Text(
                    'select_all'.tr,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration:setBoxDecoration(
                      
                      // ignore: deprecated_member_use
                      color: theme.colorScheme.primary.withOpacity(0.08),),
                     
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${state.items.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ===== القائمة + الخلفية المنحنية =====
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: hasItems
                ? ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final line = state.items[i];
                      return Dismissible(
                        key: ValueKey('cart_${line.id}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            cartCubit.removeItem(line.id!),
                        background: const SizedBox.shrink(),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.delete_forever_rounded,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        child: _CartItemCard(
                          cubit: cartCubit,
                          isAr: isAr,
                          line: line,
                        ),
                      );
                    },
                  )
                : Center(
                    child: EmptyWidget(
                      iconData: Icons.shopping_cart_outlined,
                      titleText: 'cart_empty'.tr,
                    ),
                  ),
          ),
        ),

        // ===== شريط الملخص =====
        SummaryBar(cartCubit: cartCubit),
      ],
    );
  }
}

/// =======================
/// CART ITEM CUSTOM CARD
/// =======================

class _CartItemCard extends StatelessWidget {
  final CartCubit cubit;
  final bool isAr;
  final CartModel line;

  const _CartItemCard({
    required this.cubit,
    required this.isAr,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = line.product?.mainImage;

    // السعر حسب الحجم إن وجد، وإلا سعر المنتج
    final double unitPrice;
    if (line.sizeData.price != null) {
      unitPrice = line.sizeData.price!;
    } else {
      unitPrice = line.unitPrice;
    }
    final double lineTotal = unitPrice * line.quantity;

    final sizeName = isAr
        ? (line.sizeData.nameAr )
        : (line.sizeData.nameEn );

    final sizeDesc = isAr
        ? (line.sizeData.descriptionAr )
        : (line.sizeData.descriptionEn );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>Get.toNamed(AppRoutes.details,arguments: line), // ممكن تفتحي صفحة تفاصيل المنتج لاحقاً
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: line.selected
                  // ignore: deprecated_member_use
                  ? theme.colorScheme.primary.withOpacity(.35)
                  // ignore: deprecated_member_use
                  : theme.colorScheme.outline.withOpacity(.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox + صورة المنتج
                Column(
                  children: [
                    Checkbox(
                      value: line.selected,
                      onChanged: (_) => cubit.toggleSelect(line.id!),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: image == null
                            ? Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: theme.colorScheme.outline,
                                ),
                              )
                            : Image.network(
                                image,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // النصوص + الحجم + اللون + السعر + الكمية
                Expanded(
                  child: Column(
                    crossAxisAlignment: isAr
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // اسم المنتج
                      Text(
                        isAr
                            ? (line.product?.nameAr ?? '')
                            : (line.product?.nameEn ?? ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (sizeDesc.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          sizeDesc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if(line.additional.isNotEmpty)...[
                          Wrap(
    children: line.additional
        .map((e) => Text (isAr?e.nameAr!:e.nameEn!,style: setTextStyle(fontSize: 13),),) // أو e.name / e.title حسب موديلك
        .toList(),
  ),
                        ]
                      ],
                      const SizedBox(height: 6),
 
                      // الحجم + اللون
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sizeName.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: setBoxDecoration(color: theme.colorScheme
                                    .surfaceContainerHighest,
                                    radius: 12,),
                                    // ignore: deprecated_member_use
                                    
                            
                              child: Text(
                                sizeName,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: 
                            BoxDecoration(
                              shape: BoxShape.circle,
                              color: line.parsedColor,
                              border: Border.all(
                                color: theme.colorScheme.outline,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // السعر + الكمية
                      Row(
                        children: [
                          // سعر السطر (total)
                          Column(
                            crossAxisAlignment: isAr
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                _money(lineTotal),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                '${_money(unitPrice)} × ${line.quantity}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // stepper
                          _QuantityStepper(
                            cubit: cubit,
                            model: line,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // زر الحذف
                IconButton(
                  tooltip: 'remove'.tr,
                  onPressed: () => cubit.removeItem(line.id!),
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _money(double v) => v.toStringAsFixed(2);
}

class _QuantityStepper extends StatelessWidget {
  final CartCubit cubit;
  final CartModel model;

  const _QuantityStepper({
    required this.cubit,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

    return Container(
      decoration: ShapeDecoration(
        shape: shape,
        // ignore: deprecated_member_use
        color: theme.colorScheme.surfaceVariant.withOpacity(.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(
            icon: Icons.remove,
            onTap: () => cubit.decreaseQuantity(model),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              model.quantity.toString(),
              style: theme.textTheme.titleSmall,
            ),
          ),
          _stepBtn(
            icon: Icons.add,
            onTap: () => cubit.increaseQuantity(model),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

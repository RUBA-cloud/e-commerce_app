// lib/views/cart/cart_page.dart

import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_cubit.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';

    return BlocProvider(
      create: (_) => CartCubit()..load(),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          switch (state.status) {
            case CartStatus.loading:
              return const _CartLoading();
            case CartStatus.error:
              return _CartError(
                message: state.error ?? 'error'.tr,
                onRetry: () => context.read<CartCubit>().load(),
              );
            case CartStatus.idle:
            case CartStatus.success:
              final hasItems = state.lines.isNotEmpty;
              return Column(
                children: [
                  if (hasItems)
                    _SelectAllBar(
                      isChecked: state.allSelected,
                      onChanged: (v) =>
                          context.read<CartCubit>().toggleSelectAll(v ?? false),
                    ),
                  Expanded(
                    child: hasItems
                        ? ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: state.lines.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, i) {
                              final line = state.lines[i];
                              return Dismissible(
                                key: ValueKey('cart_${line.id}'),
                                direction: DismissDirection.endToStart,
                                background: const SizedBox.shrink(),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(ctx)
                                        .colorScheme
                                        .errorContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.delete_forever_rounded,
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .onErrorContainer),
                                ),
                                onDismissed: (_) => context
                                    .read<CartCubit>()
                                    .removeLine(line.id),
                                child: _CartItemCard(
                                  isAr: isAr,
                                  line: line,
                                  onToggleSelect: () => context
                                      .read<CartCubit>()
                                      .toggleSelect(line.id),
                                  onIncrease: () => context
                                      .read<CartCubit>()
                                      .increaseQty(line.id),
                                  onDecrease: () => context
                                      .read<CartCubit>()
                                      .decreaseQty(line.id),
                                  onDelete: () => context
                                      .read<CartCubit>()
                                      .removeLine(line.id),
                                ),
                              );
                            },
                          )
                        : _EmptyCartView(isAr: isAr),
                  ),
                  _SummaryBar(
                    subtotal: state.subtotal,
                    discount: state.discount,
                    shipping: state.shipping,
                    total: state.total,
                    canCheckout: state.lines.any((e) => e.selected),
                    onCheckout: () {
                      // TODO: navigate to checkout
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('proceed_checkout'.tr)),
                      );
                    },
                    onApplyCoupon: (code) =>
                        context.read<CartCubit>().applyCoupon(code),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _CartLoading extends StatelessWidget {
  const _CartLoading();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _CartError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _CartError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('failed_to_load'.tr,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr),
              ),
            ],
          ),
        ),
      );
}

class _SelectAllBar extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  const _SelectAllBar({required this.isChecked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Checkbox(value: isChecked, onChanged: onChanged),
            Text('select_all'.tr),
            const Spacer(),
            Icon(Icons.shopping_bag_outlined,
                size: 18, color: Theme.of(context).hintColor),
            const SizedBox(width: 6),
            // you can show selected count if needed
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final bool isAr;
  final CartLine line;
  final VoidCallback onToggleSelect;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.isAr,
    required this.line,
    required this.onToggleSelect,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = line.imageUrl;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // Select
            Checkbox(value: line.selected, onChanged: (_) => onToggleSelect()),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: image == null
                    ? Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.network(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    line.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (line.variant != null && line.variant!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        line.variant!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Price + qty stepper
                  Row(
                    children: [
                      Text(
                        _money(line.unitPrice),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      _QtyStepper(
                        qty: line.qty,
                        onMinus: onDecrease,
                        onPlus: onIncrease,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Delete
            IconButton(
              tooltip: 'remove'.tr,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  String _money(double v) => v.toStringAsFixed(2);
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyStepper(
      {required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Container(
      decoration: ShapeDecoration(
        shape: shape,
        color: theme.colorScheme.surfaceVariant.withOpacity(.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text('$qty', style: theme.textTheme.titleSmall),
          ),
          _StepBtn(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
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

class _SummaryBar extends StatefulWidget {
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final bool canCheckout;
  final void Function(String code) onApplyCoupon;
  final VoidCallback onCheckout;

  const _SummaryBar({
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.canCheckout,
    required this.onApplyCoupon,
    required this.onCheckout,
  });

  @override
  State<_SummaryBar> createState() => _SummaryBarState();
}

class _SummaryBarState extends State<_SummaryBar> {
  final _couponCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Coupon row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponCtrl,
                      decoration: InputDecoration(
                        hintText: 'enter_coupon'.tr,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => widget.onApplyCoupon(_couponCtrl.text),
                    child: Text('apply'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Totals
              _kv('subtotal'.tr, widget.subtotal),
              if (widget.discount > 0) _kv('discount'.tr, -widget.discount),
              _kv('shipping'.tr, widget.shipping),
              const Divider(height: 16),
              _kv('total'.tr, widget.total, isBold: true),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: widget.canCheckout ? widget.onCheckout : null,
                  child: Text('checkout'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, double v, {bool isBold = false}) {
    final style = isBold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(k),
          const Spacer(),
          Text(v >= 0 ? _money(v) : '-${_money(v.abs())}', style: style),
        ],
      ),
    );
  }

  String _money(double v) => v.toStringAsFixed(2);
}

class _EmptyCartView extends StatelessWidget {
  final bool isAr;
  const _EmptyCartView({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 64),
            const SizedBox(height: 12),
            Text('cart_empty'.tr,
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

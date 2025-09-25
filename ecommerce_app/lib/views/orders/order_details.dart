import 'package:ecommerce_app/models/additional_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;
  final void Function(ProductSummary)? onOpenProduct; // optional

  const OrderDetailsPage({
    super.key,
    required this.order,
    this.onOpenProduct,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('order_details'.tr), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeaderCard(isAr: isAr, order: order),
          const SizedBox(height: 16),
          _SectionLabel('products'.tr),
          const SizedBox(height: 8),

          // --- Product list ---
          ...order.items.map((p) => _ProductTile(
                isAr: isAr,
                p: p,
                onTap: () {
                  if (onOpenProduct != null) onOpenProduct!(p);
                },
              )),
          const SizedBox(height: 16),

          // --- Totals ---
          _SectionLabel('totals'.tr),
          const SizedBox(height: 8),
          _TotalsCard(order: order),
        ],
      ),
      bottomNavigationBar: _BottomActions(
        onTrack: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('tracking_not_implemented'.tr)),
          );
        },
        onInvoice: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('invoice_not_implemented'.tr)),
          );
        },
        onReorder: () {
          if (onOpenProduct != null && order.items.isNotEmpty) {
            onOpenProduct!(order.items.first);
          }
        },
      ),
    );
  }
}

// ====================== HEADER ======================

class _HeaderCard extends StatelessWidget {
  final bool isAr;
  final OrderModel order;

  const _HeaderCard({required this.isAr, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdStr =
        '${order.createdAt.year}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.day.toString().padLeft(2, '0')} '
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';
    final (label, color, icon) = _statusMeta(order.progress, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Row 1: code + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.code ?? order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(label: label, color: color, icon: icon),
              ],
            ),
            const SizedBox(height: 6),

            // Row 2: date + items count
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: theme.hintColor),
                const SizedBox(width: 6),
                Text(createdStr, style: theme.textTheme.bodySmall),
                const Spacer(),
                Icon(Icons.inventory_2_outlined,
                    size: 16, color: theme.hintColor),
                const SizedBox(width: 6),
                Text(
                  '${order.itemsCount} ${'items'.tr}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Customer
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: theme.hintColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(order.userName,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address
            Row(
              children: [
                Icon(Icons.place_outlined, size: 18, color: theme.hintColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(order.addressName,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, IconData) _statusMeta(OrderProgress s, ThemeData theme) {
    switch (s) {
      case OrderProgress.pending:
        return (
          'pending'.tr,
          theme.colorScheme.tertiary,
          Icons.hourglass_bottom
        );
      case OrderProgress.processing:
        return ('processing'.tr, Colors.blue, Icons.sync);
      case OrderProgress.shipped:
        return ('shipped'.tr, Colors.orange, Icons.local_shipping_outlined);
      case OrderProgress.delivered:
        return ('delivered'.tr, Colors.green, Icons.check_circle);
      case OrderProgress.cancelled:
        return ('cancelled'.tr, theme.colorScheme.error, Icons.cancel_outlined);
    }
  }
}

// ====================== PRODUCT TILE ======================

class _ProductTile extends StatelessWidget {
  final bool isAr;
  final ProductSummary p;
  final VoidCallback? onTap;

  const _ProductTile({required this.isAr, required this.p, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final extrasUnit = p.additionals.fold<double>(
      0.0,
      (prev, a) => prev + (a.price ?? 0.0),
    );
    final unitWithExtras = p.price + extrasUnit;
    final lineTotal = unitWithExtras * p.qty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: p.imageUrl == null
                      ? Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: const Icon(Icons.image_outlined),
                        )
                      : Image.network(p.imageUrl!, fit: BoxFit.cover),
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
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Meta row: qty, size, color
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _MetaChip(text: 'x${p.qty}'),
                        if (p.size != null && p.size!.isNotEmpty)
                          _MetaChip(
                              icon: Icons.straighten,
                              text: '${'size'.tr}: ${p.size}'),
                        if (p.colorHex != null)
                          _ColorChipDot(color: Color(p.colorHex!)),
                      ],
                    ),

                    // Additionals (chips)
                    if (p.additionals.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            p.additionals.map((a) => _AddOnChip(a)).toList(),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Prices row
                    Row(
                      children: [
                        Text('${'price_per_unit'.tr}: ${_money(p.price)}',
                            style: theme.textTheme.bodySmall),
                        if (extrasUnit > 0) ...[
                          const SizedBox(width: 10),
                          Text(
                            '+ ${'extras'.tr}: ${_money(extrasUnit)}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.hintColor),
                          ),
                        ],
                        const Spacer(),
                        Text('${'line_total'.tr}: ${_money(lineTotal)}',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _money(double v) => v.toStringAsFixed(2);
}

class _MetaChip extends StatelessWidget {
  final IconData? icon;
  final String text;
  const _MetaChip({this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: theme.hintColor),
            const SizedBox(width: 4),
          ],
          Text(text, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ColorChipDot extends StatelessWidget {
  final Color color;
  const _ColorChipDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.black26),
      ),
    );
  }
}

class _AddOnChip extends StatelessWidget {
  final AdditionalItem a;
  const _AddOnChip(this.a);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pieces = <String>[];
    pieces.add(a.name);
    if ((a.value ?? '').isNotEmpty) pieces.add(a.value!);
    if (a.price != null) pieces.add('+${a.price!.toStringAsFixed(2)}');
    return Chip(
      label: Text(pieces.join(' • '), style: theme.textTheme.labelMedium),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ====================== TOTALS ======================

class _TotalsCard extends StatelessWidget {
  final OrderModel order;
  const _TotalsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _kv(context, 'subtotal'.tr, order.subtotal),
            _kv(context, 'shipping'.tr, order.shipping),
            const Divider(height: 18),
            _kv(context, 'total'.tr, order.total, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext ctx, String k, double v, {bool isBold = false}) {
    final style = isBold
        ? Theme.of(ctx)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(ctx).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(k),
          const Spacer(),
          Text(_money(v), style: style),
        ],
      ),
    );
  }

  String _money(double v) => v.toStringAsFixed(2);
}

// ====================== BOTTOM ACTIONS ======================

class _BottomActions extends StatelessWidget {
  final VoidCallback onTrack;
  final VoidCallback onInvoice;
  final VoidCallback onReorder;

  const _BottomActions({
    required this.onTrack,
    required this.onInvoice,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.location_on_outlined, size: 18),
              label: Text('track'.tr),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onInvoice,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text('invoice'.tr),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onReorder,
              icon: const Icon(Icons.replay_outlined, size: 18),
              label: Text('reorder'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== MINOR WIDGETS ======================

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusPill(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

import 'package:ecommerce_app/views/orders/cubit/orders_cubit.dart';
import 'package:ecommerce_app/views/orders/cubit/orders_state.dart';
import 'package:ecommerce_app/views/orders/order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/models/additional_model.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text('my_orders'.tr), centerTitle: true),
      body: BlocProvider(
        create: (_) => OrdersCubit()..load(),
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.status == OrderStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == OrderStatus.error) {
              return _ErrorView(
                message: state.error ?? 'error'.tr,
                onRetry: () => context.read<OrdersCubit>().load(),
              );
            }

            final orders = state.orders.where((o) {
              switch (_filterIndex) {
                case 1:
                  return o.progress == OrderProgress.pending;
                case 2:
                  return o.progress == OrderProgress.processing;
                case 3:
                  return o.progress == OrderProgress.shipped;
                case 4:
                  return o.progress == OrderProgress.delivered;
                case 5:
                  return o.progress == OrderProgress.cancelled;
                default:
                  return true;
              }
            }).toList();

            return Column(
              children: [
                const SizedBox(height: 8),
                _StatusFilterBar(
                  index: _filterIndex,
                  onChanged: (i) => setState(() => _filterIndex = i),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context.read<OrdersCubit>().refresh();
                    },
                    child: orders.isEmpty
                        ? _EmptyOrders(isAr: isAr)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, i) {
                              OrderModel o = orders[i];
                              return _OrderCard(
                                isAr: isAr,
                                order: o,
                                onTapOrder: () {
                                  Get.to(OrderDetailsPage(
                                    order: o,
                                  ));
                                },
                                onTapProduct: (p) =>
                                    context.read<OrdersCubit>().openProduct(p),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _StatusFilterBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = [
      'all'.tr,
      'pending'.tr,
      'processing'.tr,
      'shipped'.tr,
      'delivered'.tr,
      'cancelled'.tr,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[i]),
              selected: selected,
              onSelected: (_) => onChanged(i),
            ),
          );
        }),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final bool isAr;
  final OrderModel order;
  final VoidCallback onTapOrder;
  final void Function(ProductSummary) onTapProduct;

  const _OrderCard({
    required this.isAr,
    required this.order,
    required this.onTapOrder,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusMeta = _statusMeta(order.progress, theme);
    final label = statusMeta.$1;
    final color = statusMeta.$2;
    final icon = statusMeta.$3;
    final createdStr =
        '${order.createdAt.year}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.day.toString().padLeft(2, '0')} '
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    final imgs = order.items.where((e) => e.imageUrl != null).toList();
    final display = imgs.take(3).toList();
    final extra = order.items.length - display.length;

    return InkWell(
      onTap: onTapOrder,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
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
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: theme.hintColor),
                  const SizedBox(width: 6),
                  Text(createdStr, style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Text('total'.tr,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor)),
                  const SizedBox(width: 6),
                  Text(_money(order.total),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  ...display.map((p) => _Thumb(
                        url: p.imageUrl!,
                        onTap: () => onTapProduct(p),
                      )),
                  if (extra > 0) _MoreThumb(count: extra, onTap: onTapOrder),
                  const Spacer(),
                  Text('${order.items.length} ${'items'.tr}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onTapOrder,
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: Text('view_order'.tr),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      if (order.items.isNotEmpty) {
                        onTapProduct(order.items.first);
                      }
                    },
                    icon: const Icon(Icons.replay_outlined, size: 18),
                    label: Text('reorder'.tr),
                  ),
                ],
              ),
            ],
          ),
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

  String _money(double v) => v.toStringAsFixed(2);
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
        // ignore: deprecated_member_use
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

class _Thumb extends StatelessWidget {
  final String url;
  final VoidCallback onTap;
  const _Thumb({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(url, width: 54, height: 54, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _MoreThumb extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _MoreThumb({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('+$count',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final bool isAr;
  const _EmptyOrders({required this.isAr});

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
            const Icon(Icons.receipt_long_outlined, size: 64),
            const SizedBox(height: 12),
            Text('no_orders'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('no_orders_hint'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
}

import 'package:ecommerce_app/repostery%20/app_notification.dart';
import 'package:ecommerce_app/views/notification/cubit/notification_cubit.dart';
import 'package:ecommerce_app/views/notification/cubit/notification_state.dart';
import 'package:ecommerce_app/views/notification/notification_badge.dart';
import 'package:ecommerce_app/views/notification/notification_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NotificationCubit(InMemoryNotificationRepository())..load(),
      child: Builder(builder: (context) {
        return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // Demo add
                context.read<NotificationCubit>().add(
                  title: 'order_update'.tr,
                  body: 'order_out_for_delivery'.trParams({
                    'order': '#${DateTime.now().millisecondsSinceEpoch % 10000}'
                  }),
                  data: {'route': '/orders/123'},
                );
              },
              label: Text('add_demo'.tr),
              icon: const Icon(Icons.add),
            ),
            appBar: AppBar(
              title: Text('notifications'.tr),
              actions: [
                NotificationBadge(onTap: () {
                  // Open this page or a sheet, depending on your app flow
                }),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                _buildFilterBar(context),
                Expanded(
                  child: NotificationList(
                    onTapNotification: (n) {
                      // Handle deep link/navigation using n.data
                      // Example: Get.toNamed(n.data?['route'] ?? '/');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

Widget _buildFilterBar(BuildContext context) {
  return BlocBuilder<NotificationCubit, NotificationState>(
    buildWhen: (p, n) => p.filter != n.filter || p.unreadCount != n.unreadCount,
    builder: (context, state) {
      final primary = Theme.of(context).colorScheme.primary;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ChoiceChip(
              label: Text('all'.tr),
              selected: state.filter == NotificationFilter.all,
              onSelected: (_) => context
                  .read<NotificationCubit>()
                  .setFilter(NotificationFilter.all),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text('unread'.trParams({'count': '${state.unreadCount}'})),
              selected: state.filter == NotificationFilter.unread,
              onSelected: (_) => context
                  .read<NotificationCubit>()
                  .setFilter(NotificationFilter.unread),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: state.unreadCount == 0
                  ? null
                  : context.read<NotificationCubit>().markAllRead,
              icon: Icon(Icons.mark_email_read,
                  color: state.unreadCount == 0 ? null : primary),
              label: Text('mark_all_read'.tr),
            ),
          ],
        ),
      );
    },
  );
}

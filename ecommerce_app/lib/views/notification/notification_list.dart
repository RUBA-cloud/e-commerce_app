import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/models/notiifcation.dart';
import 'package:ecommerce_app/views/notification/cubit/notification_cubit.dart';
import 'package:ecommerce_app/views/notification/cubit/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class NotificationList extends StatelessWidget {
  final void Function(AppNotification notif)? onTapNotification;

  const NotificationList({super.key, this.onTapNotification});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final items = state.visible;
        if (state.status == NotificationStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (items.isEmpty) {
          return Center(child: Text('no_notifications'.tr));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final n = items[i];
            return Dismissible(
              key: ValueKey(n.id),
              background: _bg(
                Alignment.centerLeft,
                Icons.mark_email_read,
                greenColor,
                'mark_read'.tr,
              ),
              secondaryBackground: _bg(
                Alignment.centerRight,
                Icons.delete,
                Colors.red,
                'delete'.tr,
              ),
              confirmDismiss: (dir) async {
                if (dir == DismissDirection.startToEnd) {
                  context
                      .read<NotificationCubit>()
                      .markRead(n.id, isRead: true);
                  return false; // keep the tile, just mark read
                } else {
                  context.read<NotificationCubit>().remove(n.id);
                  return true; // remove from list
                }
              },
              child: _tile(context, n),
            );
          },
        );
      },
    );
  }

  Widget _tile(BuildContext context, AppNotification n) {
    final isRead = n.isRead;
    final theme = Theme.of(context);
    return Card(
      elevation: isRead ? 0 : 2,
      color: isRead
          ? theme.colorScheme.surface
          : theme.colorScheme.primary.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () => onTapNotification?.call(n),
        leading: n.imageUrl == null
            ? CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                child: Icon(
                  isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: theme.colorScheme.primary,
                ),
              )
            : CircleAvatar(backgroundImage: NetworkImage(n.imageUrl!)),
        title: Text(
          n.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
            color: isRead ? null : theme.colorScheme.primary,
          ),
        ),
        subtitle: Text(
          n.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_formatTime(n.createdAt), style: theme.textTheme.labelSmall),
            const SizedBox(height: 6),
            if (!isRead)
              InkWell(
                onTap: () => context.read<NotificationCubit>().markRead(n.id),
                child: Text(
                  'mark_read'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bg(Alignment align, IconData icon, Color color, String text) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: color.withOpacity(0.15),
      child: Row(
        mainAxisAlignment: align == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just_now'.tr;
    if (diff.inMinutes < 60) return '${diff.inMinutes}${'m'.tr}';
    if (diff.inHours < 24) return '${diff.inHours}${'h'.tr}';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }
}

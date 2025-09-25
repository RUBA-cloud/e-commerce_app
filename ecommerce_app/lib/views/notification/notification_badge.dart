// lib/notifications/widgets/notification_badge.dart
import 'package:ecommerce_app/views/notification/cubit/notification_cubit.dart';
import 'package:ecommerce_app/views/notification/cubit/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const NotificationBadge(
      {super.key, this.onTap, this.icon = Icons.notifications});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (p, n) => p.unreadCount != n.unreadCount,
      builder: (context, state) {
        final count = state.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(onPressed: onTap, icon: Icon(icon)),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

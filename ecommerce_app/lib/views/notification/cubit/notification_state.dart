// lib/notifications/notification_state.dart
import 'package:ecommerce_app/models/notiifcation.dart';
import 'package:flutter/foundation.dart';

enum NotificationStatus { idle, loading, success, failure }

enum NotificationFilter { all, unread }

@immutable
class NotificationState {
  final NotificationStatus status;
  final List<AppNotification> items;
  final NotificationFilter filter;
  final String error;

  int get unreadCount => items.where((e) => !e.isRead).length;

  List<AppNotification> get visible {
    switch (filter) {
      case NotificationFilter.unread:
        return items.where((e) => !e.isRead).toList();
      case NotificationFilter.all:
        return items;
    }
  }

  const NotificationState({
    required this.status,
    required this.items,
    required this.filter,
    required this.error,
  });

  factory NotificationState.initial() => const NotificationState(
        status: NotificationStatus.idle,
        items: [],
        filter: NotificationFilter.all,
        error: '',
      );

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? items,
    NotificationFilter? filter,
    String? error,
  }) {
    return NotificationState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      error: error ?? this.error,
    );
  }
}

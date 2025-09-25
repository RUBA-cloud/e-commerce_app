// lib/notifications/notification_repo.dart
import 'package:ecommerce_app/models/notiifcation.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetchAll();
  Future<void> saveAll(List<AppNotification> list);
}

class InMemoryNotificationRepository implements NotificationRepository {
  List<AppNotification> _store = [];

  @override
  Future<List<AppNotification>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _store..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveAll(List<AppNotification> list) async {
    _store = List<AppNotification>.from(list);
  }
}

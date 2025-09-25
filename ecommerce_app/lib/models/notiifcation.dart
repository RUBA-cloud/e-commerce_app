// lib/notifications/notification_model.dart
import 'package:flutter/foundation.dart';

@immutable
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl; // optional for rich cards
  final Map<String, dynamic>? data; // payload (e.g., route, ids, etc.)

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
    );
  }
}

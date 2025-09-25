// lib/notifications/notification_cubit.dart

import 'package:ecommerce_app/models/notiifcation.dart';
import 'package:ecommerce_app/repostery%20/app_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repo;

  NotificationCubit(this.repo) : super(NotificationState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: NotificationStatus.loading, error: ''));
    try {
      final list = await repo.fetchAll();
      emit(state.copyWith(status: NotificationStatus.success, items: list));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> setFilter(NotificationFilter filter) async {
    emit(state.copyWith(filter: filter));
  }

  Future<void> markRead(String id, {bool isRead = true}) async {
    final next = state.items
        .map((e) => e.id == id ? e.copyWith(isRead: isRead) : e)
        .toList();
    emit(state.copyWith(items: next));
    await repo.saveAll(next);
  }

  Future<void> markAllRead() async {
    final next = state.items.map((e) => e.copyWith(isRead: true)).toList();
    emit(state.copyWith(items: next));
    await repo.saveAll(next);
  }

  Future<void> add({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) async {
    final newItem = AppNotification(
      id: '1',
      title: title,
      body: body,
      createdAt: createdAt ?? DateTime.now(),
      imageUrl: imageUrl,
      data: data,
    );
    final next = [newItem, ...state.items];
    emit(state.copyWith(items: next));
    await repo.saveAll(next);
  }

  Future<void> remove(String id) async {
    final next = state.items.where((e) => e.id != id).toList();
    emit(state.copyWith(items: next));
    await repo.saveAll(next);
  }

  /// Example hook for FCM (optional)
}

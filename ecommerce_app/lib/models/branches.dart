// lib/features/branches/data/branch_model.dart
import 'package:flutter/foundation.dart';

/// Working days use ISO style: 1=Mon ... 7=Sun.
@immutable
class BranchModel {
  final String nameEn;
  final String nameAr;

  /// Optional generic name (fallback if localized is empty)
  final String? name;

  /// 1=Mon ... 7=Sun
  final List<int> workingDays;

  /// "HH:mm" (24h) — e.g. "09:00"
  final String hoursFrom;

  /// "HH:mm" (24h) — e.g. "17:30"
  final String hoursTo;

  final String address;

  /// Optional coordinates for map deep links
  final double? lat;
  final double? lng;

  const BranchModel({
    required this.nameEn,
    required this.nameAr,
    this.name,
    required this.workingDays,
    required this.hoursFrom,
    required this.hoursTo,
    required this.address,
    this.lat,
    this.lng,
  });

  String displayName({required bool isAr}) {
    if (isAr && nameAr.trim().isNotEmpty) return nameAr.trim();
    if (!isAr && nameEn.trim().isNotEmpty) return nameEn.trim();
    return (name ?? nameEn).trim();
  }

  bool isOpenNow(DateTime nowLocal) {
    final day = _weekdayIso(nowLocal.weekday); // already 1..7 in Dart
    if (!workingDays.contains(day)) return false;

    int hm(String s) {
      final parts = s.split(':');
      final h = int.tryParse(parts.first) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      return h * 60 + m;
    }

    final nowMinutes = nowLocal.hour * 60 + nowLocal.minute;
    final from = hm(hoursFrom);
    final to = hm(hoursTo);

    // Handle ranges that pass midnight (e.g., 22:00 -> 02:00)
    if (to < from) {
      return nowMinutes >= from || nowMinutes <= to;
    }
    return nowMinutes >= from && nowMinutes <= to;
  }

  static int _weekdayIso(int dartWeekday) => dartWeekday; // 1..7
}

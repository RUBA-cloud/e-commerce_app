// lib/features/branches/data/branch_model.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Working days ISO: 1=Mon ... 7=Sun.
@immutable
class BranchModel {
  final String nameEn;
  final String nameAr;

  /// Optional generic name (fallback if localized is empty)
  final String? name;

  /// ISO weekday numbers: 1=Mon ... 7=Sun
  final List<int> workingDays;

  /// "HH:mm" (24h) — e.g. "09:00"
  final String hoursFrom;

  /// "HH:mm" (24h) — e.g. "17:30"
  final String hoursTo;

  /// Chosen address (you can decide based on locale in UI)
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

  /// ------- UI helpers -------

  String displayName({required bool isAr}) {
    if (isAr && nameAr.trim().isNotEmpty) return nameAr.trim();
    if (!isAr && nameEn.trim().isNotEmpty) return nameEn.trim();
    return (name ?? nameEn).trim();
  }

  bool isOpenNow(DateTime nowLocal) {
    final day = nowLocal.weekday; // 1..7
    if (!workingDays.contains(day)) return false;

    int hm(String s) {
      final parts = s.split(':');
      final h = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
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

  /// ------- JSON mapping to your API response -------
  ///
  /// Supports working_days formats:
  /// - "1,2,3,4,5"
  /// - "[1,2,3]"
  /// - [1,2,3] or ["1","2","3"]
  /// - "Saturday,Sunday,Monday,Tuesday"
  /// - '["Saturday","Sunday"]'
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    List<String> parseWorkingDays(dynamic raw) {
      if (raw == null) return <String>[];

      if (raw is String) {
        final s = raw.trim();
        if (s.isEmpty) return <String>[];

        // JSON string: ["Saturday","Sunday"] OR [1,2,3]
        if (s.startsWith('[') && s.endsWith(']')) {
          try {
            final decoded = jsonDecode(s);
            if (decoded is List) {
              return decoded.map((e) => e.toString().trim()).toList();
            }
          } catch (_) {
            // fallback csv
          }
        }

        // CSV: "Saturday,Sunday,Monday" OR "1,2,3"
        return s
            .split(',')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();
      }

      if (raw is List) {
        return raw.map((e) => e.toString().trim()).toList();
      }

      return <String>[];
    }

    int? nameOrNumberToIsoDay(String s) {
      final v = s.trim();
      if (v.isEmpty) return null;

      // If it is already a number "1".."7"
      final asInt = int.tryParse(v);
      if (asInt != null && asInt >= 1 && asInt <= 7) return asInt;

      final key = v.toLowerCase();

      // ISO: 1 Mon ... 7 Sun
      const map = <String, int>{
        'monday': 1,
        'mon': 1,
        'tuesday': 2,
        'tue': 2,
        'tues': 2,
        'wednesday': 3,
        'wed': 3,
        'thursday': 4,
        'thu': 4,
        'thur': 4,
        'thurs': 4,
        'friday': 5,
        'fri': 5,
        'saturday': 6,
        'sat': 6,
        'sunday': 7,
        'sun': 7,
      };

      return map[key];
    }

    List<int> toIsoDays(List<String> list) {
      final days = list
          .map(nameOrNumberToIsoDay)
          .whereType<int>()
          .where((d) => d >= 1 && d <= 7)
          .toList();

      // remove duplicates but keep order
      final seen = <int>{};
      return days.where((d) => seen.add(d)).toList();
    }

    double? parseDouble(String? s) =>
        (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim());

    double? lat;
    double? lng;

    final loc = json['location'];

    // location can be "31.95,35.93"
    if (loc is String && loc.contains(',')) {
      final parts = loc.split(',');
      lat = parseDouble(parts.isNotEmpty ? parts[0] : null);
      lng = parseDouble(parts.length > 1 ? parts[1] : null);
    }
    // or a map {lat:..., lng:...}
    else if (loc is Map) {
      lat = parseDouble(loc['lat']?.toString());
      lng = parseDouble(loc['lng']?.toString());
    } else {
      // Optional: if your API has separate fields
      lat = parseDouble(json['lat']?.toString());
      lng = parseDouble(json['lng']?.toString());
    }

    final workingDaysStrings = parseWorkingDays(json['working_days']);

    return BranchModel(
      nameEn: (json['name_en'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      name: json['name']?.toString(),
      workingDays: toIsoDays(workingDaysStrings),
      hoursFrom: (json['working_hours_from'] ?? '00:00').toString(),
      hoursTo: (json['working_hours_to'] ?? '23:59').toString(),
      // choose English address for now; can switch based on locale later
      address: (json['address_en'] ?? json['address_ar'] ?? '').toString(),
      lat: lat,
      lng: lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_en': nameEn,
      'name_ar': nameAr,
      'name': name,
      // store as CSV of ISO numbers: "1,2,3"
      'working_days': workingDays.join(','),
      'working_hours_from': hoursFrom,
      'working_hours_to': hoursTo,
      'address_en': address,
      'location': (lat != null && lng != null) ? '$lat,$lng' : null,
    };
  }

  BranchModel copyWith({
    String? nameEn,
    String? nameAr,
    String? name,
    List<int>? workingDays,
    String? hoursFrom,
    String? hoursTo,
    String? address,
    double? lat,
    double? lng,
  }) {
    return BranchModel(
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      name: name ?? this.name,
      workingDays: workingDays ?? this.workingDays,
      hoursFrom: hoursFrom ?? this.hoursFrom,
      hoursTo: hoursTo ?? this.hoursTo,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

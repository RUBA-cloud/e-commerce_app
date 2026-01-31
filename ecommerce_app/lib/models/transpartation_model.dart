class TranspartationModel {
  final int? id;
  final String? nameEn;
  final String? nameAr;

  /// country object from API
  final Map<String, dynamic>? country;

  /// city object from API
  final Map<String, dynamic>? city;

  /// transportation type object from API
  final Map<String, dynamic>? type;

  final double? daysCount;

  const TranspartationModel({
    this.id,
    this.nameEn,
    this.nameAr,
    this.country,
    this.city,
    this.type,
    this.daysCount,
  });

  /// ✅ from API json
  factory TranspartationModel.fromJson(Map<String, dynamic> json) {
    return TranspartationModel(
      id: json['id'] as int?,
      nameEn: json['name_en'] as String?,
      nameAr: json['name_ar'] as String?,
      country: json['country'] as Map<String, dynamic>?,
      city: json['city'] as Map<String, dynamic>?,
      type: json['type'] as Map<String, dynamic>?,
      daysCount: json['days_count'] != null
          ? (json['days_count'] as num).toDouble()
          : null,
    );
  }

  /// ✅ to json (if you need to send it back)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'country': country,
      'city': city,
      'type': type,
      'days_count': daysCount,
    };
  }

  /// ✅ Helper: get display name by language
  String displayName({bool isAr = false}) {
    if (isAr) {
      return nameAr ?? nameEn ?? '';
    }
    return nameEn ?? nameAr ?? '';
  }
}

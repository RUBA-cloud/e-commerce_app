import 'dart:convert';

class SizeModel {
  final int? id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double? price;

  const SizeModel({
    this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
  });

  factory SizeModel.fromMap(Map<String, dynamic> map) {
    // --- price ---
    double? parsedPrice;
    final rawPrice = map['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice);
    }

    // --- descriptions (handle typos + different keys) ---
    final String descEn = (map['description_en'] as String?) ??
        (map['descripation_en'] as String?) ??
        (map['description'] as String?) ??
        (map['descripation'] as String?) ??
        '';

    final String descAr = (map['description_ar'] as String?) ??
        (map['descripation_ar'] as String?) ??
        (map['description'] as String?) ??
        (map['descripation'] as String?) ??
        '';

    return SizeModel(
      id: map['id'] != null ? (map['id'] as num).toInt() : null,
      nameEn: (map['name_en'] ?? '').toString(),
      nameAr: (map['name_ar'] ?? '').toString(),
      descriptionEn: descEn,
      descriptionAr: descAr,
      price: parsedPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'price': price,
    };
  }

  String toJson() => json.encode(toMap());

  SizeModel copyWith({
    int? id,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    double? price,
  }) {
    return SizeModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'SizeModel(id: $id, nameEn: $nameEn, nameAr: $nameAr, descriptionEn: $descriptionEn, descriptionAr: $descriptionAr, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SizeModel &&
            other.id == id &&
            other.nameEn == nameEn &&
            other.nameAr == nameAr &&
            other.descriptionEn == descriptionEn &&
            other.descriptionAr == descriptionAr &&
            other.price == price);
  }

  @override
  int get hashCode =>
      Object.hash(id, nameEn, nameAr, descriptionEn, descriptionAr, price);
}

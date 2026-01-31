class CityModel {
  final int? id;
  final String? nameEn;
  final String? nameAr;

  CityModel({this.id, this.nameEn, this.nameAr});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return CityModel(
      id: parseInt(json['id'] ?? json['Id']),
      nameEn: (json['name_en'] ?? json['nameEn'] ?? json['name'])?.toString(),
      nameAr: (json['name_ar'] ?? json['nameAr'] ?? json['name_ar'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_ar': nameAr,
      };

  CityModel copyWith({int? id, String? nameEn, String? nameAr}) {
    return CityModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
    );
  }

  @override
  String toString() => 'CountryModel(id: $id, nameEn: $nameEn, nameAr: $nameAr)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameEn == other.nameEn &&
          nameAr == other.nameAr;

  @override
  int get hashCode => Object.hash(id, nameEn, nameAr);
}

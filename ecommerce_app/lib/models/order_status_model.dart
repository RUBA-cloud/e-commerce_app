
class OrderStatusModel {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String?color;
final String?iconData;

  OrderStatusModel({this.id, this.nameEn, this.nameAr,this.color,this.iconData});

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return OrderStatusModel(
      id: parseInt(json['id'] ?? json['Id']),
      nameEn: (json['name_en'] ?? json['nameEn'] ?? json['name'])?.toString(),
      nameAr: (json['name_ar'] ?? json['nameAr'] ?? json['name_ar'])?.toString(),
      iconData: (json['icon_data'] ?? json['icon_data'] ?? json['name_ar'])?.toString(),
      );
    
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_ar': nameAr,
      };

  OrderStatusModel copyWith({int? id, String? nameEn, String? nameAr}) {
    return OrderStatusModel(
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
      other is OrderStatusModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameEn == other.nameEn &&
          nameAr == other.nameAr;

  @override
  int get hashCode => Object.hash(id, nameEn, nameAr);
}

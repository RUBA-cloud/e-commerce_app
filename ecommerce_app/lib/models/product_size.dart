import 'package:ecommerce_app/models/size_pivot.dart';

class ProductSize {
  final int id;
  final String nameEn;
  final String nameAr;
  final bool isActive;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? image;
  final String? descripation; // kept same name as API
  final num? price;
  final SizePivot? pivot;

  ProductSize({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.isActive,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    required this.descripation,
    required this.price,
    required this.pivot,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      id: json['id'] ?? 0,
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      userId: json['user_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      image: json['image']?.toString(),
      descripation: json['descripation']?.toString(),
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      pivot: json['pivot'] != null
          ? SizePivot.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'is_active': isActive,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image': image,
      'descripation': descripation,
      'price': price,
      'pivot': pivot?.toJson(),
    };
  }
}
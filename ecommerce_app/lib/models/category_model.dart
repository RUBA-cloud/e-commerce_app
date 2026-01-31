import 'package:ecommerce_app/models/product_model.dart';

class CategoryModel {
  final int id;
  final String nameEn;
  final String nameAr;
  final bool isActive;
  final String? image;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ProductModel> products;

  CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.isActive,
    required this.image,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      image: json['image']?.toString(),
      userId: json['user_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      products: (json['products'] as List?)
              ?.map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_ar': nameAr,
        'is_active': isActive ? 1 : 0,
        'image': image,
        'user_id': userId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'products': products.map((e) => e.toJson()).toList(),
      };

  /// ✅ Empty fallback (avoids null errors)
  factory CategoryModel.empty() => CategoryModel(
        id: 0,
        nameEn: '',
        nameAr: '',
        isActive: false,
        image: null,
        userId: null,
        createdAt: null,
        updatedAt: null,
        products: [],
      );
}

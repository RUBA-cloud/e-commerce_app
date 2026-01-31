import 'package:ecommerce_app/models/additional_model.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/product_size.dart';
import 'package:ecommerce_app/models/product_type.dart';

class ProductModel {
  final int id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String price;
  final bool isActive;
  final int? userId;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? typeId;
  final List<String> colors;
  final List<String> productImages;
  final List<ProductSize> sizes;
  final CategoryModel? category;
  final ProductType? type;
  final String?mainImage;
  final List<AdditionalModel>?productsAdditonal;

  ProductModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.mainImage,
    required this.price,
    required this.isActive,
    required this.userId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.typeId,
    required this.colors,

    required this.sizes,
    required this.category,
    required this.type,
    required this.productsAdditonal,
    required this.productImages
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      
      id: json['id'] ?? 0,
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      userId: json['user_id'] as int?,
      categoryId: json['category_id'] ?? 0,
      mainImage: json['main_image']?.toString(),

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
          typeId: null,
          
     // typeId: json['type_id'] as int?,
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      productImages: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
          type: null,category: null,
      sizes: (json['sizes'] as List<dynamic>? ?? [])
          .map((e) => ProductSize.fromJson(e))
          .toList(),
    productsAdditonal: (json['additionals'] as List<dynamic>? ?? [])
          .map((e) => AdditionalModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'price': price,
      'is_active': isActive,
      'user_id': userId,
      'category_id': categoryId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type_id': typeId,
      'colors': colors,
      'images': productImages,
      'sizes': sizes.map((e) => e.toJson()).toList(),
      'additionals':productsAdditonal,
      'category': category,
      'type': type?.toJson(),
    };
  }
}
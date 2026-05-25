import 'package:json_annotation/json_annotation.dart';

part 'carts_entity.g.dart';

@JsonSerializable()
class CartsEntity {
  String? status;
  String? message;
  List<CartsDataEntity?>? data;

  CartsEntity(this.status, this.message, this.data);

  factory CartsEntity.fromJson(Map<String, dynamic> json) =>
      _$CartsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CartsEntityToJson(this);
}

@JsonSerializable()
class CartsDataEntity {
  int? id;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'product_id')
  int? productId;
  String? color;
  @JsonKey(name: 'size_id')
  int? sizeId;
  int? quantity;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;
  CartsDataProductEntity? product;
  CartsDataSizeEntity? size;
  @JsonKey(name: 'cart_additional')
  List<dynamic>? cartAdditional;

  CartsDataEntity(
      this.id,
      this.userId,
      this.productId,
      this.color,
      this.sizeId,
      this.quantity,
      this.createdAt,
      this.updatedAt,
      this.product,
      this.size,
      this.cartAdditional,
      );

  factory CartsDataEntity.fromJson(Map<String, dynamic> json) =>
      _$CartsDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CartsDataEntityToJson(this);
}

@JsonSerializable()
class CartsDataProductEntity {
  int? id;
  @JsonKey(name: 'name_en')
  String? nameEn;
  @JsonKey(name: 'name_ar')
  String? nameAr;
  @JsonKey(name: 'description_en')
  String? descriptionEn;
  @JsonKey(name: 'description_ar')
  String? descriptionAr;
  String? price;
  @JsonKey(name: 'is_active')
  bool? isActive;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'category_id')
  int? categoryId;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;
  @JsonKey(name: 'type_id')
  int? typeId;
  List<String?>? colors;
  @JsonKey(name: 'main_image')
  String? mainImage;
  @JsonKey(name: 'size_id')
  int? sizeId;

  CartsDataProductEntity(
      this.id,
      this.nameEn,
      this.nameAr,
      this.descriptionEn,
      this.descriptionAr,
      this.price,
      this.isActive,
      this.userId,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.typeId,
      this.colors,
      this.mainImage,
      this.sizeId,
      );

  factory CartsDataProductEntity.fromJson(Map<String, dynamic> json) =>
      _$CartsDataProductEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CartsDataProductEntityToJson(this);
}

@JsonSerializable()
class CartsDataSizeEntity {
  int? id;
  @JsonKey(name: 'name_en')
  String? nameEn;
  @JsonKey(name: 'name_ar')
  String? nameAr;
  @JsonKey(name: 'is_active')
  bool? isActive;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;
  dynamic image;        // ✅ dynamic — API sends null
  String? descripation;
  int? price;

  CartsDataSizeEntity(
      this.id,
      this.nameEn,
      this.nameAr,
      this.isActive,
      this.userId,
      this.createdAt,
      this.updatedAt,
      this.image,
      this.descripation,
      this.price,
      );

  factory CartsDataSizeEntity.fromJson(Map<String, dynamic> json) =>
      _$CartsDataSizeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CartsDataSizeEntityToJson(this);
}
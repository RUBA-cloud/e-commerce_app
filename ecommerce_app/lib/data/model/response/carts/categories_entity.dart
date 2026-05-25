import 'package:json_annotation/json_annotation.dart';

part 'categories_entity.g.dart';

@JsonSerializable()
class CategoriesEntity {
  String status;
  String message;
  CategoriesDataEntity data;

  CategoriesEntity(this.status, this.message, this.data);

  factory CategoriesEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataEntity {
  @JsonKey(name: 'current_page')
  int currentPage;
  List<CategoriesDataDataEntity> data;
  @JsonKey(name: 'first_page_url')
  String firstPageUrl;
  int from;
  @JsonKey(name: 'last_page')
  int lastPage;
  @JsonKey(name: 'last_page_url')
  String lastPageUrl;
  List<CategoriesDataLinksEntity> links;
  @JsonKey(name: 'next_page_url')
  dynamic nextPageUrl;
  String path;
  @JsonKey(name: 'per_page')
  int perPage;
  @JsonKey(name: 'prev_page_url')
  dynamic prevPageUrl;
  int to;
  int total;

  CategoriesDataEntity(
      this.currentPage, this.data, this.firstPageUrl, this.from,
      this.lastPage, this.lastPageUrl, this.links, this.nextPageUrl,
      this.path, this.perPage, this.prevPageUrl, this.to, this.total,
      );

  factory CategoriesDataEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataDataEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_active')
  int isActive;
  dynamic image;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  List<CategoriesDataDataProductsEntity> products;

  CategoriesDataDataEntity(
      this.id, this.nameEn, this.nameAr, this.isActive, this.image,
      this.userId, this.createdAt, this.updatedAt, this.products,
      );

  factory CategoriesDataDataEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataDataEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataDataEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataDataProductsEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'description_en')
  String descriptionEn;
  @JsonKey(name: 'description_ar')
  String descriptionAr;
  String price;
  @JsonKey(name: 'is_active')
  bool isActive;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'category_id')
  int categoryId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  @JsonKey(name: 'deleted_at')
  String? deletedAt;                // ✅ nullable
  @JsonKey(name: 'type_id')
  int typeId;
  List<String> colors;
  @JsonKey(name: 'main_image')
  String mainImage;
  @JsonKey(name: 'size_id')
  int sizeId;
  List<CategoriesDataDataProductsImagesEntity> images;
  List<CategoriesDataDataProductsSizesEntity> sizes;
  List<dynamic> additionals;
  CategoriesDataDataProductsCategoryEntity category;
  CategoriesDataDataProductsTypeEntity type;

  CategoriesDataDataProductsEntity(
      this.id, this.nameEn, this.nameAr, this.descriptionEn, this.descriptionAr,
      this.price, this.isActive, this.userId, this.categoryId, this.createdAt,
      this.updatedAt, this.deletedAt, this.typeId, this.colors, this.mainImage,
      this.sizeId, this.images, this.sizes, this.additionals, this.category, this.type,
      );

  factory CategoriesDataDataProductsEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataDataProductsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataDataProductsEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataDataProductsImagesEntity {
  int id;
  @JsonKey(name: 'product_id')
  int productId;
  @JsonKey(name: 'image_path')
  String imagePath;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;

  CategoriesDataDataProductsImagesEntity(
      this.id, this.productId, this.imagePath, this.createdAt, this.updatedAt,
      );

  factory CategoriesDataDataProductsImagesEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataDataProductsImagesEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataDataProductsImagesEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataDataProductsSizesEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_active')
  bool isActive;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  String? image;                    // ✅ nullable — API sends null for some sizes
  String? descripation;             // ✅ nullable — API sends null for some sizes
  int price;
  CategoriesDataDataProductsSizesPivotEntity pivot;

  CategoriesDataDataProductsSizesEntity(
      this.id, this.nameEn, this.nameAr, this.isActive, this.userId,
      this.createdAt, this.updatedAt, this.image, this.descripation,
      this.price, this.pivot,
      );

  factory CategoriesDataDataProductsSizesEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataDataProductsSizesEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataDataProductsSizesEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataDataProductsSizesPivotEntity {
  @JsonKey(name: 'product_id')
  int productId;
  @JsonKey(name: 'size_id')
  int sizeId;

  CategoriesDataDataProductsSizesPivotEntity(this.productId, this.sizeId);

  factory CategoriesDataDataProductsSizesPivotEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataDataProductsSizesPivotEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataDataProductsSizesPivotEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataDataProductsCategoryEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_active')
  int isActive;
  dynamic image;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;

  CategoriesDataDataProductsCategoryEntity(
      this.id, this.nameEn, this.nameAr, this.isActive, this.image,
      this.userId, this.createdAt, this.updatedAt,
      );

  factory CategoriesDataDataProductsCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataDataProductsCategoryEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataDataProductsCategoryEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataDataProductsTypeEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_active')
  bool isActive;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;

  CategoriesDataDataProductsTypeEntity(
      this.id, this.nameEn, this.nameAr, this.isActive,
      this.userId, this.createdAt, this.updatedAt,
      );

  factory CategoriesDataDataProductsTypeEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataDataProductsTypeEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataDataProductsTypeEntityToJson(this);
}

@JsonSerializable()
class CategoriesDataLinksEntity {
  dynamic url;
  String label;
  dynamic page;
  bool active;

  CategoriesDataLinksEntity(this.url, this.label, this.page, this.active);

  factory CategoriesDataLinksEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataLinksEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesDataLinksEntityToJson(this);
}
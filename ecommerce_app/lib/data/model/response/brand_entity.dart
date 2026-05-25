import 'package:json_annotation/json_annotation.dart';

part 'brand_entity.g.dart';

@JsonSerializable()
class BrandEntity {
  bool success;
  BrandDataEntity data;

  BrandEntity(this.success, this.data);

  factory BrandEntity.fromJson(Map<String, dynamic> json) =>
      _$BrandEntityFromJson(json);
  Map<String, dynamic> toJson() => _$BrandEntityToJson(this);
}

@JsonSerializable()
class BrandDataEntity {
  @JsonKey(name: 'current_page')
  int currentPage;
  List<BrandDataDataEntity> data;
  @JsonKey(name: 'first_page_url')
  String firstPageUrl;
  int? from;                        // ✅ was int — null when list is empty
  @JsonKey(name: 'last_page')
  int lastPage;
  @JsonKey(name: 'last_page_url')
  String lastPageUrl;
  List<BrandDataLinksEntity> links;
  @JsonKey(name: 'next_page_url')
  dynamic nextPageUrl;
  String path;
  @JsonKey(name: 'per_page')
  int perPage;
  @JsonKey(name: 'prev_page_url')
  dynamic prevPageUrl;
  int? to;                          // ✅ was int — null when list is empty
  int total;

  BrandDataEntity(
      this.currentPage, this.data, this.firstPageUrl, this.from,
      this.lastPage, this.lastPageUrl, this.links, this.nextPageUrl,
      this.path, this.perPage, this.prevPageUrl, this.to, this.total,
      );

  factory BrandDataEntity.fromJson(Map<String, dynamic> json) =>
      _$BrandDataEntityFromJson(json);
  Map<String, dynamic> toJson() => _$BrandDataEntityToJson(this);
}

@JsonSerializable()
class BrandDataDataEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_top')
  bool isTop;
  @JsonKey(name: 'is_active')
  bool isActive;
  dynamic image;                    // ✅ was String — API sends null sometimes
  @JsonKey(name: 'company_id')
  int companyId;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  @JsonKey(name: 'deleted_at')
  String? deletedAt;                // ✅ nullable
  @JsonKey(name: 'category_id')
  int? categoryId;                  // ✅ nullable
  @JsonKey(name: 'image_url')
  String? imageUrl;                 // ✅ nullable
  List<BrandDataDataProductsEntity> products;

  BrandDataDataEntity(
      this.id, this.nameEn, this.nameAr, this.isTop, this.isActive,
      this.image, this.companyId, this.userId, this.createdAt, this.updatedAt,
      this.deletedAt, this.categoryId, this.imageUrl, this.products,
      );

  factory BrandDataDataEntity.fromJson(Map<String, dynamic> json) =>
      _$BrandDataDataEntityFromJson(json);
  Map<String, dynamic> toJson() => _$BrandDataDataEntityToJson(this);
}

@JsonSerializable()
class BrandDataDataProductsEntity {
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
  BrandDataDataProductsPivotEntity pivot;

  BrandDataDataProductsEntity(
      this.id, this.nameEn, this.nameAr, this.descriptionEn, this.descriptionAr,
      this.price, this.isActive, this.userId, this.categoryId, this.createdAt,
      this.updatedAt, this.deletedAt, this.typeId, this.colors,
      this.mainImage, this.sizeId, this.pivot,
      );

  factory BrandDataDataProductsEntity.fromJson(Map<String, dynamic> json) =>
      _$BrandDataDataProductsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$BrandDataDataProductsEntityToJson(this);
}

@JsonSerializable()
class BrandDataDataProductsPivotEntity {
  @JsonKey(name: 'brand_id')
  int brandId;
  @JsonKey(name: 'product_id')
  int productId;
  @JsonKey(name: 'created_at')
  dynamic createdAt;
  @JsonKey(name: 'updated_at')
  dynamic updatedAt;

  BrandDataDataProductsPivotEntity(
      this.brandId, this.productId, this.createdAt, this.updatedAt,
      );

  factory BrandDataDataProductsPivotEntity.fromJson(Map<String, dynamic> json) =>
      _$BrandDataDataProductsPivotEntityFromJson(json);
  Map<String, dynamic> toJson() =>
      _$BrandDataDataProductsPivotEntityToJson(this);
}

@JsonSerializable()
class BrandDataLinksEntity {
  dynamic url;
  String label;
  dynamic page;
  bool active;

  BrandDataLinksEntity(this.url, this.label, this.page, this.active);

  factory BrandDataLinksEntity.fromJson(Map<String, dynamic> json) =>
      _$BrandDataLinksEntityFromJson(json);
  Map<String, dynamic> toJson() => _$BrandDataLinksEntityToJson(this);
}
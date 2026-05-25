import 'package:json_annotation/json_annotation.dart';

part 'similar_product_entity_entity.g.dart';

@JsonSerializable()
class SimilarProductEntityEntity {
  String? status;
  String? message;
  SimilarProductEntityProductsEntity? products;

  SimilarProductEntityEntity(this.status, this.message, this.products);

  factory SimilarProductEntityEntity.fromJson(Map<String, dynamic> json) =>
      _$SimilarProductEntityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SimilarProductEntityEntityToJson(this);
}

@JsonSerializable()
class SimilarProductEntityProductsEntity {
  @JsonKey(name: 'current_page')
  int? currentPage;
  List<SimilarProductEntityProductsDataEntity>? data;
  @JsonKey(name: 'first_page_url')
  String? firstPageUrl;
  int? from;
  @JsonKey(name: 'last_page')
  int? lastPage;
  @JsonKey(name: 'last_page_url')
  String? lastPageUrl;
  List<SimilarProductEntityProductsLinksEntity>? links;
  @JsonKey(name: 'next_page_url')
  dynamic nextPageUrl;
  String? path;
  @JsonKey(name: 'per_page')
  int? perPage;
  @JsonKey(name: 'prev_page_url')
  dynamic prevPageUrl;
  int? to;
  int? total;

  SimilarProductEntityProductsEntity(
      this.currentPage,
      this.data,
      this.firstPageUrl,
      this.from,
      this.lastPage,
      this.lastPageUrl,
      this.links,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total,
      );

  factory SimilarProductEntityProductsEntity.fromJson(
      Map<String, dynamic> json,
      ) => _$SimilarProductEntityProductsEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SimilarProductEntityProductsEntityToJson(this);
}

@JsonSerializable()
class SimilarProductEntityProductsDataEntity {
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
  List<dynamic>? images;
  List<SimilarProductEntityProductsDataSizesEntity>? sizes;
  List<dynamic>? additionals;
  SimilarProductEntityProductsDataCategoryEntity? category;
  SimilarProductEntityProductsDataTypeEntity? type;

  SimilarProductEntityProductsDataEntity(
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
      this.images,
      this.sizes,
      this.additionals,
      this.category,
      this.type,
      );

  factory SimilarProductEntityProductsDataEntity.fromJson(
      Map<String, dynamic> json,
      ) => _$SimilarProductEntityProductsDataEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SimilarProductEntityProductsDataEntityToJson(this);
}

@JsonSerializable()
class SimilarProductEntityProductsDataSizesEntity {
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
  dynamic image;
  String? descripation;
  int? price;
  SimilarProductEntityProductsDataSizesPivotEntity? pivot;

  SimilarProductEntityProductsDataSizesEntity(
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
      this.pivot,
      );

  factory SimilarProductEntityProductsDataSizesEntity.fromJson(
      Map<String, dynamic> json,
      ) => _$SimilarProductEntityProductsDataSizesEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SimilarProductEntityProductsDataSizesEntityToJson(this);
}

@JsonSerializable()
class SimilarProductEntityProductsDataSizesPivotEntity {
  @JsonKey(name: 'product_id')
  int? productId;
  @JsonKey(name: 'size_id')
  int? sizeId;

  SimilarProductEntityProductsDataSizesPivotEntity(this.productId, this.sizeId);

  factory SimilarProductEntityProductsDataSizesPivotEntity.fromJson(
      Map<String, dynamic> json,
      ) => _$SimilarProductEntityProductsDataSizesPivotEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SimilarProductEntityProductsDataSizesPivotEntityToJson(this);
}

@JsonSerializable()
class SimilarProductEntityProductsDataCategoryEntity {
  int? id;
  @JsonKey(name: 'name_en')
  String? nameEn;
  @JsonKey(name: 'name_ar')
  String? nameAr;
  @JsonKey(name: 'is_active')
  int? isActive;
  dynamic image;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;

  SimilarProductEntityProductsDataCategoryEntity(
      this.id,
      this.nameEn,
      this.nameAr,
      this.isActive,
      this.image,
      this.userId,
      this.createdAt,
      this.updatedAt,
      );

  factory SimilarProductEntityProductsDataCategoryEntity.fromJson(
      Map<String, dynamic> json,
      ) => _$SimilarProductEntityProductsDataCategoryEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SimilarProductEntityProductsDataCategoryEntityToJson(this);
}

@JsonSerializable()
class SimilarProductEntityProductsDataTypeEntity {
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

  SimilarProductEntityProductsDataTypeEntity(
      this.id,
      this.nameEn,
      this.nameAr,
      this.isActive,
      this.userId,
      this.createdAt,
      this.updatedAt,
      );

  factory SimilarProductEntityProductsDataTypeEntity.fromJson(
      Map<String, dynamic> json,
      ) => _$SimilarProductEntityProductsDataTypeEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SimilarProductEntityProductsDataTypeEntityToJson(this);
}

@JsonSerializable()
class SimilarProductEntityProductsLinksEntity {
  dynamic url;
  String? label;
  dynamic page;
  bool? active;

  SimilarProductEntityProductsLinksEntity(
      this.url,
      this.label,
      this.page,
      this.active,
      );

  factory SimilarProductEntityProductsLinksEntity.fromJson(
      Map<String, dynamic> json,
      ) => _$SimilarProductEntityProductsLinksEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SimilarProductEntityProductsLinksEntityToJson(this);
}
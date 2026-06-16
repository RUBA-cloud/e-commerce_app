import 'package:json_annotation/json_annotation.dart';

part 'filter_option_entity.g.dart';

@JsonSerializable()
class FilterOptionEntity {
  String status;
  String message;
  List<FilterOptionCategoriesEntity> categories;
  List<FilterOptionSizesEntity> sizes;
  List<FilterOptionTypesEntity> types;
  List<FilterOptionBrandsEntity> brands;
  List<String> colors;
  List<String> prices;

  FilterOptionEntity(
    this.status,
    this.message,
    this.categories,
    this.sizes,
    this.types,
    this.brands,
    this.colors,
    this.prices,
  );

  factory FilterOptionEntity.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FilterOptionEntityToJson(this);
}

@JsonSerializable()
class FilterOptionCategoriesEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  String image;
  @JsonKey(name: 'is_active')
  int isActive;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;

  FilterOptionCategoriesEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.image,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory FilterOptionCategoriesEntity.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionCategoriesEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FilterOptionCategoriesEntityToJson(this);
}

@JsonSerializable()
class FilterOptionSizesEntity {
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
  dynamic image;
  String descripation;
  int price;

  FilterOptionSizesEntity(
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

  factory FilterOptionSizesEntity.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionSizesEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FilterOptionSizesEntityToJson(this);
}

@JsonSerializable()
class FilterOptionTypesEntity {
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

  FilterOptionTypesEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory FilterOptionTypesEntity.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionTypesEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FilterOptionTypesEntityToJson(this);
}

@JsonSerializable()
class FilterOptionBrandsEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_top')
  bool isTop;
  @JsonKey(name: 'is_active')
  bool isActive;
  String image;
  @JsonKey(name: 'company_id')
  int companyId;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;
  @JsonKey(name: 'category_id')
  int categoryId;
  @JsonKey(name: 'image_url')
  String imageUrl;

  FilterOptionBrandsEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isTop,
    this.isActive,
    this.image,
    this.companyId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.categoryId,
    this.imageUrl,
  );

  factory FilterOptionBrandsEntity.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionBrandsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FilterOptionBrandsEntityToJson(this);
}

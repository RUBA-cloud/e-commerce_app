import 'package:json_annotation/json_annotation.dart';

part 'filter_result_entity.g.dart';

@JsonSerializable()
class FilterResultEntity {
  bool status;
  FilterResultDataEntity data;

  FilterResultEntity(this.status, this.data);

  factory FilterResultEntity.fromJson(Map<String, dynamic> json) =>
      _$FilterResultEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FilterResultEntityToJson(this);
}

@JsonSerializable()
class FilterResultDataEntity {
  List<FilterResultDataCategoriesEntity> categories;

  FilterResultDataEntity(this.categories);

  factory FilterResultDataEntity.fromJson(Map<String, dynamic> json) =>
      _$FilterResultDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FilterResultDataEntityToJson(this);
}

@JsonSerializable()
class FilterResultDataCategoriesEntity {
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
  List<dynamic> products;

  FilterResultDataCategoriesEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.image,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.products,
  );

  factory FilterResultDataCategoriesEntity.fromJson(
    Map<String, dynamic> json,
  ) => _$FilterResultDataCategoriesEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$FilterResultDataCategoriesEntityToJson(this);
}

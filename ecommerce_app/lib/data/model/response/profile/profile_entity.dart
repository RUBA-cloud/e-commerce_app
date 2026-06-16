import 'package:json_annotation/json_annotation.dart';

part 'profile_entity.g.dart';

@JsonSerializable()
class ProfileEntity {
  String message;
  ProfileUserEntity user;

  ProfileEntity(this.message, this.user);

  factory ProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$ProfileEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileEntityToJson(this);
}

@JsonSerializable()
class ProfileUserEntity {
  int id;
  String name;
  String email;
  String role;
  @JsonKey(name: 'avatar_path')
  dynamic avatarPath;
  @JsonKey(name: 'email_verified_at')
  String emailVerifiedAt;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  String language;
  String theme;
  @JsonKey(name: 'device_token')
  String deviceToken;
  dynamic phone;
  @JsonKey(name: 'notification_on')
  bool notificationOn;
  dynamic address;
  dynamic street;
  @JsonKey(name: 'country_id')
  int countryId;
  @JsonKey(name: 'city_id')
  int cityId;
  ProfileUserCountryEntity country;
  ProfileUserCityEntity city;

  ProfileUserEntity(
    this.id,
    this.name,
    this.email,
    this.role,
    this.avatarPath,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.language,
    this.theme,
    this.deviceToken,
    this.phone,
    this.notificationOn,
    this.address,
    this.street,
    this.countryId,
    this.cityId,
    this.country,
    this.city,
  );

  factory ProfileUserEntity.fromJson(Map<String, dynamic> json) =>
      _$ProfileUserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUserEntityToJson(this);
}

@JsonSerializable()
class ProfileUserCountryEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_active')
  int isActive;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;

  ProfileUserCountryEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory ProfileUserCountryEntity.fromJson(Map<String, dynamic> json) =>
      _$ProfileUserCountryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUserCountryEntityToJson(this);
}

@JsonSerializable()
class ProfileUserCityEntity {
  int id;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_active')
  int isActive;
  @JsonKey(name: 'country_id')
  int countryId;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;

  ProfileUserCityEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.countryId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory ProfileUserCityEntity.fromJson(Map<String, dynamic> json) =>
      _$ProfileUserCityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUserCityEntityToJson(this);
}

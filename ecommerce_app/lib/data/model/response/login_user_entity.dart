import 'package:json_annotation/json_annotation.dart';

part 'login_user_entity.g.dart';

@JsonSerializable()
class LoginUserEntity {
  LoginUserDataEntity data;
  String country;
  String city;
  @JsonKey(name: 'token_type')
  String tokenType;
  @JsonKey(name: 'expires_in')
  int expiresIn;

  LoginUserEntity(
    this.data,
    this.country,
    this.city,
    this.tokenType,
    this.expiresIn,
  );

  factory LoginUserEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginUserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserEntityToJson(this);
}

@JsonSerializable()
class LoginUserDataEntity {
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
  @JsonKey(name: 'access_token')
  String accessToken;
  LoginUserDataCountryEntity country;
  LoginUserDataCityEntity city;

  LoginUserDataEntity(
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
    this.accessToken,
    this.country,
    this.city,
  );

  factory LoginUserDataEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginUserDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserDataEntityToJson(this);
}

@JsonSerializable()
class LoginUserDataCountryEntity {
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

  LoginUserDataCountryEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory LoginUserDataCountryEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginUserDataCountryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserDataCountryEntityToJson(this);
}

@JsonSerializable()
class LoginUserDataCityEntity {
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

  LoginUserDataCityEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.countryId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory LoginUserDataCityEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginUserDataCityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserDataCityEntityToJson(this);
}

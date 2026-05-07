import 'package:json_annotation/json_annotation.dart';

part 'login_entity.g.dart';

@JsonSerializable()
class LoginEntity {
  LoginDataEntity data;
  String country;
  String city;
  @JsonKey(name: 'token_type')
  String tokenType;
  @JsonKey(name: 'expires_in')
  int expiresIn;

  LoginEntity(
    this.data,
    this.country,
    this.city,
    this.tokenType,
    this.expiresIn,
  );

  factory LoginEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginEntityToJson(this);
}

@JsonSerializable()
class LoginDataEntity {
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
  LoginDataCountryEntity country;
  LoginDataCityEntity city;

  LoginDataEntity(
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

  factory LoginDataEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataEntityToJson(this);
}

@JsonSerializable()
class LoginDataCountryEntity {
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

  LoginDataCountryEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory LoginDataCountryEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginDataCountryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataCountryEntityToJson(this);
}

@JsonSerializable()
class LoginDataCityEntity {
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

  LoginDataCityEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.countryId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory LoginDataCityEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginDataCityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataCityEntityToJson(this);
}

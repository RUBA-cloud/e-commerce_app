// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginEntity _$LoginEntityFromJson(Map<String, dynamic> json) => LoginEntity(
  LoginDataEntity.fromJson(json['data'] as Map<String, dynamic>),
  json['country'] as String,
  json['city'] as String,
  json['token_type'] as String,
  (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$LoginEntityToJson(LoginEntity instance) =>
    <String, dynamic>{
      'data': instance.data,
      'country': instance.country,
      'city': instance.city,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };

LoginDataEntity _$LoginDataEntityFromJson(Map<String, dynamic> json) =>
    LoginDataEntity(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['email'] as String,
      json['role'] as String,
      json['avatar_path'],
      json['email_verified_at'] as String,
      json['created_at'] as String,
      json['updated_at'] as String,
      json['language'] as String,
      json['theme'] as String,
      json['device_token'] as String,
      json['phone'],
      json['notification_on'] as bool,
      json['address'],
      json['street'],
      (json['country_id'] as num).toInt(),
      (json['city_id'] as num).toInt(),
      json['access_token'] as String,
      LoginDataCountryEntity.fromJson(json['country'] as Map<String, dynamic>),
      LoginDataCityEntity.fromJson(json['city'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginDataEntityToJson(LoginDataEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'avatar_path': instance.avatarPath,
      'email_verified_at': instance.emailVerifiedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'language': instance.language,
      'theme': instance.theme,
      'device_token': instance.deviceToken,
      'phone': instance.phone,
      'notification_on': instance.notificationOn,
      'address': instance.address,
      'street': instance.street,
      'country_id': instance.countryId,
      'city_id': instance.cityId,
      'access_token': instance.accessToken,
      'country': instance.country,
      'city': instance.city,
    };

LoginDataCountryEntity _$LoginDataCountryEntityFromJson(
  Map<String, dynamic> json,
) => LoginDataCountryEntity(
  (json['id'] as num).toInt(),
  json['name_en'] as String,
  json['name_ar'] as String,
  (json['is_active'] as num).toInt(),
  json['user_id'],
  json['created_at'] as String,
  json['updated_at'] as String,
);

Map<String, dynamic> _$LoginDataCountryEntityToJson(
  LoginDataCountryEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'is_active': instance.isActive,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

LoginDataCityEntity _$LoginDataCityEntityFromJson(Map<String, dynamic> json) =>
    LoginDataCityEntity(
      (json['id'] as num).toInt(),
      json['name_en'] as String,
      json['name_ar'] as String,
      (json['is_active'] as num).toInt(),
      (json['country_id'] as num).toInt(),
      json['user_id'],
      json['created_at'] as String,
      json['updated_at'] as String,
    );

Map<String, dynamic> _$LoginDataCityEntityToJson(
  LoginDataCityEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'is_active': instance.isActive,
  'country_id': instance.countryId,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

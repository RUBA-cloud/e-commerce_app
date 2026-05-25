// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginUserEntity _$LoginUserEntityFromJson(Map<String, dynamic> json) =>
    LoginUserEntity(
      LoginUserDataEntity.fromJson(json['data'] as Map<String, dynamic>),
      json['country'] as String,
      json['city'] as String,
      json['token_type'] as String,
      (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$LoginUserEntityToJson(LoginUserEntity instance) =>
    <String, dynamic>{
      'data': instance.data,
      'country': instance.country,
      'city': instance.city,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };

LoginUserDataEntity _$LoginUserDataEntityFromJson(Map<String, dynamic> json) =>
    LoginUserDataEntity(
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
      LoginUserDataCountryEntity.fromJson(
        json['country'] as Map<String, dynamic>,
      ),
      LoginUserDataCityEntity.fromJson(json['city'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginUserDataEntityToJson(
  LoginUserDataEntity instance,
) => <String, dynamic>{
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

LoginUserDataCountryEntity _$LoginUserDataCountryEntityFromJson(
  Map<String, dynamic> json,
) => LoginUserDataCountryEntity(
  (json['id'] as num).toInt(),
  json['name_en'] as String,
  json['name_ar'] as String,
  (json['is_active'] as num).toInt(),
  json['user_id'],
  json['created_at'] as String,
  json['updated_at'] as String,
);

Map<String, dynamic> _$LoginUserDataCountryEntityToJson(
  LoginUserDataCountryEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'is_active': instance.isActive,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

LoginUserDataCityEntity _$LoginUserDataCityEntityFromJson(
  Map<String, dynamic> json,
) => LoginUserDataCityEntity(
  (json['id'] as num).toInt(),
  json['name_en'] as String,
  json['name_ar'] as String,
  (json['is_active'] as num).toInt(),
  (json['country_id'] as num).toInt(),
  json['user_id'],
  json['created_at'] as String,
  json['updated_at'] as String,
);

Map<String, dynamic> _$LoginUserDataCityEntityToJson(
  LoginUserDataCityEntity instance,
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

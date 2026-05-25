// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_verified_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailVerifiedEntity _$EmailVerifiedEntityFromJson(Map<String, dynamic> json) =>
    EmailVerifiedEntity(
      json['email_verified'] as bool,
      json['message'] as String,
      json['access_token'] as String,
      json['token_type'] as String,
      (json['expires_in'] as num).toInt(),
      EmailVerifiedUserEntity.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EmailVerifiedEntityToJson(
  EmailVerifiedEntity instance,
) => <String, dynamic>{
  'email_verified': instance.emailVerified,
  'message': instance.message,
  'access_token': instance.accessToken,
  'token_type': instance.tokenType,
  'expires_in': instance.expiresIn,
  'user': instance.user,
};

EmailVerifiedUserEntity _$EmailVerifiedUserEntityFromJson(
  Map<String, dynamic> json,
) => EmailVerifiedUserEntity(
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
);

Map<String, dynamic> _$EmailVerifiedUserEntityToJson(
  EmailVerifiedUserEntity instance,
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
};

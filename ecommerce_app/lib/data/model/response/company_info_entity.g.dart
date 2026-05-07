// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyInfoEntity _$CompanyInfoEntityFromJson(Map<String, dynamic> json) =>
    CompanyInfoEntity(
      json['status'] as String,
      json['message'] as String,
      CompanyInfoCompanyEntity.fromJson(
        json['company'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$CompanyInfoEntityToJson(CompanyInfoEntity instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'company': instance.company,
    };

CompanyInfoCompanyEntity _$CompanyInfoCompanyEntityFromJson(
  Map<String, dynamic> json,
) => CompanyInfoCompanyEntity(
  (json['id'] as num).toInt(),
  json['image'] as String,
  json['name_en'] as String,
  json['name_ar'] as String,
  json['about_us_en'] as String,
  json['about_us_ar'] as String,
  json['mission_en'] as String,
  json['mission_ar'] as String,
  json['vision_en'] as String,
  json['vision_ar'] as String,
  json['phone'],
  json['email'] as String,
  json['address_en'] as String,
  json['address_ar'] as String,
  json['location'],
  json['main_color'] as String,
  json['sub_color'] as String,
  json['text_color'] as String,
  json['button_color'] as String,
  json['icon_color'] as String,
  json['text_filed_color'] as String,
  json['hint_color'] as String,
  json['button_text_color'] as String,
  json['card_color'] as String,
  json['label_color'] as String,
  json['user_id'],
  json['created_at'] as String,
  json['updated_at'] as String,
  json['facebook'],
  json['instagram'],
  json['twitter'],
  (json['country_id'] as num).toInt(),
  (json['city_id'] as num).toInt(),
);

Map<String, dynamic> _$CompanyInfoCompanyEntityToJson(
  CompanyInfoCompanyEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'image': instance.image,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'about_us_en': instance.aboutUsEn,
  'about_us_ar': instance.aboutUsAr,
  'mission_en': instance.missionEn,
  'mission_ar': instance.missionAr,
  'vision_en': instance.visionEn,
  'vision_ar': instance.visionAr,
  'phone': instance.phone,
  'email': instance.email,
  'address_en': instance.addressEn,
  'address_ar': instance.addressAr,
  'location': instance.location,
  'main_color': instance.mainColor,
  'sub_color': instance.subColor,
  'text_color': instance.textColor,
  'button_color': instance.buttonColor,
  'icon_color': instance.iconColor,
  'text_filed_color': instance.textFiledColor,
  'hint_color': instance.hintColor,
  'button_text_color': instance.buttonTextColor,
  'card_color': instance.cardColor,
  'label_color': instance.labelColor,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'facebook': instance.facebook,
  'instagram': instance.instagram,
  'twitter': instance.twitter,
  'country_id': instance.countryId,
  'city_id': instance.cityId,
};

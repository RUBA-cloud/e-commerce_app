import 'package:json_annotation/json_annotation.dart';

part 'company_info_entity.g.dart';

@JsonSerializable()
class CompanyInfoEntity {
  String status;
  String message;
  CompanyInfoCompanyEntity company;

  CompanyInfoEntity(this.status, this.message, this.company);

  factory CompanyInfoEntity.fromJson(Map<String, dynamic> json) =>
      _$CompanyInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyInfoEntityToJson(this);
}

@JsonSerializable()
class CompanyInfoCompanyEntity {
  int id;
  String image;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'about_us_en')
  String aboutUsEn;
  @JsonKey(name: 'about_us_ar')
  String aboutUsAr;
  @JsonKey(name: 'mission_en')
  String missionEn;
  @JsonKey(name: 'mission_ar')
  String missionAr;
  @JsonKey(name: 'vision_en')
  String visionEn;
  @JsonKey(name: 'vision_ar')
  String visionAr;
  dynamic phone;
  String email;
  @JsonKey(name: 'address_en')
  String addressEn;
  @JsonKey(name: 'address_ar')
  String addressAr;
  dynamic location;
  @JsonKey(name: 'main_color')
  String mainColor;
  @JsonKey(name: 'sub_color')
  String subColor;
  @JsonKey(name: 'text_color')
  String textColor;
  @JsonKey(name: 'button_color')
  String buttonColor;
  @JsonKey(name: 'icon_color')
  String iconColor;
  @JsonKey(name: 'text_filed_color')
  String textFiledColor;
  @JsonKey(name: 'hint_color')
  String hintColor;
  @JsonKey(name: 'button_text_color')
  String buttonTextColor;
  @JsonKey(name: 'card_color')
  String cardColor;
  @JsonKey(name: 'label_color')
  String labelColor;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  dynamic facebook;
  dynamic instagram;
  dynamic twitter;
  @JsonKey(name: 'country_id')
  int countryId;
  @JsonKey(name: 'city_id')
  int cityId;

  CompanyInfoCompanyEntity(
    this.id,
    this.image,
    this.nameEn,
    this.nameAr,
    this.aboutUsEn,
    this.aboutUsAr,
    this.missionEn,
    this.missionAr,
    this.visionEn,
    this.visionAr,
    this.phone,
    this.email,
    this.addressEn,
    this.addressAr,
    this.location,
    this.mainColor,
    this.subColor,
    this.textColor,
    this.buttonColor,
    this.iconColor,
    this.textFiledColor,
    this.hintColor,
    this.buttonTextColor,
    this.cardColor,
    this.labelColor,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.facebook,
    this.instagram,
    this.twitter,
    this.countryId,
    this.cityId,
  );

  factory CompanyInfoCompanyEntity.fromJson(Map<String, dynamic> json) =>
      _$CompanyInfoCompanyEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyInfoCompanyEntityToJson(this);
}

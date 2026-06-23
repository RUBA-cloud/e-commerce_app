import 'package:json_annotation/json_annotation.dart';

part 'user_payment_entity.g.dart';

@JsonSerializable()
class UserPaymentEntity {
  final bool success;
  final UserPaymentDataEntity data;

  UserPaymentEntity(this.success, this.data);

  factory UserPaymentEntity.fromJson(Map<String, dynamic> json) =>
      _$UserPaymentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserPaymentEntityToJson(this);
}

@JsonSerializable()
class UserPaymentDataEntity {
  final int id;
  final String name;
  final String email;
  final String role;
  @JsonKey(name: 'avatar_path')
  final dynamic avatarPath;
  @JsonKey(name: 'email_verified_at')
  final String emailVerifiedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final String language;
  final String theme;
  @JsonKey(name: 'device_token')
  final String deviceToken;
  final dynamic phone;
  @JsonKey(name: 'notification_on')
  final bool notificationOn;
  final dynamic address;
  final dynamic street;
  @JsonKey(name: 'country_id')
  final int countryId;
  @JsonKey(name: 'city_id')
  final int cityId;
  @JsonKey(name: 'payment_id')
  final int paymentId;
  final UserPaymentDataPaymentEntity payment;

  UserPaymentDataEntity(
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
    this.paymentId,
    this.payment,
  );

  factory UserPaymentDataEntity.fromJson(Map<String, dynamic> json) =>
      _$UserPaymentDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserPaymentDataEntityToJson(this);
}

@JsonSerializable()
class UserPaymentDataPaymentEntity {
  final int id;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  @JsonKey(name: 'is_active')
  final int isActive;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  UserPaymentDataPaymentEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory UserPaymentDataPaymentEntity.fromJson(Map<String, dynamic> json) =>
      _$UserPaymentDataPaymentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserPaymentDataPaymentEntityToJson(this);
}

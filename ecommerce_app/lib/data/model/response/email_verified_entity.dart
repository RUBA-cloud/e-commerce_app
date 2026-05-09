import 'package:json_annotation/json_annotation.dart';

part 'email_verified_entity.g.dart';

@JsonSerializable()
class EmailVerifiedEntity {
  @JsonKey(name: 'email_verified')
  bool emailVerified;
  String message;
  @JsonKey(name: 'access_token')
  String accessToken;
  @JsonKey(name: 'token_type')
  String tokenType;
  @JsonKey(name: 'expires_in')
  int expiresIn;
  EmailVerifiedUserEntity user;

  EmailVerifiedEntity(this.emailVerified, this.message, this.accessToken,
      this.tokenType, this.expiresIn, this.user);

  factory EmailVerifiedEntity.fromJson(Map<String, dynamic> json) =>
      _$EmailVerifiedEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EmailVerifiedEntityToJson(this);
}

@JsonSerializable()
class EmailVerifiedUserEntity {
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

  EmailVerifiedUserEntity(this.id, this.name, this.email, this.role,
      this.avatarPath, this.emailVerifiedAt, this.createdAt, this.updatedAt,
      this.language, this.theme, this.deviceToken, this.phone,
      this.notificationOn, this.address, this.street, this.countryId,
      this.cityId);

  factory EmailVerifiedUserEntity.fromJson(Map<String, dynamic> json) =>
      _$EmailVerifiedUserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EmailVerifiedUserEntityToJson(this);
}

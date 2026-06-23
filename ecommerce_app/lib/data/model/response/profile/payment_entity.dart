import 'package:json_annotation/json_annotation.dart';

part 'payment_entity.g.dart';

@JsonSerializable()
class PaymentEntity {
  final bool success;
  final List<PaymentDataEntity> data;

  PaymentEntity(this.success, this.data);

  factory PaymentEntity.fromJson(Map<String, dynamic> json) =>
      _$PaymentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentEntityToJson(this);
}

@JsonSerializable()
class PaymentDataEntity {
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

  PaymentDataEntity(
    this.id,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.userId,
    this.createdAt,
    this.updatedAt,
  );

  factory PaymentDataEntity.fromJson(Map<String, dynamic> json) =>
      _$PaymentDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDataEntityToJson(this);
}

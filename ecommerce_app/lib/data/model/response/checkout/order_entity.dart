import 'package:json_annotation/json_annotation.dart';

part 'order_entity.g.dart';

@JsonSerializable()
class OrderEntity {
  String status;
  String message;
  OrderDataEntity data;

  OrderEntity(this.status, this.message, this.data);

  factory OrderEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OrderEntityToJson(this);
}

@JsonSerializable()
class OrderDataEntity {
  @JsonKey(name: 'user_id')
  int userId;
  int status;
  @JsonKey(name: 'order_status_id')
  int orderStatusId;
  String address;
  @JsonKey(name: 'street_name')
  String streetName;
  @JsonKey(name: 'building_number')
  String buildingNumber;
  int lat;
  int long;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  @JsonKey(name: 'created_at')
  String createdAt;
  int id;
  @JsonKey(name: 'created_at_human')
  String createdAtHuman;
  @JsonKey(name: 'updated_at_human')
  String updatedAtHuman;

  OrderDataEntity(
    this.userId,
    this.status,
    this.orderStatusId,
    this.address,
    this.streetName,
    this.buildingNumber,
    this.lat,
    this.long,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.createdAtHuman,
    this.updatedAtHuman,
  );

  factory OrderDataEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDataEntityToJson(this);
}

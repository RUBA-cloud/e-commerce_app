import 'package:json_annotation/json_annotation.dart';

part 'email_entity.g.dart';

@JsonSerializable()
class EmailEntity {
  String message;

  EmailEntity(this.message);

  factory EmailEntity.fromJson(Map<String, dynamic> json) =>
      _$EmailEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EmailEntityToJson(this);
}

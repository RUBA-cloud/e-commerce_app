// lib/models/type_model.dart
import 'package:equatable/equatable.dart';

class TypeModel extends Equatable {
  final int id;
  final String nameEn;
  final String nameAr;

  const TypeModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  /// Create instance from JSON (e.g. API response)
  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'] ?? 0,
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
    );
  }

  /// Convert instance to JSON (e.g. for POST request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
    };
  }

  /// Clone with modified fields
  TypeModel copyWith({
    int? id,
    String? nameEn,
    String? nameAr,
  }) {
    return TypeModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
    );
  }

  @override
  List<Object?> get props => [id, nameEn, nameAr];
}

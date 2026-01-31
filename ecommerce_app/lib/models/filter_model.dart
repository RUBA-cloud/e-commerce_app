// lib/models/filter_model.dart
import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/size_model.dart';
import 'package:ecommerce_app/models/type_model.dart';

class FilterModel extends Equatable {
  // القوائم القادمة من الـ API
  final List<CategoryModel> categories;
  final List<SizeModel> sizes;
  final List<TypeModel> types;
  final List<String>? colors;

  // الاختيارات الحالية
  final int categoryId;
  final int? selectedTypeId;
  final int? selectedSizeId;
  final String? selectedColor;
  


  // السعر
  final double? minPrice;
  final double? maxPrice;

  const FilterModel({
    this.categories = const [],
    this.sizes = const [],
    this.types = const [],
    this.colors = const [],
    this.categoryId = 0,
    this.selectedTypeId,
    this.selectedSizeId,
    this.selectedColor,
    this.minPrice,
    this.maxPrice,
  });

  /// حالة بداية (فلتر فاضي)
  factory FilterModel.initial() => const FilterModel();

  /// من JSON (لو جاي من API)
  factory FilterModel.fromJson(Map<String, dynamic> json) {
    final catsJson  = json['categories'] as List<dynamic>? ?? const [];
    final sizesJson = json['sizes'] as List<dynamic>? ?? const [];
    final typesJson = json['types'] as List<dynamic>? ?? const [];

    return FilterModel(
      categories: catsJson
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sizes: sizesJson
          .map((e) => SizeModel.fromMap(e)) // حسب اللي كنتِ كاتباه
          .toList(),
      types: typesJson
          .map((e) => TypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      minPrice: (json['min_price'] is num)
          ? (json['min_price'] as num).toDouble()
          : null,
      maxPrice: (json['max_price'] is num)
          ? (json['max_price'] as num).toDouble()
          : null,
      // لو API يرجع selectedTypeId/selectedSizeId/selectedColor تقدري تضيفيها هنا:
      // selectedTypeId: (json['selected_type_id'] as num?)?.toInt(),
      // selectedSizeId: (json['selected_size_id'] as num?)?.toInt(),
      // selectedColor: json['selected_color'] as String?,
    );
  }

  /// copyWith مرن علشان الـ Cubit
  FilterModel copyWith({
    List<CategoryModel>? categories,
    List<SizeModel>? sizes,
    List<TypeModel>? types,
    List<String>? colors,
    int? categoryId,
    int? selectedTypeId,
    int? selectedSizeId,
    String? selectedColor,
    double? minPrice,
    double? maxPrice,
  }) {
    return FilterModel(
      categories: categories ?? this.categories,
      sizes: sizes ?? this.sizes,
      types: types ?? this.types,
      colors: colors ?? this.colors,
      categoryId: categoryId ?? this.categoryId,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      selectedSizeId: selectedSizeId ?? this.selectedSizeId,
      selectedColor: selectedColor ?? this.selectedColor,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        sizes,
        types,
        colors,
        categoryId,
        selectedTypeId,
        selectedSizeId,
        selectedColor,
        minPrice,
        maxPrice,
      ];
Map<String, dynamic> toJson() {
  return {
    'categories': categories.map((e) => e.toJson()).toList(),
    'sizes': sizes.map((e) => e.toMap()).toList(),
    'types': types.map((e) => e.toJson()).toList(),
    'colors': colors,

    'category_id': categoryId,
    'selected_type_id': selectedTypeId,
    'selected_size_id': selectedSizeId,
    'selected_color': selectedColor,

    'min_price': minPrice,
    'max_price': maxPrice,
  };
}

}

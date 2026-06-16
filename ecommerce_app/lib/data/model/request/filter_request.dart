class FilterRequest {
  final int? categoryId;
  final int? typeId;
  final int? sizeId;
  final String? color;
  final String? search;
  final double? priceFrom;
  final double? priceTo;

  FilterRequest({
    this.categoryId,
    this.typeId,
    this.sizeId,
    this.color,
    this.search,
    this.priceFrom,
    this.priceTo,
  });

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      if (typeId != null) 'type_id': typeId,
      if (sizeId != null) 'size_id': sizeId,
      if (color != null) 'color': color,
      if (search != null) 'search': search,
      if (priceFrom != null) 'price_from': priceFrom,
      if (priceTo != null) 'price_to': priceTo,
    };
  }

  factory FilterRequest.fromJson(Map<String, dynamic> json) {
    return FilterRequest(
      categoryId: json['category_id'],
      typeId: json['type_id'],
      sizeId: json['size_id'],
      color: json['color'],
      search: json['search'],
      priceFrom: json['price_from']?.toDouble(),
      priceTo: json['price_to']?.toDouble(),
    );
  }
}
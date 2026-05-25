class BrandRequest {
  final int? categoryId;

  const BrandRequest({
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
    };
  }}
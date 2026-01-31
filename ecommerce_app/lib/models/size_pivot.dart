
class SizePivot {
  final int productId;
  final int sizeId;

  SizePivot({
    required this.productId,
    required this.sizeId,
  });

  factory SizePivot.fromJson(Map<String, dynamic> json) {
    return SizePivot(
      productId: json['product_id'] ?? 0,
      sizeId: json['size_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'size_id': sizeId,
    };
  }
}
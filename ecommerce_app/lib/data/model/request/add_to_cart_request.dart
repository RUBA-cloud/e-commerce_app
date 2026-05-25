class AddToCartRequest {
  final String productId;
  final int quantity;
  final int sizeId;

  AddToCartRequest({
    required this.productId,
    required this.quantity,
    required this.sizeId,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "quantity": quantity,
      "size_id": sizeId,
    };
  }
}
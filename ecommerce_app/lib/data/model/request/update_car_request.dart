class UpdateCartRequest {
  final int id;
  final int quantity;
  final int sizeId;

  UpdateCartRequest({
    required this.id,
    required this.quantity,
    required this.sizeId,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "quantity": quantity,
      "size_id": sizeId,
    };
  }
}
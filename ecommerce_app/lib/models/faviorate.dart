import 'package:ecommerce_app/models/product_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class FavoriteItem {
  final int id;
  final ProductModel product;

  const FavoriteItem({
    required this.id,
    required this.product,
  });

  // Optional: factory constructor to build from JSON
  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as int,
      product: ProductModel.fromJson(json['product']),
    );
  }

  // Optional: convert back to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
    };
  }

  // Useful equality overrides
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          product == other.product;

  @override
  int get hashCode => id.hashCode ^ product.hashCode;

  get createdAt => null;
}

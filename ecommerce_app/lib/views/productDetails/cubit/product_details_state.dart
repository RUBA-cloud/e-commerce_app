// lib/views/product_details/cubit/product_details_state.dart
import 'package:ecommerce_app/models/product_model.dart';
import 'package:flutter/foundation.dart';

enum ProductDetailsStatus { loading, loaded, error, addingToCart }

@immutable
class ProductDetailsState {
  final ProductDetailsStatus status;
  final ProductModel? product;

  final int selectedImage; // index
  final int? selectedColor; // ARGB int
  final String? selectedSize; // e.g. "M"
  final int qty;
  final bool isFavorite;
  final bool expandedDesc;
  final String? error;

  const ProductDetailsState({
    required this.status,
    required this.product,
    required this.selectedImage,
    required this.selectedColor,
    required this.selectedSize,
    required this.qty,
    required this.isFavorite,
    required this.expandedDesc,
    this.error,
  });

  factory ProductDetailsState.initial() => const ProductDetailsState(
        status: ProductDetailsStatus.loading,
        product: null,
        selectedImage: 0,
        selectedColor: null,
        selectedSize: null,
        qty: 1,
        isFavorite: false,
        expandedDesc: false,
        error: null,
      );

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    ProductModel? product,
    int? selectedImage,
    int? selectedColor,
    String? selectedSize,
    int? qty,
    bool? isFavorite,
    bool? expandedDesc,
    String? error,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product ?? this.product,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      qty: qty ?? this.qty,
      isFavorite: isFavorite ?? this.isFavorite,
      expandedDesc: expandedDesc ?? this.expandedDesc,
      error: error,
    );
  }
}

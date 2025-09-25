// lib/models/product_model.dart
import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String? brand;
  final List<String> images;
  final double price;
  final double? oldPrice;
  final double rating; // 0..5
  final int reviewsCount;
  final List<int> colors; // ARGB hex ints (e.g., 0xFF1D5D9B)
  final List<String> sizes; // e.g., ["S","M","L"]
  final String description;
  final Map<String, String> specs; // e.g., {"Material":"Cotton","SKU":"X-22"}
  final bool inStock;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.colors,
    required this.sizes,
    required this.description,
    required this.specs,
    required this.inStock,
    this.brand,
    this.oldPrice,
    this.isFavorite = false,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    List<String>? images,
    double? price,
    double? oldPrice,
    double? rating,
    int? reviewsCount,
    List<int>? colors,
    List<String>? sizes,
    String? description,
    Map<String, String>? specs,
    bool? inStock,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      description: description ?? this.description,
      specs: specs ?? this.specs,
      inStock: inStock ?? this.inStock,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Demo fallback (replace by repo)
  static ProductModel demo(String id) => ProductModel(
        id: id,
        name: "Classic Hoodie",
        brand: "AIP",
        images: [
          "https://placehold.co/800x800?text=Hoodie+Front",
          "https://placehold.co/800x800?text=Hoodie+Back",
          "https://placehold.co/800x800?text=Detail",
        ],
        price: 22.50,
        oldPrice: 29.90,
        rating: 4.4,
        reviewsCount: 124,
        colors: [0xFF1D5D9B, 0xFFA53860, 0xFF432E54],
        sizes: ["S", "M", "L", "XL"],
        description:
            "Soft cotton hoodie with ribbed cuffs, kangaroo pocket, and adjustable drawstring.",
        specs: {
          "Material": "100% Cotton",
          "Fit": "Regular",
          "SKU": "HD-CL-001",
          "Care": "Machine wash",
        },
        inStock: true,
      );
}

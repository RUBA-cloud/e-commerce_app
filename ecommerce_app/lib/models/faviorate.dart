// lib/favorites/favorite_item.dart
import 'package:flutter/foundation.dart';

@immutable
class FavoriteItem {
  final String id;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final double price;

  const FavoriteItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.price,
  });
}

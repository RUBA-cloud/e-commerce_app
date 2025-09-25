// lib/favorites/favorite_state.dart
import 'package:ecommerce_app/models/faviorate.dart';
import 'package:flutter/foundation.dart';

enum FavoriteStatus { idle, loading, success, failure }

enum FavoriteSort { newest, priceAsc, priceDesc }

enum FavoriteViewMode { grid, list }

@immutable
class FavoriteState {
  final FavoriteStatus status;
  final List<FavoriteItem> items;
  final String query;
  final FavoriteSort sort;
  final FavoriteViewMode viewMode;
  final String error;

  const FavoriteState({
    required this.status,
    required this.items,
    required this.query,
    required this.sort,
    required this.viewMode,
    required this.error,
  });

  factory FavoriteState.initial() => const FavoriteState(
        status: FavoriteStatus.idle,
        items: [],
        query: '',
        sort: FavoriteSort.newest,
        viewMode: FavoriteViewMode.grid,
        error: '',
      );

  List<FavoriteItem> get visible {
    var list = items.where((e) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return e.nameEn.toLowerCase().contains(q) ||
          e.nameAr.toLowerCase().contains(q);
    }).toList();

    switch (sort) {
      case FavoriteSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case FavoriteSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case FavoriteSort.newest:

        // assuming input order newest first
        break;
    }
    return list;
  }

  FavoriteState copyWith({
    FavoriteStatus? status,
    List<FavoriteItem>? items,
    String? query,
    FavoriteSort? sort,
    FavoriteViewMode? viewMode,
    String? error,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      viewMode: viewMode ?? this.viewMode,
      error: error ?? this.error,
    );
  }
}

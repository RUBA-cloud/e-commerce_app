// lib/views/faviorate/cubit/faviorate_state.dart

import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/models/faviorate.dart';

enum FavoriteStatus {
  initial,
  loading,
  success,
  itemsListChange,
  failure,
  itemAdded,
  itemRemoved,
  cleared,
}

enum FavoriteSort { newest, priceAsc, priceDesc }

enum FavoriteViewMode { grid, list }

class FavoriteState extends Equatable {
  final List<FavoriteItem> ?items;
  final FavoriteStatus status;
  final FavoriteSort sort;
  final FavoriteViewMode viewMode;
  final String query;
  final String? error;

  const FavoriteState({
    required this.items,
    required this.status,
    required this.sort,
    required this.viewMode,
    required this.query,
    this.error,
  });

  factory FavoriteState.initial() {
    return const FavoriteState(
      items: [],
      status: FavoriteStatus.initial,
      sort: FavoriteSort.newest,
      viewMode: FavoriteViewMode.grid,
      query: '',
      error: null,
    );
  }

  FavoriteState copyWith({
    List<FavoriteItem>? items,
    FavoriteStatus? status,
    FavoriteSort? sort,
    FavoriteViewMode? viewMode,
    String? query,
    String? error,
  }) {
    return FavoriteState(
      items: items ?? this.items,
      status: status ?? this.status,
      sort: sort ?? this.sort,
      viewMode: viewMode ?? this.viewMode,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [items, status, sort, viewMode, query, error];
}

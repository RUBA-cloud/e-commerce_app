// lib/favorites/favorite_cubit.dart
import 'package:ecommerce_app/models/faviorate.dart';
import 'package:ecommerce_app/repostery%20/faviorate_repostery.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteRepository repo;

  FavoriteCubit(this.repo) : super(FavoriteState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: FavoriteStatus.loading, error: ''));
    try {
      final data = await repo.fetchAll();
      emit(state.copyWith(status: FavoriteStatus.success, items: data));
    } catch (e) {
      emit(state.copyWith(status: FavoriteStatus.failure, error: e.toString()));
    }
  }

  Future<void> add(FavoriteItem item) async {
    final next = [item, ...state.items];
    emit(state.copyWith(items: next));
    await repo.saveAll(next);
  }

  Future<void> remove(String id) async {
    final next = state.items.where((e) => e.id != id).toList();
    emit(state.copyWith(items: next));
    await repo.saveAll(next);
  }

  Future<void> toggle(FavoriteItem item) async {
    final exists = state.items.any((e) => e.id == item.id);
    if (exists) {
      await remove(item.id);
    } else {
      await add(item);
    }
  }

  void setQuery(String q) => emit(state.copyWith(query: q));
  void setSort(FavoriteSort s) => emit(state.copyWith(sort: s));
  void setView(FavoriteViewMode v) => emit(state.copyWith(viewMode: v));

  Future<void> clearAll() async {
    emit(state.copyWith(items: []));
    await repo.saveAll(const []);
  }
}

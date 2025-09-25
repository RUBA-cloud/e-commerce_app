// lib/favorites/favorite_repo.dart
import 'package:ecommerce_app/models/faviorate.dart';

abstract class FavoriteRepository {
  Future<List<FavoriteItem>> fetchAll();
  Future<void> saveAll(List<FavoriteItem> items);
}

class InMemoryFavoriteRepository implements FavoriteRepository {
  List<FavoriteItem> _store = const [];

  @override
  Future<List<FavoriteItem>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<FavoriteItem>.from(_store);
  }

  @override
  Future<void> saveAll(List<FavoriteItem> items) async {
    _store = List<FavoriteItem>.from(items);
  }
}

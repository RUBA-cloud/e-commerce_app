// lib/favorites/favorite_cubit.dart
import 'package:ecommerce_app/models/faviorate.dart';
import 'package:ecommerce_app/repostery%20/faviorate_repostery.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(FavoriteState.initial());

  final TextEditingController searchController = TextEditingController();

  // ===== Helpers =====
 List<FavoriteItem> _applySort(
  List<FavoriteItem> items,
  FavoriteSort sort,
) {
  final List<FavoriteItem> sorted = List.of(items); // copy
   double priceOf(FavoriteItem item) {
    final p = item.product.price;
    return double.tryParse(p.toString()) ?? 0;
  }

  switch (sort) {
    case FavoriteSort.priceAsc:
      sorted.sort((a, b) {
        final pa = priceOf(a);
        final pb = priceOf(b);
        return pa.compareTo(pb); // الأقل أولاً
      });
      break;

    case FavoriteSort.priceDesc:
      sorted.sort((a, b) {
        final pa = priceOf(a);
        final pb = priceOf(b);
        return pb.compareTo(pa); // الأعلى أولاً
      });
      break;

    case FavoriteSort.newest:
      sorted.sort((a, b) {
        // الأحدث أولاً
        final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(a.id);
        final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(b.id);
        return db.compareTo(da);
      });
      break;

   
  }

  return sorted;
}


  // ===== Actions =====
Future<List<FavoriteItem>> loadFromSqlOnly() async {
  return await ApiFaviorateRepository().loadFromSql();
}

  Future<void> load() async {
    emit(state.copyWith(status: FavoriteStatus.loading, error: ''));

    try {
      final data = await ApiFaviorateRepository().fetchAll();
      final sorted = _applySort(data, state.sort);
      emit(
        state.copyWith(
          status: FavoriteStatus.success,
          items: sorted,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoriteStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> search(String s) async {
    try {
      final result = await ApiFaviorateRepository().search(s);
      final sorted = _applySort(result, state.sort);
      emit(
        state.copyWith(
          items: sorted,
          status: FavoriteStatus.itemsListChange,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoriteStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

 Future<void> toggleFromHome(FavoriteItem fav) async {
  // نسخة قابلة للتعديل من الليست الحالية

   final current = List<FavoriteItem>.from(state.items ?? []);

  // // نبحث إذا العنصر موجود أصلاً (حسب id أو product.id حسب مشروعك)
  // final index = current.indexWhere((e) => e.id == fav.product.id);

  // if (index >= 0) {
  //   // ✅ موجود → نحذف
  //   current.removeAt(index);

  //   final sorted = _applySort(current, state.sort);
  //   emit(
  //     state.copyWith(
  //       items: sorted,
  //       status: FavoriteStatus.itemRemoved,
  //     ),
  //   );
  // } else {
    // ✅ غير موجود → نضيف
    final newItem = FavoriteItem(
      id: fav.id, // لو id ممكن يكون null
      product: fav.product,
    );

    final updated = [...current, newItem];
    final sorted = _applySort(updated, state.sort);

    emit(
      state.copyWith(
        items: sorted,
        status: FavoriteStatus.itemAdded,
      ),
    );
  }



  Future<void> remove(FavoriteItem fav,BuildContext context) async {
    final success =
        await ApiFaviorateRepository().removeFaviorate(fav.id,context,false,fav.product.id);

    if (success) {
      final updated =
          (state.items ?? []).where((e) => e.id != fav.id).toList();
      final sorted = _applySort(updated, state.sort);

      emit(state.copyWith(items: sorted,status:FavoriteStatus.itemRemoved));
    } else {
      emit(
        state.copyWith(
          status: FavoriteStatus.failure,
          error: 'Failed to remove favorite item.',
        ),
      );
    }
  }

  void setSort(FavoriteSort s) {
    final sorted = _applySort(state.items ?? [], s);
    emit(
      state.copyWith(
        sort: s,
        items: sorted,
      ),
    );
  }

  void setView(FavoriteViewMode v) {
    emit(state.copyWith(viewMode: v));
  }

  void newItemAddedOrRemovedFromFaviorate(FavoriteItem fav) {
    // لو عندك بث من سكشن آخر أو من سوكت، طبقي فيه نفس منطق الإضافة/الحذف + _applySort
    final currentItems = List<FavoriteItem>.from(state.items ?? []);
    final index = currentItems.indexWhere((e) => e.id == fav.id);

    if (index >= 0) {
      // تحديث / حذف لو حبيتي
      currentItems[index] = fav;
    } else {
      currentItems.add(fav);
    }

    final sorted = _applySort(currentItems, state.sort);
    emit(state.copyWith(items: sorted));
  }

  Future<void> clearAll() async {
    emit(state.copyWith(items: []));

    final result = await ApiFaviorateRepository().removeAllFaviorate();

    if (result) {
      emit(
        state.copyWith(
          items: const [],
          status: FavoriteStatus.itemRemoved,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: FavoriteStatus.failure,
          error: 'Failed to clear favorites.',
        ),
      );
    }
  }
}

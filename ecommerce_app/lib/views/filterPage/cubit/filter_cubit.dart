// lib/views/filterPage/cubit/filter_cubit.dart

import 'package:ecommerce_app/models/filter_model.dart';
import 'package:ecommerce_app/views/filterPage/cubit/filter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repostery /filter_repoistery.dart';

class FiltersCubit extends Cubit<FiltersState> {
  FiltersCubit() : super(FiltersState.initial());


  Future<void> load(FilterModel? filter) async {
    try {
      // نبدأ تحميل + نمسح أي error قديم
      emit(state.copyWith(
        status: FiltersStatus.loading,
        clearError: true,
        model:  FilterModel(),
      ));

      var data = await ApiFiltersRepository().getFilters();

      final updatedModel = state.model.copyWith(
        categories: data.categories,
        types: data.types,
        sizes: data.sizes,
        colors: data.colors,
        selectedTypeId: filter!=null?filter.selectedTypeId: data.types.first.id,
        selectedSizeId: filter!=null?filter.selectedSizeId:data.selectedSizeId,
        categoryId: filter!=null?filter.categoryId: data.categories.first.id,
        
      );

      emit(state.copyWith(
        model: updatedModel,
        status: FiltersStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FiltersStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// reset كل الفلاتر + إعادة تحميل الداتا
  void reset() {
    // نرجع initial (فلتر فاضي)
    emit(FiltersState.initial());
    // ثم نعيد تحميل الداتا
    load(null);
  }

  /// اختيار كاتيجوري
  void selectCategory(int id) {
    emit(
      state.copyWith(
        model: state.model.copyWith(
          categoryId: id,
          // ممكن هنا تعملي reset لاختيارات تابعة للكاتيجوري
          selectedTypeId: null,
          selectedSizeId: null,
          selectedColor: null,
          minPrice: null,
          maxPrice: null,
          // ملاحظة: ما نمسح القوائم نفسها
          // categories / types / sizes / colors
        ),
      ),
    );

    // لو حابة تجيب أنواع/مقاسات/ألوان خاصة بالفئة:
    // fetchTypesAndSizesForCategory(id);
  }

  /// اختيار نوع (Type)
  void selectType(int id) {
    emit(
      state.copyWith(
        model: state.model.copyWith(
          selectedTypeId: id,
        ),
      ),
    );
  }

  /// اختيار مقاس (Size)
  void selectSize(int id) {
    emit(
      state.copyWith(
        model: state.model.copyWith(
          selectedSizeId: id,
        ),
      ),
    );
  }

  /// اختيار لون
  void selectColor(String? color) {
    emit(
      state.copyWith(
        model: state.model.copyWith(
          selectedColor: color,
        ),
      ),
    );
  }

  /// اختيار رينج السعر
  void setPrice(double min, double max) {
    emit(
      state.copyWith(
        model: state.model.copyWith(
          minPrice: min,
          maxPrice: max,
        ),
      ),
    );
  }

  /// تطبيق الفلاتر
  Future<void> applyFilters() async {
    emit(state.copyWith(status: FiltersStatus.applying));

  }
}

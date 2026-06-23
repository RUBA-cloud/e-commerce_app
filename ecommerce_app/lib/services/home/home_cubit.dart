// lib/services/home/home_cubit.dart

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/filter_request.dart';
import 'package:ecommerce_app/data/model/response/category_entity.dart';
import 'package:ecommerce_app/data/model/response/filter_option_entity.dart';
import 'package:ecommerce_app/data/model/response/filter_result_entity.dart';
import 'package:ecommerce_app/domain/usecases/get_categories_use_case.dart';
import 'package:ecommerce_app/domain/usecases/get_fliter_options.dart';
import 'package:ecommerce_app/domain/usecases/submit_filter_use_case.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Filter options model ──────────────────────────────────────

class FilterOptions {
  final double       minPrice;
  final double       maxPrice;
  final int?         selectedCategoryId;
  final int?         selectedBrandId;
  final int?         selectedSizeId;
  final int?         selectedTypeId;
  final List<String> selectedSizes;
  final List<String> selectedColors;
  final String?      sortBy;
  final String       sortOrder;

  const FilterOptions({
    this.minPrice           = 0,
    this.maxPrice           = 10000,
    this.selectedCategoryId,
    this.selectedBrandId,
    this.selectedSizeId,
    this.selectedTypeId,
    this.selectedSizes  = const [],
    this.selectedColors = const [],
    this.sortBy,
    this.sortOrder = 'asc',
  });

  bool get isActive =>
      selectedCategoryId != null ||
          selectedBrandId    != null ||
          selectedSizeId     != null ||
          selectedTypeId     != null ||
          selectedSizes.isNotEmpty   ||
          selectedColors.isNotEmpty  ||
          sortBy != null             ||
          minPrice > 0               ||
          maxPrice < 10000;

  FilterOptions copyWith({
    double?       minPrice,
    double?       maxPrice,
    int?          selectedCategoryId,
    int?          selectedBrandId,
    int?          selectedSizeId,
    int?          selectedTypeId,
    List<String>? selectedSizes,
    List<String>? selectedColors,
    String?       sortBy,
    String?       sortOrder,
    bool          clearCategory = false,
    bool          clearBrand    = false,
    bool          clearSize     = false,
    bool          clearType     = false,
    bool          clearSort     = false,
  }) =>
      FilterOptions(
        minPrice:           minPrice           ?? this.minPrice,
        maxPrice:           maxPrice           ?? this.maxPrice,
        selectedCategoryId: clearCategory ? null : selectedCategoryId ?? this.selectedCategoryId,
        selectedBrandId:    clearBrand    ? null : selectedBrandId    ?? this.selectedBrandId,
        selectedSizeId:     clearSize     ? null : selectedSizeId     ?? this.selectedSizeId,
        selectedTypeId:     clearType     ? null : selectedTypeId     ?? this.selectedTypeId,
        selectedSizes:      selectedSizes  ?? this.selectedSizes,
        selectedColors:     selectedColors ?? this.selectedColors,
        sortBy:             clearSort ? null : sortBy ?? this.sortBy,
        sortOrder:          sortOrder ?? this.sortOrder,
      );

  FilterRequest toRequest() => FilterRequest(
    categoryId: selectedCategoryId,
    sizeId:     selectedSizeId,
    typeId:     selectedTypeId,
    color:      selectedColors.isNotEmpty ? selectedColors.first : null,
    priceFrom:  minPrice > 0     ? minPrice : null,
    priceTo:    maxPrice < 10000 ? maxPrice : null,
  );
}

// ── Cubit ─────────────────────────────────────────────────────

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  final GetCategoryUseCase     _categoryUseCase      = getIt<GetCategoryUseCase>();
  final GetFilterOptionsUseCse _filterOptionsUseCase = getIt<GetFilterOptionsUseCse>();
  final SubmitFilterUseCase    _submitFilterUseCase  = getIt<SubmitFilterUseCase>();

  // ── Navigation ────────────────────────────────────────────
  int selectedTab = 0;

  void homeTabChange(int index) {
    selectedTab = index;
    _emitLoaded();
  }

  void goToCart() => homeTabChange(1);

  // ── Data ──────────────────────────────────────────────────
  int                  selectedCategoryIndex = 0;
  CategoryEntity?      categoriesEntity;
  FilterOptionEntity?  filterOptionsEntity;
  FilterResultEntity?  filterResultEntity;

  // ── Filter ────────────────────────────────────────────────
  FilterOptions _activeFilter = const FilterOptions();
  FilterOptions get activeFilter => _activeFilter;

  // ── Derived: selected category ────────────────────────────

  CategoryDataDataEntity? get selectedCategory {
    final cats = categoriesEntity?.data.data;
    if (cats == null || cats.isEmpty) return null;
    return cats[selectedCategoryIndex.clamp(0, cats.length - 1)];
  }

  // ── Derived: brands of selected category ─────────────────

  List<CategoryDataDataProductsBrandsEntity> get selectedCategoryBrands {
    return selectedCategory?.brands ?? [];
  }

  // ── Derived: products of selected category ───────────────

  List<CategoryDataDataProductsEntity> get selectedProducts {
    if (filterResultEntity != null && _activeFilter.isActive) {
      final cats = filterResultEntity!.data.categories;
      if (cats.isEmpty) return [];
      return cats
          .expand((c) => c.products)
          .whereType<CategoryDataDataProductsEntity>()
          .toList();
    }
    final products = selectedCategory?.products;
    if (products == null || products.isEmpty) return [];
    return _applyLocalFilter(products);
  }

  // ── Derived: products filtered by selected brand ──────────

  List<CategoryDataDataProductsEntity> get selectedBrandProducts {
    final brandId = _activeFilter.selectedBrandId;
    if (brandId == null) return selectedProducts;
    return selectedProducts
        .where((p) => p.brands.any((b) => b.id == brandId))
        .toList();
  }

  List<CategoryDataDataProductsEntity> _applyLocalFilter(
      List<CategoryDataDataProductsEntity> products,
      ) {
    if (!_activeFilter.isActive) return products;
    return products.where((p) {
      final price   = double.tryParse(p.price) ?? 0.0;
      final inPrice = price >= _activeFilter.minPrice &&
          price <= _activeFilter.maxPrice;
      return inPrice;
    }).toList();
  }

  // ── Apply / clear filter ──────────────────────────────────

  Future<void> applyFilter(FilterOptions options) async {
    if (isClosed) return; // ✅ guard
    _activeFilter      = options;
    filterResultEntity = null;
    _emitLoaded();

    if (!options.isActive) return;

    if (isClosed) return; // ✅ guard before async emit
    emit(HomeFilterLoading());

    try {
      final result = await _submitFilterUseCase.execute(options.toRequest());
      if (isClosed) return; // ✅ guard after await
      switch (result) {
        case Success(:final data):
          filterResultEntity = data;
          _emitLoaded();
        case Failure(:final error):
          emit(HomeFailed(error.toString()));
          _emitLoaded();
      }
    } catch (e) {
      if (isClosed) return; // ✅ guard in catch
      emit(HomeFailed(e.toString()));
      _emitLoaded();
    }
  }

  void clearFilter() {
    if (isClosed) return; // ✅ guard
    _activeFilter      = const FilterOptions();
    filterResultEntity = null;
    _emitLoaded();
  }

  // ── Load filter options ───────────────────────────────────

  Future<void> loadFilterOptions() async {
    try {
      final result = await _filterOptionsUseCase.execute();
      if (isClosed) return; // ✅ guard after await
      switch (result) {
        case Success(:final data):
          filterOptionsEntity = data;
          _emitLoaded();
        case Failure(:final error):
          debugPrint('loadFilterOptions failed: $error');
      }
    } catch (e) {
      if (isClosed) return; // ✅ guard in catch
      debugPrint('loadFilterOptions error: $e');
    }
  }

  // ── Load home ─────────────────────────────────────────────

  Future<void> loadHome() async {
    if (isClosed) return; // ✅ guard
    emit(HomeLoading());

    final ok = await _fetchCategories();

    if (isClosed) return; // ✅ guard AFTER await — this is what caused the crash
    if (ok) _emitLoaded();
  }

  Future<bool> _fetchCategories() async {
    try {
      final result = await _categoryUseCase.execute();
      if (isClosed) return false; // ✅ guard after await
      switch (result) {
        case Success<CategoryEntity>():
          categoriesEntity = result.data;
          return true;
        case Failure<CategoryEntity>():
          if (!isClosed) emit(HomeFailed(result.message)); // ✅ guard
          return false;
      }
    } catch (e) {
      if (!isClosed) emit(HomeFailed(e.toString())); // ✅ guard
      return false;
    }
  }

  // ── Category selection ────────────────────────────────────

  void selectCategory(int index) {
    if (isClosed) return; // ✅ guard
    selectedCategoryIndex = index;
    filterResultEntity    = null;
    _activeFilter         = const FilterOptions();
    _emitLoaded();
  }

  // ── Emit ──────────────────────────────────────────────────
 bool  loggedIn =false;
  void _emitLoaded() {
    if (isClosed) return;              // ✅ guard — prevents the crash
    if (categoriesEntity == null) return;
    emit(HomeLoaded(
      categoriesEntity:      categoriesEntity!,
      brandEntity:           null,
      filterOptionsEntity:   filterOptionsEntity,
      selectedCategoryIndex: selectedCategoryIndex,
      selectedTab:           selectedTab,
      activeFilter:          _activeFilter,
    ));
  }
}

void unawaited(Future<void> future) {}
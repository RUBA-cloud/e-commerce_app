// lib/services/home/home_cubit.dart

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/brand_request.dart';
import 'package:ecommerce_app/data/model/request/filter_request.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/filter_option_entity.dart';

import 'package:ecommerce_app/data/model/response/filter_result_entity.dart';

import 'package:ecommerce_app/domain/usecases/get_categories_use_case.dart';
import 'package:ecommerce_app/domain/usecases/get_fliter_options.dart';
import 'package:ecommerce_app/domain/usecases/get_top_brands_use_case.dart';
import 'package:ecommerce_app/domain/usecases/submit_filter_use_case.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Local UI filter model ────────────────────────────────────────────────────

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

  /// Convert to the Dart request model sent to the API.
  FilterRequest toRequest() => FilterRequest(
    categoryId: selectedCategoryId,
    sizeId:     selectedSizeId,
    typeId:     selectedTypeId,
    color:      selectedColors.isNotEmpty ? selectedColors.first : null,
    priceFrom:  minPrice > 0     ? minPrice : null,
    priceTo:    maxPrice < 10000 ? maxPrice : null,

  );
}

// ── Cubit ────────────────────────────────────────────────────────────────────

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  final GetCategoryUseCase      _categoryUseCase      = getIt<GetCategoryUseCase>();
  final GetTopBrandsUseCase     _getTopBrands         = getIt<GetTopBrandsUseCase>();
  final  GetFilterOptionsUseCse _filterOptionsUseCase = getIt< GetFilterOptionsUseCse>();
  final SubmitFilterUseCase     _submitFilterUseCase  = getIt<SubmitFilterUseCase>();

  // ── Navigation tab ───────────────────────────────────────────────────────
  int selectedTab = 0;

  void homeTabChange(int index) {
    selectedTab = index;
   // _emitLoaded();
  }
  FilterOptions? current;
  void reset() { current = const FilterOptions();}

  void goToCart() => homeTabChange(1);

  // ── Home data ────────────────────────────────────────────────────────────
  int                   selectedCategoryIndex = 0;
  CategoriesEntity?     categoriesEntity;
  BrandEntity?          brandEntity;
  FilterOptionEntity?  filterOptionsEntity;   // options loaded from API
  FilterResultEntity?   filterResultEntity;    // products returned by filter API

  // ── Filter state ─────────────────────────────────────────────────────────
  FilterOptions _activeFilter = const FilterOptions();
  FilterOptions get activeFilter => _activeFilter;

  // ── Products (local filter applied to cached data) ───────────────────────
  List<CategoriesDataDataProductsEntity> get selectedProducts {
    // If the API returned filtered products, use those instead.
    if (filterResultEntity != null && _activeFilter.isActive) {
      final cats = filterResultEntity!.data.categories;
      if (cats.isEmpty) return [];
      // flatten all products from every category returned
      return cats
          .expand((c) => c.products)
          .whereType<CategoriesDataDataProductsEntity>()
          .toList();
    }

    // Otherwise fall back to local price filter on cached data.
    final cats = categoriesEntity?.data.data;
    if (cats == null || cats.isEmpty) return [];
    final idx      = selectedCategoryIndex.clamp(0, cats.length - 1);
    final products = cats[idx].products;
    return _applyLocalFilter(products);
  }

  List<CategoriesDataDataProductsEntity> _applyLocalFilter(
      List<CategoriesDataDataProductsEntity> products,
      ) {
    return products.where((p) {
      final price = double.tryParse(p.price.toString()) ?? 0;
      if (price < _activeFilter.minPrice || price > _activeFilter.maxPrice) {
        return false;
      }
      // if (_activeFilter.selectedBrandId != null &&
      //     p.brandId != _activeFilter.selectedBrandId) {
      //   return false;
      // }false
      return true;
    }).toList();
  }

  // ── Apply / clear filter ─────────────────────────────────────────────────

  /// Called from FilterDialog "Apply" button.
  Future<void> applyFilter(FilterOptions options) async {
    _activeFilter     = options;
    filterResultEntity = null;          // clear stale results
    _emitLoaded();

    if (!options.isActive) return;      // nothing to send to server

    emit(HomeFilterLoading());
    try {
      final result = await _submitFilterUseCase.execute(options.toRequest());
      switch (result) {
        case Success(:final data):
          filterResultEntity = data;
          _emitLoaded();
        case Failure(:final error):
          emit(HomeFailed(error));
          _emitLoaded();               // restore previous loaded state
      }
    } catch (e) {
      emit(HomeFailed(e.toString()));
      _emitLoaded();
    }
  }

  void clearFilter() {
    _activeFilter      = const FilterOptions();
    filterResultEntity = null;
    _emitLoaded();
  }

  // ── Load filter options from API ─────────────────────────────────────────
  Future<void> loadFilterOptions() async {
    try {
      final result = await _filterOptionsUseCase.execute();
      switch (result) {
        case Success(:final data):
          filterOptionsEntity = data;
          _emitLoaded();
        case Failure(:final error):
        // non-fatal: filter dialog still works with static data
          debugPrint('loadFilterOptions failed: $error');
      }
    } catch (e) {
      debugPrint('loadFilterOptions error: $e');
    }
  }

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadHome() async {
    emit(HomeLoading());
    await fetchCategories(silent: true);
    unawaited(loadFilterOptions());       // fire-and-forget; don't block UI
    if (categoriesEntity != null) _emitLoaded();
  }

  Future<void> fetchCategories({bool silent = false}) async {
    if (!silent) emit(HomeLoading());
    try {
      final result = await _categoryUseCase.execute();
      switch (result) {
        case Success<CategoriesEntity>():
          categoriesEntity = result.data;
          await fetchTopBrands(silent: true);
          if (!silent) _emitLoaded();
        case Failure<CategoriesEntity>():
          emit(HomeFailed(result.message));
      }
    } catch (e) {
      emit(HomeFailed(e.toString()));
    }
  }

  Future<void> fetchTopBrands({bool silent = false}) async {
    try {
      final result = await _getTopBrands.execute(
        request: BrandRequest(categoryId: selectedCategoryIndex),
      );
      switch (result) {
        case Success<BrandEntity>():
          brandEntity = result.data;
        case Failure<BrandEntity>():
          if (!silent) emit(HomeFailed(result.error.toString()));
      }
    } catch (e) {
      if (!silent) emit(HomeFailed(e.toString()));
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;
    filterResultEntity    = null;   // reset filter results when category changes
    fetchTopBrands(silent: false);
    _emitLoaded();
  }

  // ── Emit ─────────────────────────────────────────────────────────────────
  void _emitLoaded() {
    if (categoriesEntity == null) return;
    emit(HomeLoaded(
      categoriesEntity:      categoriesEntity!,
      brandEntity:           brandEntity,
      filterOptionsEntity:   filterOptionsEntity,
      selectedCategoryIndex: selectedCategoryIndex,
      selectedTab:           selectedTab,
      activeFilter:          _activeFilter,
    ));
  }
}

// Dart doesn't have a built-in unawaited; import or inline it:
void unawaited(Future<void> future) {}
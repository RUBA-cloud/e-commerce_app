import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/brand_request.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';

import 'package:ecommerce_app/domain/usecases/get_categories_use_case.dart';
import 'package:ecommerce_app/domain/usecases/get_top_brands_use_case.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  final GetCategoryUseCase  _categoryUseCase = getIt<GetCategoryUseCase>();
  final GetTopBrandsUseCase _getTopBrands    = getIt<GetTopBrandsUseCase>();

  // ── Navigation tab ────────────────────────────────────────────────────────
  int selectedTab = 0;

  void homeTabChange(int index) {
    selectedTab = index;
    _emitLoaded();
  }

  void goToCart() => homeTabChange(1);

  // ── Home data ─────────────────────────────────────────────────────────────
  int selectedCategoryIndex = 0;

  CategoriesEntity? categoriesEntity;
  BrandEntity?      brandEntity;

  List<CategoriesDataDataProductsEntity> get selectedProducts {
    final cats = categoriesEntity?.data.data;
    if (cats == null || cats.isEmpty) return [];
    final idx = selectedCategoryIndex.clamp(0, cats.length - 1);
    return cats[idx].products;
  }

  void _emitLoaded() {
    if (categoriesEntity == null) return;
    emit(HomeLoaded(
      categoriesEntity:      categoriesEntity!,
      brandEntity:           brandEntity,
      selectedCategoryIndex: selectedCategoryIndex,
      selectedTab:           selectedTab,
    ));
  }

  Future<void> loadHome() async {
    emit(HomeLoading());
    await fetchCategories(silent: true);

    if (categoriesEntity != null) _emitLoaded();
  }

  Future<void> fetchCategories({bool silent = false}) async {
    if (!silent) emit(HomeLoading());
    try {
      final result = await _categoryUseCase.execute();
      switch (result) {
        case Success<CategoriesEntity>():
          categoriesEntity = result.data;

          await fetchTopBrands(silent: true,);
          if (!silent) _emitLoaded();
        case Failure<CategoriesEntity>():
          emit(HomeFailed(result.message));
      }
    } catch (e) {
      emit(HomeFailed(e.toString()));
    }
  }

  Future<void> fetchTopBrands({bool silent = false,}) async {
    try {
      print(selectedCategoryIndex);
      final result = await _getTopBrands.execute(
        request: BrandRequest(categoryId: selectedCategoryIndex),
      );
      switch (result) {
        case Success<BrandEntity>():
          brandEntity = result.data;

        case Failure<BrandEntity>():

          print(result.error);
       emit(HomeFailed(result.error.toString()));
      }

    } catch (e) {
      if (!silent) emit(HomeFailed(e.toString()));
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;

    fetchTopBrands(silent: false);
    _emitLoaded();
  }
}
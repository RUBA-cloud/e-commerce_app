import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/response/categories_entity.dart';
import 'package:ecommerce_app/domain/usecases/category_use_case.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  final CategoryUseCase _categoryUseCase = getIt<CategoryUseCase>();

  int selectedCategoryIndex = 0;

  // all categories from API
  List<CategoriesDataDataEntity> get categories =>
      _categoriesEntity?.data.data ?? [];

  // products of selected category
  List<CategoriesDataDataProductsEntity> get selectedProducts =>
      categories.isEmpty ? [] : categories[selectedCategoryIndex].products;

  CategoriesEntity? _categoriesEntity;

  Future<void> fetchCategories() async {
    emit(HomeLoading());
    try {
      final result = await _categoryUseCase.execute();
      switch (result) {
        case Success<CategoriesEntity>():
          _categoriesEntity = result.data;
          emit(HomeLoaded(categoriesEntity: result.data));
        case Failure<CategoriesEntity>():
          emit(HomeFailed(result.message));
      }
    } catch (e) {
      emit(HomeFailed(e.toString()));
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;
    if (_categoriesEntity != null) {
      emit(HomeLoaded(categoriesEntity: _categoriesEntity!));
    }
  }
}
// lib/services/product_details/product_details_cubit.dart

import 'package:ecommerce_app/core/di/api_result.dart' show Success, Failure;
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/category_entity.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';
import 'package:ecommerce_app/domain/usecases/cart/add_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/selected_category_use_case.dart';
import 'package:ecommerce_app/services/product_details/product_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/model/response/carts/carts_entity.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit()
      : super(ProductDetailsInitial(
    selectedColor: '',

  ));

  late CategoryDataDataProductsEntity entity;

  final SelectedCategoryUseCase _selectedCategoryUseCase =
  getIt<SelectedCategoryUseCase>();
  final AddCartUseCase _addCart = getIt<AddCartUseCase>();

  static ProductDetailsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // ── helper ───────────────────────────────────────────────────────────────

  void _emit({
    int?                        selectedImageIndex,
    int?                        selectedSizeIndex,
    String?                     selectedColor,
    int?                        quantity,
    bool?                       isFav,
    bool?                       descExpanded,
    CategoriesEntity?           selectedCategory,
    SimilarProductEntityEntity? similarCategory,
  }) {
    emit(ProductDetailsUpdated(
      selectedImageIndex: selectedImageIndex ?? state.selectedImageIndex,
      selectedSizeIndex:  selectedSizeIndex  ?? state.selectedSizeIndex,
      selectedColor:      selectedColor      ?? state.selectedColor,
      quantity:           quantity           ?? state.quantity,
      isFav:              isFav              ?? state.isFav,
      descExpanded:       descExpanded       ?? state.descExpanded,
      selectedCategory:   selectedCategory   ?? state.selectedCategory,
      similarCategory:    similarCategory    ?? state.similarCategory,
    ));
  }

  // ── UI actions ───────────────────────────────────────────────────────────

  void imageChanged(int index) => _emit(selectedImageIndex: index);

  /// ✅ [index] is the list index (0, 1, 2…) — used for highlight comparison
  /// The actual size ID is looked up from entity.sizes[index] when adding to cart
  void selectSize(int index) {
    // ✅ toggle off if tapping the already-selected size
    final next = state.selectedSizeIndex == index ? -1 : index;
    _emit(selectedSizeIndex: next);
  }

  void selectColor(String hex) {
    // ✅ toggle off if tapping the already-selected color
    final next = state.selectedColor == hex ? '' : hex;
    _emit(selectedColor: next);
  }

  void increment() => _emit(quantity: state.quantity + 1);
  void toggleFav() => _emit(isFav: !state.isFav);
  void toggleDesc() => _emit(descExpanded: !state.descExpanded);

  void decrement() {
    if (state.quantity > 1) _emit(quantity: state.quantity - 1);
  }

  // ── Add to cart ───────────────────────────────────────────────────────────

  Future<bool> addToCart(BuildContext context) async {
    // ✅ guard: must select a size if the product has sizes
    if (entity.sizes.isNotEmpty && state.selectedSizeIndex < 0) {
      showSnackBar(
        context: context,
        message: 'select_size'.tr(),
        success: false,
      );
      return false;
    }

    // ✅ resolve the actual size ID from the index (-1 → null when no sizes)
    final sizeId = (entity.sizes.isNotEmpty && state.selectedSizeIndex >= 0)
        ? entity.sizes[state.selectedSizeIndex].id
        : null;

    final request = AddToCartRequest(
      productId: entity.id.toString(),
      quantity:  state.quantity,
      sizeId:    sizeId??0,       // ✅ real size ID, not the list index
      color:     state.selectedColor.isEmpty ? null : state.selectedColor,
    );

    emit(AddProductCartsLoading());
    final result = await _addCart.execute(request);

    switch (result) {
      case Success<CartsEntity>():
        emit(AddProductsToCartsSuccess());
        return true;
      case Failure<CartsEntity>():
        emit(AddProductsToCartsFail());
        return false;
    }
  }

  // ── Fetch similar products by category ───────────────────────────────────

  Future<void> fetchSelectedCategory(int categoryId) async {
    emit(ProductDetailsCategoryLoading(
      selectedImageIndex: state.selectedImageIndex,
      selectedSizeIndex:  state.selectedSizeIndex,
      selectedColor:      state.selectedColor,
      quantity:           state.quantity,
      isFav:              state.isFav,
      descExpanded:       state.descExpanded,
      selectedCategory:   state.selectedCategory,
      similarCategory:    state.similarCategory,
    ));

    final result = await _selectedCategoryUseCase.execute(categoryId);

    switch (result) {
      case Success<SimilarProductEntityEntity>():
        emit(ProductDetailsCategoryLoaded(
          selectedImageIndex: state.selectedImageIndex,
          selectedSizeIndex:  state.selectedSizeIndex,
          selectedColor:      state.selectedColor,
          quantity:           state.quantity,
          isFav:              state.isFav,
          descExpanded:       state.descExpanded,
          selectedCategory:   state.selectedCategory,
          similarCategory:    result.data,
        ));

      case Failure<SimilarProductEntityEntity>():
        emit(ProductDetailsCategoryFailed(
          error:              result.message,
          selectedImageIndex: state.selectedImageIndex,
          selectedSizeIndex:  state.selectedSizeIndex,
          selectedColor:      state.selectedColor,
          quantity:           state.quantity,
          isFav:              state.isFav,
          descExpanded:       state.descExpanded,
          selectedCategory:   state.selectedCategory,
          similarCategory:    state.similarCategory,
        ));
    }
  }
}
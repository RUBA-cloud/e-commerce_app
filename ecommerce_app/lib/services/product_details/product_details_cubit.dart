import 'package:ecommerce_app/core/di/api_result.dart' show Success, Failure;
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/add_to_cart_request.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';
import 'package:ecommerce_app/domain/usecases/cart/add_cart_use_case.dart';
import 'package:ecommerce_app/domain/usecases/selected_category_use_case.dart';
import 'package:ecommerce_app/services/product_details/product_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/model/response/carts/carts_entity.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this.entity)
      : super(ProductDetailsInitial(
    selectedColor: entity.colors.isNotEmpty ? entity.colors.first : '',
  ));

  // ✅ store product as field — used in fetchSelectedCategory & addToCart
  final CategoriesDataDataProductsEntity entity;

  final SelectedCategoryUseCase _selectedCategoryUseCase =
  getIt<SelectedCategoryUseCase>();
  final AddCartUseCase _addCart = getIt<AddCartUseCase>();
  static ProductDetailsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // ── helper ───────────────────────────────────────────────────────────────

  void _emit({
    int?            selectedImageIndex,
    int?            selectedSizeIndex,
    String?         selectedColor,
    int?            quantity,
    bool?           isFav,
    bool?           descExpanded,
    CategoriesEntity? selectedCategory,
    SimilarProductEntityEntity?   similarCategory,
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
  void selectSize(int index)   => _emit(selectedSizeIndex: index);
  void selectColor(String hex) => _emit(selectedColor: hex);
  void increment()             => _emit(quantity: state.quantity + 1);
  void toggleFav()             => _emit(isFav: !state.isFav);
  void toggleDesc()            => _emit(descExpanded: !state.descExpanded);

  void decrement() {
    if (state.quantity > 1) _emit(quantity: state.quantity - 1);
  }
  CartsEntity? _lastCart;
  // ── Fetch similar products by category ───────────────────────────────────
  Future<bool> addToCart(BuildContext context) async {

    // ✅ use this.entity — no need to pass product as parameter
    if (entity.sizes.isNotEmpty && state.selectedSizeIndex < 0) {
      showSnackBar(context: context, message: 'select_size'.tr(),);

    }
    final sizeId = entity.sizes.isNotEmpty
        ? entity.sizes[state.selectedSizeIndex].id
        : entity.sizeId;


   AddToCartRequest request= AddToCartRequest(
      productId: entity.id.toString(),
      quantity:  state.quantity,
      sizeId:    sizeId,

    );


    emit(AddProductCartsLoading());
    final result = await _addCart.execute(request);
    switch (result) {
      case Success<CartsEntity>(data: final cart):
        _lastCart = cart;
        emit(AddProductsToCartsSuccess());
        return true;
      case Failure<CartsEntity>(error: final err):
        emit(AddProductsToCartsFail());
        return false;
    }
  }
  Future<void> fetchSelectedCategory(int categoryId) async {
    debugPrint("ddjd");
    emit(ProductDetailsCategoryLoading(
      selectedImageIndex: state.selectedImageIndex,
      selectedSizeIndex:  state.selectedSizeIndex,
      selectedColor:      state.selectedColor,
      quantity:           state.quantity,
      isFav:              state.isFav,
      descExpanded:       state.descExpanded,
      selectedCategory:   state.selectedCategory,
      similarCategory:    state.similarCategory,   // ✅ carry over
    ));

    final result = await _selectedCategoryUseCase.execute(categoryId);

    switch (result) {
      case Success<SimilarProductEntityEntity>():
        print("object");
        emit(ProductDetailsCategoryLoaded(
          selectedImageIndex: state.selectedImageIndex,
          selectedSizeIndex:  state.selectedSizeIndex,
          selectedColor:      state.selectedColor,
          quantity:           state.quantity,
          isFav:              state.isFav,
          descExpanded:       state.descExpanded,
          selectedCategory:   state.selectedCategory,
          similarCategory:    result.data,          // ✅ unwrapped CategoryEntity
        ));

      case Failure<SimilarProductEntityEntity>():
        print("failwuwuw" +result.error);
        emit(ProductDetailsCategoryFailed(
          error:              result.message,        // ✅ real error message
          selectedImageIndex: state.selectedImageIndex,
          selectedSizeIndex:  state.selectedSizeIndex,
          selectedColor:      state.selectedColor,
          quantity:           state.quantity,
          isFav:              state.isFav,
          descExpanded:       state.descExpanded,
          selectedCategory:   state.selectedCategory,
          similarCategory:    state.similarCategory, // ✅ carry over
        ));
    }
  }}

  // ── Add to cart ──────────────────────────────────────────────────────────

  // ── Snack helper ─────────────────────────────────────────────────────────

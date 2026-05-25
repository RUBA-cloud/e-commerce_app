import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';

abstract class ProductDetailsState {
  final int selectedImageIndex;
  final int selectedSizeIndex;
  final String selectedColor;
  final int quantity;
  final bool isFav;
  final bool descExpanded;
  final CategoriesEntity? selectedCategory;
  final SimilarProductEntityEntity? similarCategory;       // ✅ holds similar products data

  const ProductDetailsState({
    this.selectedImageIndex = 0,
    this.selectedSizeIndex  = 0,
    this.selectedColor      = '',
    this.quantity           = 1,
    this.isFav              = false,
    this.descExpanded       = false,
    this.selectedCategory,
    this.similarCategory,
  });
}

class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial({required String selectedColor})
      : super(selectedColor: selectedColor);
}

class ProductDetailsUpdated extends ProductDetailsState {
  const ProductDetailsUpdated({
    required super.selectedImageIndex,
    required super.selectedSizeIndex,
    required super.selectedColor,
    required super.quantity,
    required super.isFav,
    required super.descExpanded,
    super.selectedCategory,
    super.similarCategory,
  });
}

class ProductDetailsCategoryLoading extends ProductDetailsState {
  const ProductDetailsCategoryLoading({
    required super.selectedImageIndex,
    required super.selectedSizeIndex,
    required super.selectedColor,
    required super.quantity,
    required super.isFav,
    required super.descExpanded,
    super.selectedCategory,
    super.similarCategory,
  });
}

class ProductDetailsCategoryLoaded extends ProductDetailsState {
  const ProductDetailsCategoryLoaded({
    required super.selectedImageIndex,
    required super.selectedSizeIndex,
    required super.selectedColor,
    required super.quantity,
    required super.isFav,
    required super.descExpanded,
    super.selectedCategory,
    super.similarCategory,               // ✅ populated on success
  });
}

class ProductDetailsCategoryFailed extends ProductDetailsState {
  final String error;
  const ProductDetailsCategoryFailed({
    required this.error,
    required super.selectedImageIndex,
    required super.selectedSizeIndex,
    required super.selectedColor,
    required super.quantity,
    required super.isFav,
    required super.descExpanded,
    super.selectedCategory,
    super.similarCategory,
  });
}
class AddProductCartsLoading extends ProductDetailsState {}
class AddProductsToCartsSuccess extends ProductDetailsState {}
class AddProductsToCartsFail extends ProductDetailsState {}
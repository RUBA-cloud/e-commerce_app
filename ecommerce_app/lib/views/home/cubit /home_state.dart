import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/filter_model.dart';

enum ProductHomeState {
  addToFaviorate,
  removeFromFaviorate,
  addToCartItem,
  removeFromCart,
}

class HomeState extends Equatable {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;

  final List<ProductModel> products;

  // ✅ Pagination
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  // ✅ Make it NON-nullable
  final List<int>? additonals;

  // UI / misc
  final bool isArabic;
  final String? selectedColor;
  final int? selectedSize;

  final bool isFavorite;
  final String? message;

  final bool newCategorySelected;

  final bool isLoadingCategories;
  final bool isLoadingProducts;
  final String? errorMessage;

  final int selectedTabIndex;
  final int? cartCount;
  final int? faviorateCount;

  final ProductHomeState? productHomeState;
  final FilterModel? filterModel;

  final Set<int> favoriteProductIds;
  final bool addToFavorate;

  final ProductModel? selectedProduct;

  const HomeState({
    this.categories = const [],
    this.selectedCategory,
    this.products = const [],
    this.selectedProduct,
this.additonals,
    // ✅ default empty set

    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,

    this.isArabic = false,
    this.selectedColor,
    this.selectedSize,
    this.isFavorite = false,
    this.message,
    this.newCategorySelected = false,
    this.isLoadingCategories = false,
    this.isLoadingProducts = false,
    this.errorMessage,
    this.selectedTabIndex = 0,
    this.cartCount,
    this.faviorateCount,
    this.productHomeState,
    this.filterModel,
    this.favoriteProductIds = const <int>{},
    this.addToFavorate = false,
    
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
    List<ProductModel>? products,
    ProductModel? product, // ✅ fixed

    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,

    bool? isArabic,
    String? selectedColor,
    int? selectedSize,

    List<int>? additonals, // ✅ non-nullable now
    bool? isFavorite,
    String? message,
    bool? newCategorySelected,
    bool? isLoadingCategories,
    bool? isLoadingProducts,
    String? errorMessage,
    int? selectedTabIndex,
    Set<int>? favoriteProductIds,
    bool? addToFavorate,
    FilterModel? filterModel,
    ProductHomeState? productHomeState,
    int? cartCount,
    int? faviorateCount,  
    ProductModel?selectedProduct
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,

      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,

      isArabic: isArabic ?? this.isArabic,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
additonals: additonals??this.additonals,

      isFavorite: isFavorite ?? this.isFavorite,
      message: message ?? this.message,
      newCategorySelected: newCategorySelected ?? this.newCategorySelected,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      addToFavorate: addToFavorate ?? this.addToFavorate,
      filterModel: filterModel ?? this.filterModel,
      productHomeState: productHomeState ?? this.productHomeState,
      cartCount: cartCount ?? this.cartCount,
      faviorateCount: faviorateCount ?? this.faviorateCount,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        selectedCategory,
        products,
        selectedProduct, // ✅ add product to props

        currentPage,
        hasMore,
        isLoadingMore,

        isArabic,
        selectedColor,
        selectedSize,

        additonals, // ✅ IMPORTANT: add to props

        isFavorite,
        message,
        newCategorySelected,
        isLoadingCategories,
        isLoadingProducts,
        errorMessage,
        selectedTabIndex,
        cartCount,
        faviorateCount,
        productHomeState,
        filterModel,
        favoriteProductIds,
        addToFavorate,
      ];
}

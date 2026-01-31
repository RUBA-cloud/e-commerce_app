import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/filter_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/repostery%20/faviorate_repostery.dart';
import 'package:ecommerce_app/repostery%20/filter_repoistery.dart';
import 'package:ecommerce_app/repostery%20/home_repoistery.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiHomeRepository _homeRepo;
  final ApiFiltersRepository _filtersRepo;
  final ApiFaviorateRepository _favoriteRepo;
  final ScrollController allProductsScrollController = ScrollController();

  bool _allProductsListenerAttached = false;
  HomeCubit({
    ApiHomeRepository? homeRepository,
    ApiFiltersRepository? filtersRepository,
    ApiFaviorateRepository? favoriteRepository,
  })  : _homeRepo = homeRepository ?? ApiHomeRepository(),
        _filtersRepo = filtersRepository ?? ApiFiltersRepository(),
        _favoriteRepo = favoriteRepository ?? ApiFaviorateRepository(),
        super(HomeState.initial());

  // --------------------------
  // BOTTOM NAV
  // --------------------------
  void setTab(int index) => emit(state.copyWith(selectedTabIndex: index,));

  // --------------------------
  // SEARCH
  // --------------------------
    void ensureAllProductsScrollAttached(BuildContext context) {
    if (_allProductsListenerAttached) return;
    _allProductsListenerAttached = true;

    allProductsScrollController.addListener(() {
      _onAllProductsScroll();
    });
  }

  void _onAllProductsScroll() {
    if (!allProductsScrollController.hasClients) return;

    final isLoadingMore = state.isLoadingMore == true;
    final hasMore = state.hasMore != false;

    if (isLoadingMore || !hasMore) return;

    const threshold = 250.0;
    final max = allProductsScrollController.position.maxScrollExtent;
    final offset = allProductsScrollController.offset;

    if (offset >= (max - threshold)) {
      loadMoreProducts();
    }
  }
  Future<void> search(String? s) async {
    final query = s?.trim() ?? '';

    if (query.isEmpty) {
      await loadCategories();
      return;
    }

    try {
      final result = await _homeRepo.search(query);

      if (result.isNotEmpty && result.first != null) {
        await changeCategory(result.first!);
      } else {
        emit(
          state.copyWith(
            categories: const [],
            selectedCategory: null,
            products: const [],
            currentPage: 1,
            hasMore: false,
            isLoadingMore: false,
            isLoadingProducts: false,
            isLoadingCategories: false,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
  
  // --------------------------
  // FILTER
  // --------------------------
  FilterModel? getFilterModel() => state.filterModel;

  Future<void> applyFilter(FilterModel model) async {
    try {
      final data = await _filtersRepo.sendFilter(
        model.categoryId,
        model.selectedSizeId,
        model.selectedTypeId,
        model.selectedColor,
        model.minPrice,
        model.maxPrice,
      );

      if (data != null) {
        emit(state.copyWith(filterModel: model));
        await changeCategory(data);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // --------------------------
  // FAVORITES
  // --------------------------
  bool checkProductIdInFav(int productId) =>
      state.favoriteProductIds.contains(productId);

  Future<void> toggleFavorite(ProductModel product, BuildContext context) async {
    final current = Set<int>.from(state.favoriteProductIds);

    if (current.contains(product.id)) {
      final result = await _favoriteRepo.removeFaviorate(
        product.id,
        context,
        true,
        product.id,
      );

      if (result) {
        current.remove(product.id);

        emit(
          state.copyWith(
            isFavorite: false,
            favoriteProductIds: current,
            addToFavorate: false,
          ),
        );

        try {
          // ignore: use_build_context_synchronously
          context.read<FavoriteCubit>().load();
        } catch (_) {}
      }
    } else {
      final fav = await _favoriteRepo.addToFaviorate(product.id, context);

      if (fav != null) {
        current.add(product.id);

        emit(
          state.copyWith(
            isFavorite: true,
            favoriteProductIds: current,
            addToFavorate: true,
          ),
        );

        try {
          // ignore: use_build_context_synchronously
          context.read<FavoriteCubit>().load();
        } catch (_) {}
      }
    }
  }

  Future<void> refreshFavoriteBadge() async {
    try {
      final favList = await _favoriteRepo.fetchAll();
      emit(
        state.copyWith(
          addToFavorate: true,
          favoriteProductIds: favList.map((e) => e.product.id).toSet(),
        ),
      );
    } catch (_) {}
  }

  // --------------------------
  // CATEGORIES / PRODUCTS
  // --------------------------
  Future<void> loadCategories() async {
    emit(
      state.copyWith(
        selectedTabIndex: 0,
        isLoadingCategories: true,
        isLoadingProducts: false,
        isLoadingMore: false,
        currentPage: 1,
        hasMore: true,
        errorMessage: null,
        addToFavorate: false,
      ),
    );

    try {
      final categories = await _homeRepo.fetchAll();

      if (categories.isEmpty) {
        emit(
          state.copyWith(
            isLoadingCategories: false,
            isLoadingProducts: false,
            isLoadingMore: false,
            categories: const [],
            products: const [],
            selectedCategory: null,
            currentPage: 1,
            hasMore: false,
            errorMessage: null,
            
          ),
        );
        return;
      }

      final firstCategory = categories.first;

      emit(
        state.copyWith(
          isLoadingCategories: false,
          isLoadingProducts: true,
          categories: categories,
          selectedCategory: firstCategory,
          products: firstCategory.products,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );

      await _loadFirstPageForCategory(firstCategory.id);
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingCategories: false,
          isLoadingProducts: false,
          isLoadingMore: false,
          currentPage: 1,
          hasMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> changeCategory(CategoryModel newCategory) async {
    if (newCategory.id == state.selectedCategory?.id) return;

    emit(
      state.copyWith(
        selectedCategory: newCategory,
        isLoadingProducts: true,
        isLoadingMore: false,
        currentPage: 1,
        hasMore: true,
        products: newCategory.products,
        errorMessage: null,
      ),
    );

  }

  Future<void> _loadFirstPageForCategory(int categoryId) async {
    try {
      final pageProducts = await _homeRepo.loadSpecificCategoryProduct(
       categoryId:  categoryId,
        page: 5,
      );

      emit(
        state.copyWith(
          isLoadingProducts: false,
          products: pageProducts?.products,
          currentPage: 1,
          hasMore: pageProducts!=null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingProducts: false,
          isLoadingMore: false,
          hasMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreProducts() async {
    final selected = state.selectedCategory;
    if (selected == null) return;

    if (state.isLoadingMore) return;
    if (!state.hasMore) return;
    if (state.isLoadingProducts || state.isLoadingCategories) return;

    final nextPage = state.currentPage + 1;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    try {
      final more = await _homeRepo.loadSpecificCategoryProduct(
        categoryId:  selected.id,
        page: nextPage,
      );

      if (more!.products.isNotEmpty) {
        emit(state.copyWith(isLoadingMore: false, hasMore: false));
        return;
      }

      final existingIds = state.products.map((e) => e.id).toSet();
      final merged = [
        ...state.products,
        ...more.products.where((p) => !existingIds.contains(p.id)),
      ];

      emit(
        state.copyWith(
          isLoadingMore: false,
          currentPage: nextPage,
          hasMore: true,
          products: merged,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.toString()));
    }
  }

  // --------------------------
  // DETAILS
  // --------------------------
  Future<void> goToDetailsPage(ProductModel product, BuildContext context) async {
    await Get.toNamed(AppRoutes.details, arguments: product);
  }

  void onCartItemsChanged(int newLength) {
    emit(
      state.copyWith(
        productHomeState: ProductHomeState.addToCartItem,
        cartCount: newLength,
      ),
    );
  }

  void removeItemfromProductIds(int productId) {
    final updated = Set<int>.from(state.favoriteProductIds);
    updated.remove(productId);

    emit(
      state.copyWith(
        favoriteProductIds: updated,
        productHomeState: ProductHomeState.removeFromCart,
      ),
    );
  }
}

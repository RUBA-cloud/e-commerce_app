// lib/services/home/home_state.dart
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/filter_option_entity.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

/// Emitted while the filter API call is in-flight so the UI can show
/// a lightweight indicator without wiping out the existing product list.
class HomeFilterLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final CategoriesEntity      categoriesEntity;
  final BrandEntity?          brandEntity;
  final FilterOptionEntity?  filterOptionsEntity;   // API-sourced filter options
  final int                   selectedCategoryIndex;
  final int                   selectedTab;
  final FilterOptions         activeFilter;

  HomeLoaded({
    required this.categoriesEntity,
    required this.brandEntity,
    this.filterOptionsEntity,
    this.selectedCategoryIndex = 0,
    required this.selectedTab,
    required this.activeFilter,
  });
}

class HomeFailed extends HomeState {
  final String? message;
  HomeFailed(this.message);
}
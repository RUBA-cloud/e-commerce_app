
import 'package:ecommerce_app/data/model/response/brand_entity.dart';

import '../../data/model/response/carts/categories_entity.dart' show CategoriesEntity;

abstract class HomeState {
}
class HomeInitial extends HomeState{}
class HomeLoading extends HomeState{}
class HomeLoaded extends HomeState {
  final CategoriesEntity categoriesEntity;
  final BrandEntity? brandEntity;
  final int selectedCategoryIndex;
  final int                   selectedTab;          //

  HomeLoaded({
    required this.categoriesEntity,
    required this.brandEntity,
    this.selectedCategoryIndex = 0,
    required this.selectedTab,
  });
}

class HomeFailed extends HomeState{
  final String?message;
  HomeFailed(this.message);
}


import 'package:ecommerce_app/data/model/response/categories_entity.dart';

abstract class HomeState {
}
class HomeInitial extends HomeState{}
class HomeLoading extends HomeState{}
class HomeLoaded extends HomeState{
final  CategoriesEntity categoriesEntity;
  HomeLoaded({required this.categoriesEntity});
}
class HomeFailed extends HomeState{
  final String?message;
  HomeFailed(this.message);
}
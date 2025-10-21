// lib/views/product_details/cubit/product_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_details_state.dart';
import 'package:ecommerce_app/models/product_model.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final String productId;
  ProductDetailsCubit({required this.productId})
      : super(ProductDetailsState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ProductDetailsStatus.loading, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 350));
      final p = ProductModel.demo(productId);
      emit(state.copyWith(
        status: ProductDetailsStatus.loaded,
        product: p,
        selectedImage: 0,
        selectedColor: p.colors.isNotEmpty ? p.colors.first : null,
        selectedSize: p.sizes.isNotEmpty ? p.sizes.first : null,
        isFavorite: p.isFavorite,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ProductDetailsStatus.error, error: e.toString()));
    }
  }

  void selectImage(int i) => emit(state.copyWith(selectedImage: i));

  void selectColor(int color) => emit(state.copyWith(selectedColor: color));

  void selectSize(String size) => emit(state.copyWith(selectedSize: size));

  void toggleFavorite() => emit(state.copyWith(isFavorite: !state.isFavorite));

  void setQty(int q) => emit(state.copyWith(qty: q.clamp(1, 9999)));

  void incQty() => setQty(state.qty + 1);

  void decQty() => setQty(state.qty - 1);

  void toggleDesc() => emit(state.copyWith(expandedDesc: !state.expandedDesc));

  Future<void> addToCart() async {
    if (state.product == null) return;
    emit(state.copyWith(status: ProductDetailsStatus.addingToCart));
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(status: ProductDetailsStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
          status: ProductDetailsStatus.error, error: e.toString()));
    }
  }
}

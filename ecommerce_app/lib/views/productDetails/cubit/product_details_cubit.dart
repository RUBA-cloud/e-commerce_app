import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/repostery%20/cart_items_repostery.dart';

import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_cubit.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProductDetailsCubit extends HomeCubit {
  final InMemoryCartItemsRepository _cartRepo;

  ProductDetailsCubit({
    required ProductModel product,
    required bool isArabic,
    super.homeRepository,
    super.filtersRepository,
    super.favoriteRepository,
    InMemoryCartItemsRepository? cartRepository,
  })  : _cartRepo = cartRepository ?? InMemoryCartItemsRepository() {
    // اضبط حالة الصفحة بالـ product واللغة
    emit(
      state.copyWith(
        selectedProduct: product,
        isArabic: isArabic,
        selectedColor: null,
        selectedSize: null,
        isFavorite: state.favoriteProductIds.contains(product.id),
        message: null,
      ),
    );
  }

  /* ================== COLOR / SIZE ================== */

  void selectColor(String color) {
    emit(
      state.copyWith(
        selectedColor: color,
        message: null,
      ),
    );
  }

  void selectSize(int size) {
    emit(
      state.copyWith(
        selectedSize: size,
        message: null,
      ),
    );
  }
  void selectAdditonal(int id) {
  // ✅ نسخة جديدة + تنظيف null
  final List<int> current = List<int>.from(state.additonals ?? [])
    // ignore: unnecessary_null_comparison
    ..removeWhere((e) => e == null);

  // ✅ toggle
  final exists = current.contains(id);
  if (exists) {
    current.remove(id);
  } else {
    current.add(id);
  }

  emit(
    state.copyWith(
      additonals: current, // List<int?> 
      message: null,
    ),
  );

}

  
 

  /* ================== ADD TO CART ================== */

  Future<void> addToCart(BuildContext context) async {
    final currentProduct = state.selectedProduct;
    if (currentProduct == null) return;

    // تأكد من اختيار اللون
    if (currentProduct.colors.isNotEmpty && state.selectedColor == null) {
      emit(state.copyWith(message: 'select_color_first'.tr));
      return;
    }

    // تأكد من اختيار المقاس
    if (currentProduct.sizes.isNotEmpty && state.selectedSize == null) {
      emit(state.copyWith(message: 'select_size_first'.tr));
      return;
    }

    final result = await _cartRepo.addToCart(
      currentProduct.id,
      state.selectedSize!,
      state.selectedColor!,
      state.additonals,
    );

    if (result != null) {
      try {
        // حدّث كارت الكيوبت
        // ignore: use_build_context_synchronously
        final cartCubit = context.read<CartCubit>();
        await cartCubit.load();

        final length = cartCubit.state.items.length;

        // استعملنا ميثود من HomeCubit

        // ارجعي للصفحة السابقة مع عدد العناصر
        Get.back(result: length);
      } catch (_) {
        // ممكن تتجاهلي الخطأ أو تعملي لوج
      }
    }
  }
}


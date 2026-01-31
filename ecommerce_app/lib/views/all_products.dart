// lib/views/home/home_tab.dart
import 'package:ecommerce_app/components/product_grid.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart' show HomeCubit;
import 'package:ecommerce_app/views/home/cubit%20/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/export.dart';

class AllProducts extends StatelessWidget {
  const AllProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("all_product".tr)),
      body: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listenWhen: (prev, curr) =>
              prev.selectedCategory?.id != curr.selectedCategory?.id ||
              prev.favoriteProductIds != curr.favoriteProductIds ||
              prev.categories != curr.categories,
          listener: (context, state) {},
          builder: (context, state) {
            if (state.isLoadingCategories && state.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            }

            final cubit = context.read<HomeCubit>();

            // ✅ جهّز/اربط الكونترولر مرة واحدة (داخل cubit)
            cubit.ensureAllProductsScrollAttached(context);

            return RefreshIndicator(
              onRefresh: () async {
                await cubit.loadCategories();
                // لو عندك دالة ترجع المنتجات من البداية:
                // await cubit.reloadProducts();
              },
              child: SingleChildScrollView(
                controller: cubit.allProductsScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ProductGrid(
                      products: state.products,
                      favoriteIds: state.favoriteProductIds,
                    ),

                    if (state.isLoadingMore == true)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    if (state.hasMore == false)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'no_more_products'.tr,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

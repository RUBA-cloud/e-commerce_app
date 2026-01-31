// lib/views/home/home_tab.dart

import 'package:ecommerce_app/components/basic_search.dart';
import 'package:ecommerce_app/components/category_list.dart';
import 'package:ecommerce_app/components/list_products.dart';
import 'package:ecommerce_app/components/section_tile_action.dart';
import 'package:ecommerce_app/views/all_products.dart';
import 'package:ecommerce_app/pages/offers/offers_header.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_state.dart';
import 'package:ecommerce_app/views/home/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listenWhen: (prev, curr) =>
              prev.selectedCategory?.id != curr.selectedCategory?.id ||
              prev.favoriteProductIds != curr.favoriteProductIds ||
              prev.categories != curr.categories ||
              prev.products != curr.products ||
              prev.isLoadingCategories != curr.isLoadingCategories,
          listener: (context, state) {},
          builder: (context, state) {
            if (state.isLoadingCategories && state.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            }

            final read = context.read<HomeCubit>();

            return RefreshIndicator(
              onRefresh: () => read.loadCategories(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 16),

                    BasicSearchBar(
                      isArabic: isArabic,
                      onChanged: (s) => read.search(s),
                    ),
                    const SizedBox(height: 16),

                    OffersHeader(isArabic: isArabic),
                    const SizedBox(height: 24),

                    Text(
                      'categories'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    CategoryList(
                      categories: state.categories,
                      selectedId: state.selectedCategory?.id,
                      onTap: (category) => read.changeCategory(category),
                    ),

                    const SizedBox(height: 16),

                    SectionTitleWithAction(
                      title: 'featured'.tr,
                      actionLabel: 'see_all'.tr,
                      onTap: () => Get.to(() => const AllProducts()),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: ListProducts(
                        products: state.products.toList(),
                        favoriteIds: state.favoriteProductIds,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SectionTitleWithAction(
                      title: 'best_seller'.tr,
                      actionLabel: 'more'.tr,
                      onTap: () => Get.to(() => const AllProducts()),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: ListProducts(
                      
                        products: state.products.take(4).toList(),
                        favoriteIds: state.favoriteProductIds,
                      ),
                    ),

                    const SizedBox(height: 24),
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

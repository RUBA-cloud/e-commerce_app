// lib/components/product_grid.dart
import 'package:ecommerce_app/components/product_widget_design.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;

  const ProductGrid({
    super.key,
    required this.products,
    required Set<int> favoriteIds, // (مش مستخدم عندك، خليته زي ما هو)
  });

  // ✅ helper: trigger when close to bottom
  bool _shouldLoadMore(ScrollMetrics m) {
    const threshold = 220.0; // px قبل النهاية
    return m.pixels >= (m.maxScrollExtent - threshold);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Text(
            'no_products'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.favoriteProductIds != c.favoriteProductIds ,
      builder: (context, state) {
        // ✅ مهم: خفف تكرار النداء
        // الأفضل يكون عندك في HomeState:
        // bool isLoadingMore, bool hasMore
        final canLoadMore =
            (state.hasMore ) && !(state.isLoadingMore );

        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            // نستخدم ScrollUpdateNotification عشان ما ننادي كثير
            if (n is ScrollUpdateNotification) {
              if (canLoadMore && _shouldLoadMore(n.metrics)) {
                context.read<HomeCubit>().loadMoreProducts();
              }
            }
            return false;
          },
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              final p = products[index];
              return ProductWidgetDesign(p: p);
            },
          ),
        );
      },
    );
  }
}

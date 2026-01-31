// lib/components/list_products.dart

import 'package:ecommerce_app/components/product_widget_design.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart' show HomeCubit;
import 'package:ecommerce_app/views/home/cubit%20/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ListProducts extends StatelessWidget {
  final List<ProductModel> products;
  final Set<int> favoriteIds;

  const ListProducts({
    super.key,
    required this.products,
    required this.favoriteIds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (products.isEmpty) {
      return Center(
        child: Text(
          'no_products'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            // ignore: deprecated_member_use
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.favoriteProductIds != c.favoriteProductIds,
      builder: (context, state) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          physics: const BouncingScrollPhysics(), // ✅ يسمح بالسكرول الأفقي
          itemBuilder: (context, index) {
            final p = products[index];

            // إذا ProductWidgetDesign يحتاج isFav مرّريها

            return SizedBox(
              width: 160, // ✅ مهم عشان العناصر تبين بشكل أفقي
              child: ProductWidgetDesign(
                p: p,
                 // لو عندك باراميتر
              ),
            );
          },
        );
      },
    );
  }
}

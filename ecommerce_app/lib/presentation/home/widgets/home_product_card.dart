// lib/presentation/home/widgets/home_product_card.dart

import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/presentation/home/widgets/app_network_image.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:ecommerce_app/presentation/product_details.dart';
import 'package:ecommerce_app/services/product_details/product_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════════════════
// ProductsGrid
// ═══════════════════════════════════════════════════════

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key, required this.products, required this.c});

  final List<CategoriesDataDataProductsEntity> products;
  final AppColors                              c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          mainAxisSpacing:  12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.58,
        ),
        itemCount:   products.length,
        itemBuilder: (_, i) =>
            HomeProductCard(product: products[i], colors: c),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HomeProductCard
// ═══════════════════════════════════════════════════════

class HomeProductCard extends StatefulWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    required this.colors,
    this.heroTag,
  });

  final CategoriesDataDataProductsEntity product;
  final AppColors                        colors;
  final String?                          heroTag;

  @override
  State<HomeProductCard> createState() => _HomeProductCardState();
}

class _HomeProductCardState extends State<HomeProductCard> with UiUtility {
  bool _fav = false;

  // ── Per-category accent colour ─────────────────────────────────────────────
  // Falls back to the brand's main colour when category name is unrecognised.
  Color _accentFor(String categoryEn, AppColors c) {
    final key = categoryEn.toLowerCase();
    if (key.contains('electronic') || key.contains('tech')) {
      return const Color(0xFF0F6E56); // teal-600
    } else if (key.contains('footwear') || key.contains('shoe')) {
      return const Color(0xFF993C1D); // coral-600
    } else if (key.contains('bag') || key.contains('accessory')) {
      return const Color(0xFF854F0B); // amber-600
    } else if (key.contains('sport') || key.contains('fitness')) {
      return const Color(0xFF185FA5); // blue-600
    } else if (key.contains('home') || key.contains('kitchen')) {
      return const Color(0xFF3B6D11); // green-600
    }
    return c.main; // default brand colour
  }

  Color _accentBgFor(String categoryEn, AppColors c) {
    final key = categoryEn.toLowerCase();
    if (key.contains('electronic') || key.contains('tech')) {
      return const Color(0xFFE1F5EE);
    } else if (key.contains('footwear') || key.contains('shoe')) {
      return const Color(0xFFFAECE7);
    } else if (key.contains('bag') || key.contains('accessory')) {
      return const Color(0xFFFAEEDA);
    } else if (key.contains('sport') || key.contains('fitness')) {
      return const Color(0xFFE6F1FB);
    } else if (key.contains('home') || key.contains('kitchen')) {
      return const Color(0xFFEAF3DE);
    }
    return c.main.withOpacity(0.08);
  }

  @override
  Widget build(BuildContext context) {
    final c    = widget.colors;
    final p    = widget.product;

    final categoryName = localizedEnAr(
      context: context,
      nameEn:  p.category.nameEn,
      nameAr:  p.category.nameAr,
    );
    final productName = localizedEnAr(
      context: context,
      nameEn: p.nameEn,
      nameAr: p.nameAr,
    );

    final accent   = _accentFor(p.category.nameEn, c);
    final accentBg = _accentBgFor(p.category.nameEn, c);

    return GestureDetector(
      onTap: () =>navigateTo(context: context, page: BlocProvider(create:(c)=> ProductDetailsCubit(widget.product),child: ProductDetailsScreen(product: widget.product),)),
         
        
      
      child: Container(
        decoration: BoxDecoration(
          color:        c.card,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color:      accent.withOpacity(0.10),
              blurRadius: 18,
              offset:     const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image ────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(22.r),
                topRight: Radius.circular(22.r),
              ),
              child: SizedBox(
                height: 128.h,
                width:  double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      url:         p.mainImage,
                      fit:         BoxFit.cover,
                      placeholder: HomeProductPlaceholder(
                        colors:    c,
                        accentBg:  accentBg,
                        accent:    accent,
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      left: 0, right: 0, bottom: 0,
                      height: 56.h,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin:  Alignment.topCenter,
                            end:    Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.30),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // NEW badge
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color:        accent.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize:   8.sp,
                            fontWeight: FontWeight.w800,
                            color:      Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    // Favourite button
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _fav = !_fav),
                        child: Container(
                          width: 30.r, height: 30.r,
                          decoration: BoxDecoration(
                            color: c.card.withOpacity(0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _fav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border,
                            size:  16.r,
                            color: _fav ? Colors.red.shade400 : c.hint,
                          ),
                        ),
                      ),
                    ),
                    // Add-to-cart button
                    Positioned(
                      right: 10, bottom: 10,
                      child: Container(
                        width: 34.r, height: 34.r,
                        decoration: BoxDecoration(
                          color:        accent,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color:      accent.withOpacity(0.4),
                              blurRadius: 8,
                              offset:     const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          size:  18.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(10.r, 10.r, 10.r, 12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category label
                  Row(
                    children: [
                      Container(
                        width:  4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: accent, shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        categoryName.toUpperCase(),
                        style: TextStyle(
                          fontSize:      8.sp,
                          fontWeight:    FontWeight.w700,
                          color:         accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  // Product name
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize:   12.sp,
                      fontWeight: FontWeight.w700,
                      color:      c.bodyText,
                      height:     1.25,
                    ),
                    maxLines:  2,
                    overflow:  TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Price + rating
                  Row(
                    children: [
                      Text(
                        '\$${p.price}',
                        style: TextStyle(
                          fontSize:   15.sp,
                          fontWeight: FontWeight.w800,
                          color:      accent,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star_rounded,
                        size:  14.r,
                        color: Colors.amber[700],
                      ),
                      Text(
                        ' 4.8',
                        style:
                        TextStyle(fontSize: 10.sp, color: c.hint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HomeProductPlaceholder
// ═══════════════════════════════════════════════════════

class HomeProductPlaceholder extends StatelessWidget {
  const HomeProductPlaceholder({
    super.key,
    required this.colors,
    Color? accentBg,
    Color? accent,
  })  : accentBg = accentBg ?? const Color(0xFFEEEDFE),
        accent   = accent   ?? const Color(0xFF534AB7);

  final AppColors colors;
  final Color     accentBg;
  final Color     accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accentBg,
      child: Icon(
        Icons.image_outlined,
        size:  40.r,
        color: accent.withOpacity(0.45),
      ),
    );
  }
}
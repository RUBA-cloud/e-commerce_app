import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/similar_product_entity_entity.dart';
import 'package:ecommerce_app/presentation/home/widgets/app_network_image.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SimilarProductsSection extends StatelessWidget with UiUtility {
  const SimilarProductsSection({
    super.key,
    required this.currentProduct,
    required this.similarProducts,
    required this.onProductTap,
  });

  final CategoriesDataDataProductsEntity currentProduct;
  final SimilarProductEntityEntity similarProducts;

  // ✅ Fix: callback receives the correct type
  final void Function(SimilarProductEntityProductsDataEntity product) onProductTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;

    final items = similarProducts.products?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c),
        SizedBox(height: 12.h),
        SizedBox(
          height: 230.h,
          child: ListView.separated(
            scrollDirection:  Axis.horizontal,
            padding:          EdgeInsets.symmetric(horizontal: 20.w),
            itemCount:        items.length,
            separatorBuilder: (_, __) => SizedBox(width: 14.w),
            itemBuilder: (ctx, i) => _ProductCard(
              product: items[i],
              c:       c,
              // ✅ Fix: pass the data entity directly, no wrong cast
              onTap:   () => onProductTap(items[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(AppColors c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 18.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:  Alignment.topCenter,
                end:    Alignment.bottomCenter,
                colors: [c.main, c.sub],
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'similar_products'.tr(),
            style: TextStyle(
              fontSize:   15.sp,
              fontWeight: FontWeight.w800,
              color:      c.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// PRODUCT CARD
// ══════════════════════════════════════════════════════════════════════════

class _ProductCard extends StatelessWidget with UiUtility {
  const _ProductCard({
    required this.product,
    required this.c,
    required this.onTap,
  });

  final SimilarProductEntityProductsDataEntity product; // ✅ non-nullable
  final AppColors c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = localizedEnAr(
      context: context,
      nameEn:  product.nameEn ?? '',
      nameAr:  product.nameAr ?? '',
    );

    // ✅ Fix: safe access to images list and imagePath
    final images = product.images ?? [];
    final image=(product.mainImage ?? '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color:        c.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: c.hint.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color:      c.main.withOpacity(0.06),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: Container(
                height: 130.h,
                width:  double.infinity,
                color:  c.main.withOpacity(0.06),
                child: image.isEmpty
                    ? Center(
                  child: Icon(Icons.shopping_bag_outlined,
                      size: 40.r, color: c.main.withOpacity(0.30)),
                )
                    : AppNetworkImage(url: image, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color:        c.main.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      localizedEnAr(
                        context: context,
                        nameEn:  product.category?.nameEn ?? '',
                        nameAr:  product.category?.nameAr ?? '',
                      ),
                      style: TextStyle(
                        fontSize:   8.sp,
                        fontWeight: FontWeight.w600,
                        color:      c.main,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:   12.sp,
                      fontWeight: FontWeight.w700,
                      color:      c.bodyText,
                      height:     1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // ✅ Fix: was missing ! — now safely null-checked
                        '\$${product.price ?? '0'}',
                        style: TextStyle(
                          fontSize:   13.sp,
                          fontWeight: FontWeight.w900,
                          color:      c.main,
                        ),
                      ),
                      Container(
                        width: 28.r, height: 28.r,
                        decoration: BoxDecoration(
                          gradient:     LinearGradient(colors: [c.main, c.sub]),
                          borderRadius: BorderRadius.circular(9.r),
                          boxShadow: [
                            BoxShadow(
                              color:      c.main.withOpacity(0.28),
                              blurRadius: 6,
                              offset:     const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(Icons.add_rounded, color: c.buttonText, size: 16.r),
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
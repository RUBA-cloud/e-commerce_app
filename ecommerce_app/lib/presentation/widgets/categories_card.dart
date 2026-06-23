// lib/presentation/widgets/categories_card.dart

import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../home/widgets/home_shared.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.cubit});

  final HomeCubit cubit;
  // ✅ removed `required AppColors c` — colors come from theme now

  @override
  Widget build(BuildContext context) {
    final c    = Theme.of(context).colorScheme;// ✅ live company colors
    final cats = cubit.categoriesEntity?.data.data;

    if (cats == null || cats.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding:          EdgeInsets.symmetric(horizontal: 16.w),
        itemCount:        cats.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final cat      = cats[i];
          final selected = cubit.selectedCategoryIndex == i;
          final name     = localizedEnAr(
            context: context,
            nameEn:  cat.nameEn,
            nameAr:  cat.nameAr,
          );

          return GestureDetector(
            onTap: () => cubit.selectCategory(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width:    76.w,
              child: Column(
                children: [
                  // ── Icon container ──────────────────────────────────
                  Container(
                    width:  64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                        colors: [c.primary, c.secondary],
                        begin:  Alignment.topLeft,
                        end:    Alignment.bottomRight,
                      )
                          : null,
                      color:        selected ? null : c.primary,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color:      (selected ? c.surface : c.primary)
                              .withOpacity(0.15),
                          blurRadius: 10,
                          offset:     const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(selected ? 3.r : 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:        c.surface,
                        borderRadius: BorderRadius.circular(17.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: cat.image != null
                          ? Image.network(
                        cat.image!,
                        fit:        BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.category_rounded,
                          size:  28.r,
                          color: selected ? c.primary:c.secondary,
                        ),
                      )
                          : Icon(
                        Icons.category_rounded,
                        size:  28.r,
                        color: selected ? c.primary:c.secondary,
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // ── Label ────────────────────────────────────────────
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:   10.sp,
                      color:      selected ? c.primary:c.secondary,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
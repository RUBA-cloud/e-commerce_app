
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/app_theme.dart';
import '../home/widgets/home_shared.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({required this.cubit, required this.c});

  final HomeCubit cubit;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final cats = cubit.categoriesEntity?.data.data;
    if (cats == null || cats.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: cats.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final cat      = cats[i];
          final selected = cubit.selectedCategoryIndex == i;
          final name     = localizedEnAr(
            context: context,
            nameEn: cat.nameEn,
            nameAr: cat.nameAr,
          );
          return GestureDetector(
            onTap: () => cubit.selectCategory(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 76.w,
              child: Column(
                children: [
                  Container(
                    width:  64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                        colors: [c.main, c.sub],
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                      )
                          : null,
                      color:        selected ? null : c.card,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color:      (selected ? c.main : c.hint).withOpacity(0.15),
                          blurRadius: 10,
                          offset:     const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(selected ? 3.r : 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:        c.card,
                        borderRadius: BorderRadius.circular(17.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: cat.image != null
                          ? Text("data")

                          : Icon(
                        Icons.category_rounded,
                        size:  28.r,
                        color: selected ? c.main : c.hint,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:   10.sp,
                      color:      selected ? c.main : c.hint,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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

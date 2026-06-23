import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/data/model/response/category_entity.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_product_card.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeeAllProductsScreen extends StatefulWidget {
  const SeeAllProductsScreen({
    super.key,
    required this.categories,
    this.initialCategoryIndex = 0,
  });

  final List<CategoryDataDataEntity> categories;
  final int initialCategoryIndex;

  @override
  State<SeeAllProductsScreen> createState() => _SeeAllProductsScreenState();
}

class _SeeAllProductsScreenState extends State<SeeAllProductsScreen> {
  late int _categoryIndex;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _categoryIndex = widget.categories.isEmpty
        ? 0
        : widget.initialCategoryIndex.clamp(
            0,
            widget.categories.length - 1,
          );
  }

  List<dynamic> get _products {
    if (widget.categories.isEmpty || _categoryIndex >= widget.categories.length) {
      return [];
    }
    final list = widget.categories[_categoryIndex].products;
    if (_query.isEmpty) return list!;
    final q = _query.toLowerCase();
    return list!.where((p) {
      return p.nameEn.toLowerCase().contains(q) ||
          p.nameAr.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final products = _products;

    return SeeAllScaffold(
      title: 'products'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'search_products'.tr(),
                prefixIcon: Icon(Icons.search, size: 20.r, color: c.hint),
                filled: true,
                fillColor: c.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 12.w),
              ),
            ),
          ),
          SizedBox(
            height: 40.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final cat = widget.categories[i];
                final selected = _categoryIndex == i;
                final name = localizedEnAr(
                  context: context,
                  nameEn: cat.nameEn,
                  nameAr: cat.nameAr,
                );
                return GestureDetector(
                  onTap: () => setState(() {
                    _categoryIndex = i;
                    _query = '';
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: selected ? c.main : c.card,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected ? c.main : c.hint.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: selected ? c.buttonText : c.bodyText,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(
                      'no_products'.tr(),
                      style: TextStyle(color: c.hint, fontSize: 14.sp),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16.r),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => HomeProductCard(
                      product: products[i],
                      colors: c,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

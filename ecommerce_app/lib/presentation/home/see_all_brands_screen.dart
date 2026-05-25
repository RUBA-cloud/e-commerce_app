import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeeAllBrandsScreen extends StatefulWidget {
  const SeeAllBrandsScreen({super.key, required this.brands});

  final List<BrandDataDataEntity> brands;

  @override
  State<SeeAllBrandsScreen> createState() => _SeeAllBrandsScreenState();
}

class _SeeAllBrandsScreenState extends State<SeeAllBrandsScreen> {
  String _query = '';

  List<BrandDataDataEntity> get _filtered {
    if (_query.isEmpty) return widget.brands;
    final q = _query.toLowerCase();
    return widget.brands.where((b) {
      return b.nameEn.toLowerCase().contains(q) ||
          b.nameAr.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final brands = _filtered;

    return SeeAllScaffold(
      title: 'top_brands'.tr(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'search_brands'.tr(),
                prefixIcon: Icon(Icons.search, size: 20.r, color: c.hint),
                filled: true,
                fillColor: c.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.w),
              ),
            ),
          ),
          Expanded(
            child: brands.isEmpty
                ? Center(
                    child: Text(
                      'no_items'.tr(),
                      style: TextStyle(color: c.hint, fontSize: 14.sp),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16.r),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: brands.length,
                    itemBuilder: (_, i) {
                      final brand = brands[i];
                      final name = localizedEnAr(
                        context: context,
                        nameEn: brand.nameEn,
                        nameAr: brand.nameAr,
                      );
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: c.card,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: c.main.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.all(10.r),
                                      decoration: BoxDecoration(
                                        color: c.textField,
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.r),
                                        child: brandNetworkImage(brand, c),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: c.bodyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (brand.products.isNotEmpty)
                            Text(
                              '${brand.products.length} ${'products'.tr()}',
                              style: TextStyle(fontSize: 9.sp, color: c.hint),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

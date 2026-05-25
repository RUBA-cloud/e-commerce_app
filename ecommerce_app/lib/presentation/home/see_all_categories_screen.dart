import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/presentation/home/see_all_products_screen.dart';
import 'package:ecommerce_app/presentation/home/widgets/app_network_image.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeeAllCategoriesScreen extends StatefulWidget {
  const SeeAllCategoriesScreen({
    super.key,
    required this.categories,
    required this.selectedIndex,
  });

  final List<CategoriesDataDataEntity> categories;
  final int selectedIndex;

  @override
  State<SeeAllCategoriesScreen> createState() =>
      _SeeAllCategoriesScreenState();
}

class _SeeAllCategoriesScreenState extends State<SeeAllCategoriesScreen> {
  late String _query;

  @override
  void initState() {
    super.initState();
    _query = '';
  }

  List<CategoriesDataDataEntity> get _filtered {
    if (_query.isEmpty) return widget.categories;
    final q = _query.toLowerCase();
    return widget.categories.where((c) {
      return (c.nameEn?.toLowerCase().contains(q) ?? false) ||
          (c.nameAr?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: c.textField,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: Row(
                children: [
                  _BackButton(c: c),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'categories'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: c.bodyText,
                      ),
                    ),
                  ),
                  // total count pill
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: c.hint.withOpacity(0.18)),
                    ),
                    child: Text(
                      '${widget.categories.length} ${'total'.tr()}',
                      style: TextStyle(
                          fontSize: 11.sp, color: c.hint),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Search bar ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                      color: c.hint.withOpacity(0.14)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(fontSize: 13.sp, color: c.bodyText),
                  decoration: InputDecoration(
                    hintText: 'search_categories'.tr(),
                    hintStyle:
                    TextStyle(fontSize: 13.sp, color: c.hint),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 20.r, color: c.hint),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                      onTap: () => setState(() => _query = ''),
                      child: Icon(Icons.close_rounded,
                          size: 18.r, color: c.hint),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Grid ─────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                child: Text(
                  'no_results'.tr(),
                  style: TextStyle(
                      fontSize: 14.sp, color: c.hint),
                ),
              )
                  : GridView.builder(
                padding: EdgeInsets.fromLTRB(
                    16.w, 0, 16.w, 24.h),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 0.76,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final cat = filtered[i];
                  // match against original index for selected state
                  final originalIndex =
                  widget.categories.indexOf(cat);
                  final selected =
                      widget.selectedIndex == originalIndex;
                  final name = localizedEnAr(
                    context: context,
                    nameEn: cat.nameEn,
                    nameAr: cat.nameAr,
                  );
                  return _CategoryTile(
                    cat: cat,
                    name: name,
                    selected: selected,
                    c: c,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeeAllProductsScreen(
                          categories: widget.categories,
                          initialCategoryIndex: originalIndex,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.cat,
    required this.name,
    required this.selected,
    required this.c,
    required this.onTap,
  });

  final CategoriesDataDataEntity cat;
  final String                   name;
  final bool                     selected;
  final AppColors                c;
  final VoidCallback             onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // ── Image box ──────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: selected
                        ? c.main.withOpacity(0.10)
                        : c.card,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: selected
                          ? c.main
                          : c.hint.withOpacity(0.14),
                      width: selected ? 1.5 : 0.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: cat.image != null
                      ? AppNetworkImage(
                    url: cat.image.toString(),
                    fit: BoxFit.cover,
                    placeholder: _placeholder(c, selected),
                  )
                      : _placeholder(c, selected),
                ),
                // item count badge
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? c.main.withOpacity(0.15)
                          : c.card.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: selected
                            ? c.main.withOpacity(0.3)
                            : c.hint.withOpacity(0.14),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${cat.products.length}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? c.main : c.hint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 7.h),

          // ── Name ───────────────────────────────────────────────
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight:
              selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? c.main : c.bodyText,
              height: 1.3,
            ),
          ),

          // ── Selected dot ───────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(top: 4.h),
            width: selected ? 5.r : 0,
            height: selected ? 5.r : 0,
            decoration: BoxDecoration(
              color: c.main,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(AppColors c, bool selected) {
    return Center(
      child: Icon(
        Icons.category_outlined,
        size: 28.r,
        color: selected ? c.main : c.hint,
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: c.hint.withOpacity(0.18)),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16.r,
          color: c.bodyText,
        ),
      ),
    );
  }
}

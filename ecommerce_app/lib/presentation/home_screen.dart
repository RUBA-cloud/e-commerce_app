// lib/presentation/home/main_home_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/response/PromoSlide.dart';
import 'package:ecommerce_app/presentation/home/fliter_dialog.dart';
import 'package:ecommerce_app/presentation/home/home_buttom_navigation.dart';
import 'package:ecommerce_app/presentation/home/see_all_brands_screen.dart';
import 'package:ecommerce_app/presentation/home/see_all_categories_screen.dart';
import 'package:ecommerce_app/presentation/home/see_all_products_screen.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_decorations.dart';
import 'package:ecommerce_app/presentation/widgets/accent_section_title.dart';
import 'package:ecommerce_app/presentation/widgets/categories_card.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/model/response/category_entity.dart';
import 'home/widgets/home_product_card.dart';

// ═══════════════════════════════════════════════════════
// HomeScreen
// ═══════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with UiUtility {
  int _hours   = 2;
  int _minutes = 14;
  int _seconds = 37;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeCubit.get(context).loadHome();
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_hours == 0 && _minutes == 0 && _seconds == 0) return;
        _seconds--;
        if (_seconds < 0) { _seconds = 59; _minutes--; }
        if (_minutes < 0) { _minutes = 59; _hours--;   }
        if (_hours   < 0) { _hours = _minutes = _seconds = 0; }
      });
      return mounted && (_hours > 0 || _minutes > 0 || _seconds > 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Read theme colors once here via the ThemeExtension
    final c = Theme.of(context).colorScheme;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.get(context);
        return Scaffold(
          backgroundColor: c.surface,
          body: Stack(
            children: [
              HomeBackgroundDecor(),
              SafeArea(
                child: Column(
                  children: [
                    _HomeHeader(cubit: cubit),
                    Expanded(child: _buildBody(context, state, cubit)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      HomeState state,
      HomeCubit cubit,
      ) {
    // ✅ Read colors from context — no need to pass c around
    final c = Theme.of(context).appColors;

    if (state is HomeLoading) {
      return Center(child: CircularProgressIndicator(color: c.buttonText));
    }

    if (state is HomeFailed) {
      return getErrorView(
        context: context,
        message: state.message,
        onRetry: cubit.loadHome,
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          color:     c.label,
          onRefresh: cubit.loadHome,
          child: _Body(
            cubit:   cubit,
            hours:   _hours,
            minutes: _minutes,
            seconds: _seconds,
          ),
        ),
        if (state is HomeFilterLoading)
          Positioned(
            top: 0, left: 0, right: 0,
            child: LinearProgressIndicator(
              color:           c.buttonText,
              backgroundColor: c.button.withOpacity(0.15),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// _Body  — reads colors from context directly
// ═══════════════════════════════════════════════════════

class _Body extends StatelessWidget {
  const _Body({
    required this.cubit,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final HomeCubit cubit;
  final int       hours;
  final int       minutes;
  final int       seconds;

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context — no parameter needed
    final c = Theme.of(context).colorScheme;

    final brands   = cubit.selectedCategoryBrands;
    final products = cubit.selectedProducts;

    return ListView(
      padding: EdgeInsets.zero,
      children: [

        // ── Promo carousel ───────────────────────────────────────────────
        const _PromoCarousel(),
        SizedBox(height: 20.h),

        // ── Categories row ───────────────────────────────────────────────
        AccentSectionTitle(
          title:                'categories'.tr(),
          subtitle:             'explore_collections'.tr(),
          accentColor:          c.primary,
          accentSecondaryColor: c.surface,
          seeAllLabel:          'see_all'.tr(),
          onSeeAll: () {
            final cats = cubit.categoriesEntity?.data.data;
            if (cats == null || cats.isEmpty) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeeAllCategoriesScreen(
                  categories:    cats,
                  selectedIndex: cubit.selectedCategoryIndex,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 12.h),
        CategoryCard(cubit: cubit),
        SizedBox(height: 16.h),

        // ── Flash sale bar ───────────────────────────────────────────────
        _FlashBar(hours: hours, minutes: minutes, seconds: seconds),
        SizedBox(height: 20.h),

        // ── Brands for selected category ─────────────────────────────────
        if (brands.isNotEmpty) ...[
          AccentSectionTitle(
            title:                'top_brands'.tr(),
            subtitle:             'trusted_partners'.tr(),
            accentColor:          c.primary,
            accentSecondaryColor: c.secondary,
            seeAllLabel:          'see_all'.tr(),
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeeAllBrandsScreen(brands: brands),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _BrandsRow(brands: brands, cubit: cubit),
          SizedBox(height: 20.h),
        ],

        // ── Products for selected category ───────────────────────────────
        AccentSectionTitle(
          title:                'products'.tr(),
          subtitle:             'handpicked_for_you'.tr(),
          accentColor:          c.primary,
          accentSecondaryColor: c.secondary,
          seeAllLabel:          'see_all'.tr(),
          onSeeAll: () {
            final cats = cubit.categoriesEntity?.data.data;
            if (cats == null || cats.isEmpty) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeeAllProductsScreen(
                  categories:          cats,
                  initialCategoryIndex: cubit.selectedCategoryIndex,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 12.h),

        if (cubit.activeFilter.isActive) ...[
          _ActiveFilterBar(cubit: cubit),
          SizedBox(height: 12.h),
        ],
        if (products.isEmpty)
         emptyWidget(c: Theme.of(context).appColors)
        else
          ProductsGrid(products: products, c: Theme.of(context).appColors,),
        SizedBox(height: 100.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// _ActiveFilterBar
// ═══════════════════════════════════════════════════════

class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({required this.cubit});

  final HomeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final c      = Theme.of(context).colorScheme; // ✅
    final f      = cubit.activeFilter;
    final brands = cubit.selectedCategoryBrands;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Wrap(
        spacing:    8.w,
        runSpacing: 6.h,
        children: [

          if (f.minPrice > 0 || f.maxPrice < 10000)
            _FilterChip(
              label: '\$${f.minPrice.toInt()}–\$${f.maxPrice.toInt()}',
              onRemove: () => cubit.applyFilter(
                f.copyWith(minPrice: 0, maxPrice: 10000),
              ),
            ),

          if (f.selectedBrandId != null && brands.isNotEmpty)
            _FilterChip(
              label: brands
                  .firstWhere(
                    (b) => b.id == f.selectedBrandId,
                orElse: () => brands.first,
              )
                  .nameEn,
              onRemove: () => cubit.applyFilter(
                f.copyWith(clearBrand: true),
              ),
            ),

          GestureDetector(
            onTap: cubit.clearFilter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color:        c.surface.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border:       Border.all(color: c.surface.withOpacity(0.4)),
              ),
              child: Text(
                'clear_all'.tr(),
                style: TextStyle(
                  fontSize:   11.sp,
                  color:      c.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _FilterChip
// ═══════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  final String       label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme; // ✅

    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 4.w, top: 6.h, bottom: 6.h),
      decoration: BoxDecoration(
        color:        c.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: c.primary.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize:   11.sp,
              color:      c.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width:  16.r,
              height: 16.r,
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 10.r, color: c.primary
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _HomeHeader
// ═══════════════════════════════════════════════════════

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.cubit});

  final HomeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final c        = Theme.of(context).colorScheme; // ✅
    final userName = '';                           // replace with real user name

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:  48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c.primary, c.surface],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color:      c.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.person_rounded, color: c.primary, size: 26.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'good_morning'.tr(),
                      style: TextStyle(fontSize: 12.sp, color: c.surface),
                    ),
                    Text(
                      userName.isEmpty ? 'guest'.tr() : userName,
                      style: TextStyle(
                        fontSize:      18.sp,
                        fontWeight:    FontWeight.w800,
                        color:         c.primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderIcon(icon: Icons.notifications_none_rounded, badge: true),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => ButtonHomeNavigationScreen.goToCart(context),
                child: _HeaderIcon(icon: Icons.shopping_bag_outlined),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          GlassSurface(

            radius:  18.r,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            child: Row(
              children: [
                Container(
                  width:  36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color:        c.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.search_rounded, size: 20.r, color: c.surface),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'search_hint'.tr(),
                    style: TextStyle(fontSize: 13.sp, color: c.primary),
                  ),
                ),
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    final filterActive = cubit.activeFilter.isActive;
                    return GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const FilterDialog(),
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width:  40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [c.primary, c.surface]),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              size:  20.r,
                              color: c.primary
                            ),
                          ),
                          if (filterActive)
                            Positioned(
                              top: -3, right: -3,
                              child: Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  color:  Colors.redAccent,
                                  shape:  BoxShape.circle,
                                  border: Border.all(color: c.primary, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _HeaderIcon
// ═══════════════════════════════════════════════════════

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    this.badge = false,
  });

  final IconData icon;
  final bool     badge;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme; // ✅

    return Stack(
      children: [
        Container(
          width:  42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color:      c.secondary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color:      c.secondary.withOpacity(0.10),
                blurRadius: 8,
                offset:     const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 22.r, color: c.primary
          ),
        ),
        if (badge)
          Positioned(
            top: 8, right: 8,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color:  c.primary,
                shape:  BoxShape.circle,
                border: Border.all(color: c.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// _PromoCarousel
// ═══════════════════════════════════════════════════════

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> with UiUtility {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;// ✅

    final slides = [
      PromoSlideData(
        badge:    'limited_offer'.tr(),
        title:    'summer_collection'.tr(),
        subtitle: 'free_delivery_notice'.tr(),
        discount: '50%',
        gradient: [c.primary, c.surface],
      ),
      PromoSlideData(
        badge:    'new_arrivals'.tr(),
        title:    'fresh_styles'.tr(),
        subtitle: 'trending_now'.tr(),
        discount: '30%',
        gradient: [c.secondary, c.surface],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller:    _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount:     slides.length,
            itemBuilder:   (ctx, i) => promoSlide(context: ctx, data: slides[i]),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (i) {
            final active = _page == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin:   EdgeInsets.symmetric(horizontal: 3.w),
              width:    active ? 18.w : 6.w,
              height:   6.h,
              decoration: BoxDecoration(
                color:        active ? c.primary : c.surface.withOpacity(0.35),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// _FlashBar
// ═══════════════════════════════════════════════════════

class _FlashBar extends StatelessWidget {
  const _FlashBar({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int hours;
  final int minutes;
  final int seconds;

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;// ✅

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primary, c.secondary],
          begin:  Alignment.centerLeft,
          end:    Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color:      c.primary.withOpacity(0.35),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20, top: -20,
            child: Icon(
              Icons.bolt_rounded,
              size:  100.r,
              color: c.primary.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color:        c.surface.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.bolt_rounded, size: 22.r, color: c.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'flash_sale'.tr(),
                        style: TextStyle(
                          fontSize:   15.sp,
                          fontWeight: FontWeight.w800,
                          color:      c.primary,
                        ),
                      ),
                      Text(
                        'ends_today'.tr(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color:    c.primary.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _TimerBox(val: _pad(hours)),
                    _timerSep(context),
                    _TimerBox(val: _pad(minutes)),
                    _timerSep(context),
                    _TimerBox(val: _pad(seconds)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerSep(BuildContext context) {
    final c = Theme.of(context).appColors; // ✅
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        ':',
        style: TextStyle(
          fontSize:   14.sp,
          fontWeight: FontWeight.w700,
          color:      c.buttonText.withOpacity(0.6),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _TimerBox
// ═══════════════════════════════════════════════════════

class _TimerBox extends StatelessWidget {
  const _TimerBox({required this.val});

  final String val;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors; // ✅

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color:        c.buttonText.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        val,
        style: TextStyle(
          fontSize:   13.sp,
          fontWeight: FontWeight.w500,
          color:      c.buttonText,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _BrandsRow
// ═══════════════════════════════════════════════════════

class _BrandsRow extends StatelessWidget {
  const _BrandsRow({
    required this.brands,
    required this.cubit,
  });

  final List<CategoryDataDataProductsBrandsEntity> brands;
  final HomeCubit                                  cubit;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors; // ✅

    if (brands.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 118.h,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding:          EdgeInsets.symmetric(horizontal: 16.w),
        itemCount:        brands.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (_, i) {
          final brand      = brands[i];
          final isSelected = cubit.activeFilter.selectedBrandId == brand.id;
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                cubit.applyFilter(cubit.activeFilter.copyWith(clearBrand: true));
              } else {
                cubit.applyFilter(cubit.activeFilter.copyWith(selectedBrandId: brand.id));
              }
            },

          );
        },
      ),
    );
  }
}
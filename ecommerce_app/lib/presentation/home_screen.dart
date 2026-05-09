import 'package:ecommerce_app/data/model/response/categories_entity.dart';
import 'package:ecommerce_app/presentation/product_details.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNav  = 0;
  int _hours   = 2;
  int _minutes = 14;
  int _seconds = 37;
  late HomeCubit homeCubit;

  @override
  void initState() {
    super.initState();
    _startTimer();
    homeCubit = HomeCubit.get(context);
    homeCubit.fetchCategories();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _seconds--;
        if (_seconds < 0) { _seconds = 59; _minutes--; }
        if (_minutes < 0) { _minutes = 59; _hours--;   }
        if (_hours   < 0) { _hours = _minutes = _seconds = 0; }
      });
      return _hours > 0 || _minutes > 0 || _seconds > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.get(context);
        return Scaffold(
          backgroundColor: const Color(0xFFF7F6F2),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildSearchRow(),
                Expanded(
                  child: state is HomeLoading
                      ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF534AB7)))
                      : state is HomeFailed
                      ? _buildError(state.message, cubit)
                      : _buildBody(cubit),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Error ─────────────────────────────────────────────────
  Widget _buildError(String? message, HomeCubit cubit) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: Colors.grey[400]),
          SizedBox(height: 12.h),
          Text(message ?? 'Something went wrong',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: cubit.fetchCategories,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF534AB7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text('Retry',
                  style: TextStyle(fontSize: 13.sp, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────
  Widget _buildBody(HomeCubit cubit) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(),
          SizedBox(height: 20.h),
          _buildSectionHeader('Categories', onTap: () {}),
          SizedBox(height: 12.h),
          _buildCategories(cubit),
          SizedBox(height: 16.h),
          _buildFlashBar(),
          SizedBox(height: 16.h),
          _buildSectionHeader('Products', onTap: () {}),
          SizedBox(height: 12.h),
          _buildProductsGrid(cubit),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 38.r, height: 38.r,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Text('AR',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,
                    color: const Color(0xFF3C3489))),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500])),
              Text('Ahmad Al-Rashid',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          _iconBtn(Icons.notifications_outlined, badge: true),
          SizedBox(width: 8.w),
          _iconBtn(Icons.shopping_bag_outlined),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, {bool badge = false}) {
    return Stack(
      children: [
        Container(
          width: 38.r, height: 38.r,
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFE8),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.r, color: Colors.grey[600]),
        ),
        if (badge)
          Positioned(
            top: 7, right: 7,
            child: Container(
              width: 7, height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFD85A30),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  // ── Search ────────────────────────────────────────────────
  Widget _buildSearchRow() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFE8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.r, color: Colors.grey[500]),
                  SizedBox(width: 8.w),
                  Text('Search products, brands...',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 42.r, height: 42.r,
            decoration: BoxDecoration(
              color: const Color(0xFF3C3489),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.tune_rounded, size: 20.r, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF26215C),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.all(18.r),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('Limited time offer',
                      style: TextStyle(fontSize: 10.sp,
                          color: const Color(0xFFAFA9EC))),
                ),
                SizedBox(height: 8.h),
                Text('Summer\nCollection',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500,
                        color: Colors.white, height: 1.2)),
                SizedBox(height: 4.h),
                Text('Free delivery on orders above \$30',
                    style: TextStyle(fontSize: 11.sp,
                        color: const Color(0xFFAFA9EC))),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F77DD),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Shop now',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white,
                              fontWeight: FontWeight.w500)),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward, size: 14.r, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFF534AB7),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text('Up to',
                    style: TextStyle(fontSize: 10.sp,
                        color: const Color(0xFFAFA9EC))),
                Text('50%',
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w500,
                        color: Colors.white)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9E75).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('OFF',
                      style: TextStyle(fontSize: 10.sp,
                          color: const Color(0xFF9FE1CB),
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────
  Widget _buildSectionHeader(String title,
      {VoidCallback? onTap, bool showLink = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
          if (showLink)
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text('See all',
                      style: TextStyle(fontSize: 12.sp,
                          color: const Color(0xFF1D9E75))),
                  Icon(Icons.chevron_right, size: 16.r,
                      color: const Color(0xFF1D9E75)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Categories from API ───────────────────────────────────
  Widget _buildCategories(HomeCubit cubit) {
    final cats = cubit.categories;
    if (cats.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: cats.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          final cat      = cats[i];
          final selected = cubit.selectedCategoryIndex == i;
          return GestureDetector(
            onTap: () => cubit.selectCategory(i),
            child: Column(
              children: [
                Container(
                  width: 52.r, height: 52.r,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEEEDFE)
                        : const Color(0xFFF1EFE8),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF534AB7)
                          : Colors.transparent,
                      width: selected ? 2 : 0,
                    ),
                  ),
                  child: cat.image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.network(cat.image.toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.category_outlined, size: 24.r,
                          color: selected
                              ? const Color(0xFF534AB7)
                              : Colors.grey[500]),
                    ),
                  )
                      : Icon(Icons.category_outlined, size: 24.r,
                      color: selected
                          ? const Color(0xFF534AB7)
                          : Colors.grey[500]),
                ),
                SizedBox(height: 6.h),
                Text(cat.nameEn,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: selected
                        ? const Color(0xFF534AB7)
                        : Colors.grey[500],
                    fontWeight: selected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Flash bar ─────────────────────────────────────────────
  Widget _buildFlashBar() {
    String pad(int v) => v.toString().padLeft(2, '0');
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3C3489),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 34.r, height: 34.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.bolt, size: 20.r,
                color: const Color(0xFFFAC775)),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flash sale',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,
                      color: Colors.white)),
              Text('Ends today',
                  style: TextStyle(fontSize: 10.sp,
                      color: const Color(0xFFAFA9EC))),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _timerBox(pad(_hours)),
              Text(' : ', style: TextStyle(color: const Color(0xFFAFA9EC),
                  fontSize: 13.sp)),
              _timerBox(pad(_minutes)),
              Text(' : ', style: TextStyle(color: const Color(0xFFAFA9EC),
                  fontSize: 13.sp)),
              _timerBox(pad(_seconds)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerBox(String val) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(val,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,
              color: Colors.white)),
    );
  }

  // ── Products grid from API ────────────────────────────────
  Widget _buildProductsGrid(HomeCubit cubit) {
    final products = cubit.selectedProducts;
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Text('No products in this category',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing:  10.h,
          childAspectRatio: 0.72,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => _buildProductCard(products[i]),
      ),
    );
  }

  Widget _buildProductCard(CategoriesDataDataProductsEntity p) {
    final isFav = ValueNotifier<bool>(false);
    return ValueListenableBuilder<bool>(
      valueListenable: isFav,
      builder: (_, fav, __) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: p),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ─────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18.r)),
                  child: SizedBox(
                    height: 120.h,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ✅ removed Expanded — invalid inside Stack
                        p.mainImage.isNotEmpty
                            ? Image.network(
                          p.mainImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImg(),
                        )
                            : _placeholderImg(),

                        // Favourite btn
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: () => isFav.value = !isFav.value,
                            child: Container(
                              width: 28.r, height: 28.r,
                              decoration: BoxDecoration(
                                color: fav
                                    ? const Color(0xFFFBEAF0)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: fav
                                      ? const Color(0xFFED93B1)
                                      : Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Icon(
                                fav ? Icons.favorite : Icons.favorite_border,
                                size: 15.r,
                                color: fav
                                    ? const Color(0xFF993556)
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),

                        // Colors row
                        if (p.colors.isNotEmpty)
                          Positioned(
                            bottom: 6, left: 8,
                            child: Row(
                              children: p.colors.take(3).map((hex) {
                                return Container(
                                  width: 12.r, height: 12.r,
                                  margin: EdgeInsets.only(right: 3.w),
                                  decoration: BoxDecoration(
                                    color: _hexToColor(hex),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Body ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.category.nameEn,
                          style: TextStyle(fontSize: 10.sp,
                              color: const Color(0xFF1D9E75))),
                      SizedBox(height: 2.h),
                      Text(p.nameEn,
                          style: TextStyle(fontSize: 12.sp,
                              fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 6.h),

                      if (p.sizes.isNotEmpty)
                        Wrap(
                          spacing: 4.w,
                          children: p.sizes.take(3).map((s) =>
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EFE8),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(s.nameEn,
                                    style: TextStyle(fontSize: 9.sp,
                                        color: Colors.grey[600])),
                              ),
                          ).toList(),
                        ),
                      SizedBox(height: 8.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${p.price}',
                              style: TextStyle(fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF085041))),
                          Container(
                            width: 28.r, height: 28.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D9E75),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.add, size: 16.r,
                                color: Colors.white),
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
      },
    );
  }

  Widget _placeholderImg() {
    return Container(
      color: const Color(0xFFF1EFE8),
      child: Icon(Icons.image_outlined, size: 40.r,
          color: Colors.grey[400]),
    );
  }

  Color _hexToColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  // ── Bottom nav ────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined,          'label': 'Home'},
      {'icon': Icons.category_outlined,      'label': 'Explore'},
      {'icon': Icons.favorite_border,        'label': 'Wishlist'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart'},
      {'icon': Icons.person_outline,         'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.12))),
      ),
      padding: EdgeInsets.only(
          top: 10.h, bottom: 16.h, left: 8.w, right: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final selected = _selectedNav == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedNav = e.key),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(e.value['icon'] as IconData,
                    size: 24.r,
                    color: selected
                        ? const Color(0xFF534AB7)
                        : Colors.grey[400]),
                SizedBox(height: 4.h),
                Text(e.value['label'] as String,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: selected
                          ? const Color(0xFF534AB7)
                          : Colors.grey[400],
                      fontWeight: selected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    )),
                if (selected) ...[
                  SizedBox(height: 3.h),
                  Container(
                    width: 5, height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF534AB7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
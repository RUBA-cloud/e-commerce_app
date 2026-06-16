import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/response/carts/categories_entity.dart';
import 'package:ecommerce_app/presentation/home/home_buttom_navigation.dart';
import 'package:ecommerce_app/presentation/home/widgets/app_network_image.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:ecommerce_app/presentation/widgets/similar_products.dart';
import 'package:ecommerce_app/services/product_details/product_details_cubit.dart';
import 'package:ecommerce_app/services/product_details/product_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final CategoriesDataDataProductsEntity product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with UiUtility {
  // ── helpers ───────────────────────────────────────────────────────────────
  List<String> get _imageUrls {
    if (widget.product.images.isNotEmpty) {
      return widget.product.images.map((e) => e.imagePath).toList();
    }
    if (widget.product.mainImage.isNotEmpty) return [widget.product.mainImage];
    return [];
  }

  String _name(BuildContext ctx) => localizedEnAr(
    context: ctx,
    nameEn: widget.product.nameEn,
    nameAr: widget.product.nameAr,
  );

  String _category(BuildContext ctx) => localizedEnAr(
    context: ctx,
    nameEn: widget.product.category.nameEn,
    nameAr: widget.product.category.nameAr,
  );

  String _description(BuildContext ctx) => localizedEnAr(
    context: ctx,
    nameEn: widget.product.descriptionEn,
    nameAr: widget.product.descriptionAr,
  );

  double get _unitPrice => double.tryParse(widget.product.price) ?? 0;

  // ── Cubit ─────────────────────────────────────────────────────────────────
  late final ProductDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProductDetailsCubit(widget.product);
    _cubit.fetchSelectedCategory(widget.product.categoryId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<ProductDetailsCubit, ProductDetailsState>(
        listener: (context, state) {
          // Navigate to cart tab on successful add
          if (state is AddProductsToCartsSuccess) {
            ButtonHomeNavigationScreen.goToCart(context);
          }
        },
        child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            final c = Theme.of(context).appColors;
            return Scaffold(
              backgroundColor: c.textField,
              extendBody: true,
              body: Stack(
                children: [
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _gallerySliver(context, c, state),
                      SliverToBoxAdapter(
                        child: _contentSheet(context, c, state),
                      ),
                    ],
                  ),
                  _topBar(context, c, state),
                  _bottomDock(context, c, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GALLERY
  // ══════════════════════════════════════════════════════════════════════════
  Widget _gallerySliver(
      BuildContext context, AppColors c, ProductDetailsState state) {
    final urls = _imageUrls;
    final cubit = ProductDetailsCubit.get(context);
    final controller = PageController(initialPage: state.selectedImageIndex);

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Container(
            height: 380.h,
            color: c.main.withOpacity(0.06),
            child: urls.isEmpty
                ? _emptyGallery(c)
                : PageView.builder(
              controller: controller,
              onPageChanged: cubit.imageChanged,
              itemCount: urls.length,
              itemBuilder: (_, i) => AppNetworkImage(
                url: urls[i],
                fit: BoxFit.contain,
                placeholder: _emptyGallery(c),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, c.textField.withOpacity(0.9)],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 68.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = state.selectedImageIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: active ? 22.w : 7.w,
                    height: 7.h,
                    decoration: BoxDecoration(
                      color: active ? c.main : c.hint.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
            ),
          if (urls.isNotEmpty)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 58.h,
              right: 16.w,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: c.card.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: c.hint.withOpacity(0.12)),
                ),
                child: Text(
                  '${state.selectedImageIndex + 1} / ${urls.length}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: c.bodyText,
                  ),
                ),
              ),
            ),
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16.h,
              child: SizedBox(
                height: 60.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: urls.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final selected = state.selectedImageIndex == i;
                    return GestureDetector(
                      onTap: () => controller.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: selected ? c.main : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: selected
                              ? [
                            BoxShadow(
                              color: c.main.withOpacity(0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: AppNetworkImage(
                              url: urls[i], fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyGallery(AppColors c) => Container(
    color: c.main.withOpacity(0.06),
    alignment: Alignment.center,
    child: Icon(
      Icons.shopping_bag_outlined,
      size: 80.r,
      color: c.main.withOpacity(0.30),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // TOP BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _topBar(
      BuildContext context, AppColors c, ProductDetailsState state) {
    final cubit = ProductDetailsCubit.get(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          12.w,
          MediaQuery.paddingOf(context).top + 6.h,
          12.w,
          12.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.card.withOpacity(0.92), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            _circleBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              c: c,
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                _name(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: c.bodyText,
                ),
              ),
            ),
            _circleBtn(
              icon: state.isFav
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              c: c,
              iconColor: state.isFav ? Colors.red.shade400 : c.icon,
              bg: state.isFav
                  ? Colors.red.shade50
                  : c.card.withOpacity(0.92),
              onTap: cubit.toggleFav,
            ),
            SizedBox(width: 8.w),
            _circleBtn(
              icon: Icons.ios_share_rounded,
              c: c,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required AppColors c,
    required VoidCallback onTap,
    Color? iconColor,
    Color? bg,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: bg ?? c.card.withOpacity(0.92),
            shape: BoxShape.circle,
            border: Border.all(color: c.hint.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: c.hint.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 18.r, color: iconColor ?? c.icon),
        ),
      );

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENT SHEET
  // ══════════════════════════════════════════════════════════════════════════
  Widget _contentSheet(
      BuildContext context, AppColors c, ProductDetailsState state) {
    final desc = _description(context);

    return Transform.translate(
      offset: Offset(0, -24.h),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(
              color: c.main.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: c.hint.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pills
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      _pill(_category(context), c),
                      _pill(
                        'in_stock'.tr(),
                        c,
                        color: const Color(0xFF0F6E56),
                        bg: const Color(0xFFE1F5EE),
                        borderColor: const Color(0xFF9FE1CB),
                      ),
                      _pill(
                        'new_arrival'.tr(),
                        c,
                        color: c.main,
                        bg: c.main.withOpacity(0.10),
                        borderColor: c.main.withOpacity(0.3),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    _name(context),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: c.bodyText,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _ratingRow(c),
                  SizedBox(height: 16.h),
                  _trustRow(c),
                  SizedBox(height: 18.h),
                  _priceQtyCard(context, c, state),
                  if (widget.product.colors.isNotEmpty) ...[
                    SizedBox(height: 22.h),
                    _sectionLabel('color'.tr(), c),
                    SizedBox(height: 10.h),
                    _colorsRow(context, c, state),
                  ],
                  if (widget.product.sizes.isNotEmpty) ...[
                    SizedBox(height: 22.h),
                    _sectionLabel('size'.tr(), c),
                    SizedBox(height: 10.h),
                    _sizesWrap(context, c, state),
                  ],
                  SizedBox(height: 22.h),
                  _sectionLabel('description'.tr(), c),
                  SizedBox(height: 10.h),
                  // Description card
                  GestureDetector(
                    onTap: ProductDetailsCubit.get(context).toggleDesc,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: c.textField,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            desc,
                            maxLines: state.descExpanded ? null : 3,
                            overflow: state.descExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: c.bodyText.withOpacity(0.85),
                              height: 1.65,
                            ),
                          ),
                          if (desc.length > 100) ...[
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.descExpanded
                                      ? 'show_less'.tr()
                                      : 'read_more'.tr(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: c.main,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  state.descExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 14.r,
                                  color: c.main,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  _sectionLabel('product_info'.tr(), c),
                  SizedBox(height: 10.h),
                  _highlights(context, c),
                  SizedBox(height: 22.h),
                ],
              ),
            ),

            // ── Similar products ──────────────────────────────────────────
            if (state.similarCategory?.products != null)
              SimilarProductsSection(
                similarProducts: state.similarCategory!,
                currentProduct: widget.product,
                onProductTap: (product) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailsScreen(product: widget.product),
                  ),
                ),
              ),

            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }

  // ── Pill ──────────────────────────────────────────────────────────────────
  Widget _pill(
      String text,
      AppColors c, {
        Color? color,
        Color? bg,
        Color? borderColor,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg ?? c.textField,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor ?? c.hint.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color ?? c.hint,
        ),
      ),
    );
  }

  // ── Rating row ────────────────────────────────────────────────────────────
  Widget _ratingRow(AppColors c) {
    return Row(
      children: [
        ...List.generate(
          5,
              (i) => Icon(
            i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
            size: 18.r,
            color: Colors.amber[600],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '4.8',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: c.bodyText,
          ),
        ),
        Text(
          ' · 128 ${'reviews'.tr()}',
          style: TextStyle(fontSize: 11.sp, color: c.hint),
        ),
      ],
    );
  }

  // ── Trust row ─────────────────────────────────────────────────────────────
  Widget _trustRow(AppColors c) {
    final items = [
      (Icons.local_shipping_outlined, 'free_shipping'.tr()),
      (Icons.verified_user_outlined, 'secure_payment'.tr()),
      (Icons.autorenew_rounded, 'easy_returns'.tr()),
    ];
    return Row(
      children: items.asMap().entries.map((e) {
        final item = e.value;
        final last = e.key == items.length - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: last ? 0 : 8.w),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: c.textField,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: c.hint.withOpacity(0.10)),
            ),
            child: Column(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: c.main.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(item.$1, size: 17.r, color: c.main),
                ),
                SizedBox(height: 5.h),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    color: c.bodyText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text, AppColors c) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.main, c.sub],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: c.bodyText,
          ),
        ),
      ],
    );
  }

  // ── Price + qty card ──────────────────────────────────────────────────────
  Widget _priceQtyCard(
      BuildContext context, AppColors c, ProductDetailsState state) {
    final cubit = ProductDetailsCubit.get(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.main, c.sub],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: c.main.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'price'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: c.buttonText.withOpacity(0.75),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '\$${widget.product.price}',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w900,
                        color: c.buttonText,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '× ${state.quantity}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: c.buttonText.withOpacity(0.85),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: c.buttonText.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _qtyBtn(Icons.remove_rounded, c, cubit.decrement),
                Text(
                  '${state.quantity}',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: c.buttonText,
                  ),
                ),
                _qtyBtn(Icons.add_rounded, c, cubit.increment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, AppColors c, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: c.buttonText.withOpacity(0.20),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: c.buttonText, size: 20.r),
        ),
      );

  // ── Colors ────────────────────────────────────────────────────────────────
  Widget _colorsRow(
      BuildContext context, AppColors c, ProductDetailsState state) {
    final cubit = ProductDetailsCubit.get(context);
    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.product.colors.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final hex = widget.product.colors[i];
          final selected = state.selectedColor == hex;
          return GestureDetector(
            onTap: () => cubit.selectColor(hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                color: _hexColor(hex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? c.main : c.hint.withOpacity(0.25),
                  width: selected ? 2.5 : 1,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: _hexColor(hex).withOpacity(0.45),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
                    : null,
              ),
              child: selected
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 20.r)
                  : null,
            ),
          );
        },
      ),
    );
  }

  // ── Sizes ─────────────────────────────────────────────────────────────────
  Widget _sizesWrap(
      BuildContext context, AppColors c, ProductDetailsState state) {
    final cubit = ProductDetailsCubit.get(context);
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: widget.product.sizes.asMap().entries.map((e) {
        final i = e.key;
        final size = e.value;
        final selected = state.selectedSizeIndex == i;
        final label = localizedEnAr(
          context: context,
          nameEn: size.nameEn,
          nameAr: size.nameAr,
        );
        return GestureDetector(
          onTap: () => cubit.selectSize(size.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: BoxConstraints(minWidth: 64.w),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient:
              selected ? LinearGradient(colors: [c.main, c.sub]) : null,
              color: selected ? null : c.textField,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: selected ? Colors.transparent : c.hint.withOpacity(0.18),
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: c.main.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: selected ? c.buttonText : c.bodyText,
                  ),
                ),
                if (size.price > 0)
                  Text(
                    '+\$${size.price}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: selected
                          ? c.buttonText.withOpacity(0.85)
                          : c.main,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Product info ──────────────────────────────────────────────────────────
  Widget _highlights(BuildContext context, AppColors c) {
    final type = localizedEnAr(
      context: context,
      nameEn: widget.product.type.nameEn,
      nameAr: widget.product.type.nameAr,
    );
    return Column(
      children: [
        _infoTile(Icons.category_rounded, 'categories'.tr(),
            _category(context), c),
        SizedBox(height: 8.h),
        _infoTile(Icons.style_rounded, 'type'.tr(), type, c),
        if (widget.product.colors.isNotEmpty) ...[
          SizedBox(height: 8.h),
          _infoTile(
            Icons.palette_rounded,
            'color'.tr(),
            '${widget.product.colors.length} colors',
            c,
          ),
        ],
      ],
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value, AppColors c) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: c.textField,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: c.hint.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: c.main.withOpacity(0.09),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(icon, size: 19.r, color: c.main),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 10.sp, color: c.hint)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: c.bodyText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: c.hint.withOpacity(0.6), size: 20.r),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM DOCK
  // ══════════════════════════════════════════════════════════════════════════
  Widget _bottomDock(
      BuildContext context, AppColors c, ProductDetailsState state) {
    final total = _unitPrice * state.quantity;
    final totalStr = total % 1 == 0
        ? '\$${total.toInt()}'
        : '\$${total.toStringAsFixed(2)}';

    final isAdding = state is AddProductCartsLoading;

    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: MediaQuery.paddingOf(context).bottom + 12.h,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: c.hint.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: c.main.withOpacity(0.14),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Total
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('total'.tr(),
                        style: TextStyle(fontSize: 10.sp, color: c.hint)),
                    Text(
                      totalStr,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w900,
                        color: c.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cart shortcut
            GestureDetector(
              onTap: () => ButtonHomeNavigationScreen.goToCart(context),
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: c.textField,
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(color: c.hint.withOpacity(0.14)),
                ),
                child: Icon(Icons.shopping_bag_outlined,
                    color: c.icon, size: 20.r),
              ),
            ),
            SizedBox(width: 8.w),

            // Add to cart
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isAdding ? null : () => _cubit.addToCart(context),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.main, c.sub]),
                    borderRadius: BorderRadius.circular(13.r),
                    boxShadow: [
                      BoxShadow(
                        color: c.main.withOpacity(0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isAdding
                      ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      color: c.buttonText,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          color: c.buttonText, size: 16.r),
                      SizedBox(width: 5.w),
                      Text(
                        'add_to_cart'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: c.buttonText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Buy now
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: c.sub.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(Icons.bolt_rounded,
                    color: c.buttonText, size: 22.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Utility ───────────────────────────────────────────────────────────────
  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
import 'package:ecommerce_app/data/model/response/categories_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetailsScreen extends StatefulWidget {
  final CategoriesDataDataProductsEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int    _selectedImageIndex = 0;
  int    _selectedSizeIndex  = -1;
  String _selectedColor      = '';
  int    _quantity           = 1;
  bool   _isFav              = false;

  CategoriesDataDataProductsEntity get p => widget.product;

  @override
  void initState() {
    super.initState();
    if (p.colors.isNotEmpty) _selectedColor = p.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGallery(),
                    _buildBody(),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor:  Colors.white,
      elevation:        0,
      pinned:           true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFE8),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16.r, color: Colors.grey[700]),
        ),
      ),
      title: Text(p.nameEn,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500,
              color: Colors.black),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _isFav = !_isFav),
          child: Container(
            margin: EdgeInsets.all(8.r),
            width: 36.r, height: 36.r,
            decoration: BoxDecoration(
              color: _isFav
                  ? const Color(0xFFFBEAF0)
                  : const Color(0xFFF1EFE8),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: _isFav
                    ? const Color(0xFFED93B1)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              size: 18.r,
              color: _isFav
                  ? const Color(0xFF993556)
                  : Colors.grey[500],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 12.w, top: 8, bottom: 8),
          width: 36.r, height: 36.r,
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFE8),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.share_outlined,
              size: 18.r, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // ── Image Gallery ─────────────────────────────────────────
  Widget _buildImageGallery() {
    final images = p.images;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Main image
          Container(
            height: 280.h,
            width: double.infinity,
            color: const Color(0xFFF7F6F2),
            child: images.isNotEmpty
                ? Image.network(
              images[_selectedImageIndex].imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
                : p.mainImage.isNotEmpty
                ? Image.network(p.mainImage,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),

          // Thumbnail row
          if (images.length > 1) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 64.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: images.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final selected = _selectedImageIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageIndex = i),
                    child: Container(
                      width: 60.r, height: 60.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF534AB7)
                              : Colors.grey.withOpacity(0.2),
                          width: selected ? 2 : 1,
                        ),
                        color: const Color(0xFFF7F6F2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.network(
                          images[i].imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                              Icons.image_outlined,
                              size: 24.r, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF1EFE8),
      child: Icon(Icons.image_outlined, size: 64.r, color: Colors.grey[400]),
    );
  }

  // ── Body ──────────────────────────────────────────────────
  Widget _buildBody() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          _buildPriceRow(),
          SizedBox(height: 20.h),
          if (p.colors.isNotEmpty) ...[
            _buildColors(),
            SizedBox(height: 20.h),
          ],
          if (p.sizes.isNotEmpty) ...[
            _buildSizes(),
            SizedBox(height: 20.h),
          ],
          _buildDescription(),
          SizedBox(height: 20.h),
          _buildCategory(),
          SizedBox(height: 20.h),
          _buildType(),
          if (p.additionals.isNotEmpty) ...[
            SizedBox(height: 20.h),
            _buildAdditionals(),
          ],
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category tag
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5EE),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(p.category.nameEn,
              style: TextStyle(fontSize: 11.sp,
                  color: const Color(0xFF0F6E56),
                  fontWeight: FontWeight.w500)),
        ),
        SizedBox(height: 8.h),
        Text(p.nameEn,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 4.h),
        Text(p.nameAr,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
      ],
    );
  }

  // ── Price row ─────────────────────────────────────────────
  Widget _buildPriceRow() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500])),
              SizedBox(height: 4.h),
              Text('\$${p.price}',
                  style: TextStyle(fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF085041))),
            ],
          ),
          // Quantity
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                _qtyBtn(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text('$_quantity',
                      style: TextStyle(fontSize: 15.sp,
                          fontWeight: FontWeight.w500)),
                ),
                _qtyBtn(Icons.add, () => setState(() => _quantity++)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r, height: 34.r,
        decoration: BoxDecoration(
          color: const Color(0xFF534AB7),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 16.r, color: Colors.white),
      ),
    );
  }

  // ── Colors ────────────────────────────────────────────────
  Widget _buildColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Color'),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          children: p.colors.map((hex) {
            final selected = _selectedColor == hex;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = hex),
              child: Container(
                width: 34.r, height: 34.r,
                decoration: BoxDecoration(
                  color: _hexToColor(hex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF534AB7)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(
                      color: _hexToColor(hex).withOpacity(0.4),
                      blurRadius: 6, spreadRadius: 1)]
                      : null,
                ),
                child: selected
                    ? Icon(Icons.check, size: 16.r, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Sizes ─────────────────────────────────────────────────
  Widget _buildSizes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Size'),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: p.sizes.asMap().entries.map((e) {
            final i        = e.key;
            final size     = e.value;
            final selected = _selectedSizeIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedSizeIndex = i),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF534AB7)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF534AB7)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(size.nameEn,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : Colors.black,
                        )),
                    if (size.price > 0) ...[
                      SizedBox(height: 2.h),
                      Text('+\$${size.price}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: selected
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF1D9E75),
                          )),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Description ───────────────────────────────────────────
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Description'),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6F2),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(p.descriptionEn,
              style: TextStyle(fontSize: 13.sp,
                  color: Colors.grey[700], height: 1.6)),
        ),
        if (p.descriptionAr.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(p.descriptionAr,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 13.sp,
                    color: Colors.grey[700], height: 1.6)),
          ),
        ],
      ],
    );
  }

  // ── Category ──────────────────────────────────────────────
  Widget _buildCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Category'),
        SizedBox(height: 10.h),
        _infoRow(Icons.category_outlined, p.category.nameEn),
      ],
    );
  }

  // ── Type ──────────────────────────────────────────────────
  Widget _buildType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Type'),
        SizedBox(height: 10.h),
        _infoRow(Icons.label_outline, p.type.nameEn),
      ],
    );
  }

  // ── Additionals ───────────────────────────────────────────
  Widget _buildAdditionals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Additional Info'),
        SizedBox(height: 10.h),
        ...p.additionals.map((a) =>
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: _infoRow(Icons.info_outline, a.toString()),
            ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Text(label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500));
  }

  Widget _infoRow(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: const Color(0xFF534AB7)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
          ),
        ],
      ),
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

  // ── Bottom bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.12))),
        ),
        child: Row(
          children: [
            // Wishlist btn
            Container(
              width: 48.r, height: 48.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFE8),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  size: 22.r, color: Colors.grey[600]),
            ),
            SizedBox(width: 12.w),
            // Add to cart btn
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF534AB7),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 20.r, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text('Add to Cart',
                          style: TextStyle(fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Buy now btn
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9E75),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt, size: 20.r, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text('Buy Now',
                          style: TextStyle(fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
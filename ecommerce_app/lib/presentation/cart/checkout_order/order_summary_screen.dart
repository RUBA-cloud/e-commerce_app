import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/request/make_order_request.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/presentation/home/widgets/app_network_image.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:ecommerce_app/services/cart/cart_cubit.dart';
import 'package:ecommerce_app/services/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key, required this.state});

  final CartGoToOrderSummary state;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final items = state.cart.data?.whereType<CartsDataEntity>().toList() ?? [];

    final subtotal = items.fold<double>(0, (sum, item) {
      final price = double.tryParse(item.product?.price ?? '0') ?? 0;
      final extra = (item.size?.price ?? 0).toDouble();
      return sum + (price + extra) * (item.quantity ?? 0);
    });
    const shipping = 0.0;
    final total = subtotal + shipping;

    return BlocListener<CartCubit, CartState>(
      listener: (context, s) {
        if (s is CartOrderSuccess) {
          showSnackBar(context: context, message: 'order_created_successfully'.tr());
        }
        if (s is CartOrderFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.message ?? 'error'.tr())),
          );
        }
      },
      child: Scaffold(
        backgroundColor: c.textField,
        extendBody: true,
        body: SafeArea(
          child: Column(
            children: [
              _header(context, c),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('delivery_address'.tr(), c),
                      SizedBox(height: 10.h),
                      _addressCard(context, c),
                      SizedBox(height: 22.h),
                      _sectionLabel('order_items'.tr(), c),
                      SizedBox(height: 10.h),
                      ...items.map((item) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _orderItemRow(context, c, item),
                      )),
                      SizedBox(height: 22.h),
                      _sectionLabel('price_breakdown'.tr(), c),
                      SizedBox(height: 10.h),
                      _priceBreakdown(c, subtotal, shipping, total),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _placeOrderDock(context, c, items, total),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context, AppColors c) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: c.card,
        border: Border(bottom: BorderSide(color: c.hint.withOpacity(0.12))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: c.textField,
                shape: BoxShape.circle,
                border: Border.all(color: c.hint.withOpacity(0.15)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16.r, color: c.icon),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.main, c.sub]),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('order_summary'.tr(),
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: c.bodyText)),
              Text('review_before_placing'.tr(),
                  style: TextStyle(fontSize: 12.sp, color: c.hint)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Address card ──────────────────────────────────────────────────────────

  Widget _addressCard(BuildContext context, AppColors c) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: c.hint.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          _addressRow(Icons.signpost_outlined, 'street_name'.tr(),
              state.street, c),
          SizedBox(height: 10.h),
          _addressRow(Icons.apartment_rounded, 'building_number'.tr(),
              state.building, c),
          SizedBox(height: 10.h),
          _addressRow(Icons.home_outlined, 'address_details'.tr(),
              state.fullAddress, c),
          if (state.latitude != null && state.longitude != null) ...[
            SizedBox(height: 10.h),
            _addressRow(
              Icons.location_pin,
              'coordinates'.tr(),
              '${state.latitude!.toStringAsFixed(5)}, '
                  '${state.longitude!.toStringAsFixed(5)}',
              c,
              iconColor: Colors.red.shade400,
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressRow(
      IconData icon,
      String label,
      String value,
      AppColors c, {
        Color? iconColor,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: c.main.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 17.r, color: iconColor ?? c.main),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10.sp, color: c.hint)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: c.bodyText)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Order item row ────────────────────────────────────────────────────────

  Widget _orderItemRow(BuildContext context, AppColors c, CartsDataEntity item) {
    final name = localizedEnAr(
      context: context,
      nameEn: item.product?.nameEn ?? '',
      nameAr: item.product?.nameAr ?? '',
    );
    final unitPrice = double.tryParse(item.product?.price ?? '0') ?? 0;
    final extra = (item.size?.price ?? 0).toDouble();
    final lineTotal = (unitPrice + extra) * (item.quantity ?? 0);

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: c.hint.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 56.r,
              height: 56.r,
              child: AppNetworkImage(
                  url: item.product?.mainImage ?? '', fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: c.bodyText)),
                SizedBox(height: 3.h),
                Text('× ${item.quantity ?? 0}',
                    style: TextStyle(fontSize: 11.sp, color: c.hint)),
              ],
            ),
          ),
          Text(
            '\$${lineTotal.toStringAsFixed(lineTotal % 1 == 0 ? 0 : 2)}',
            style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w800, color: c.main),
          ),
        ],
      ),
    );
  }

  // ── Price breakdown ───────────────────────────────────────────────────────

  Widget _priceBreakdown(
      AppColors c, double subtotal, double shipping, double total) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: c.hint.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _priceRow('subtotal'.tr(), subtotal, c),
          SizedBox(height: 8.h),
          _priceRow('shipping'.tr(), shipping, c, muted: true),
          Divider(height: 20.h, color: c.hint.withOpacity(0.15)),
          _priceRow('total'.tr(), total, c, bold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, AppColors c,
      {bool bold = false, bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: bold ? 15.sp : 13.sp,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: muted ? c.hint : c.bodyText)),
        Text(
          '\$${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}',
          style: TextStyle(
              fontSize: bold ? 18.sp : 14.sp,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              color: bold ? c.main : c.bodyText),
        ),
      ],
    );
  }

  // ── Place order dock ──────────────────────────────────────────────────────

  Widget _placeOrderDock(
      BuildContext context,
      AppColors c,
      List<CartsDataEntity> items,
      double total,
      ) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, s) {
        final isLoading = s is CartOrderLoading;
        return Container(
          padding: EdgeInsets.fromLTRB(
              16.w, 12.h, 16.w, MediaQuery.paddingOf(context).bottom + 12.h),
          decoration: BoxDecoration(
            color: c.card,
            boxShadow: [
              BoxShadow(
                  color: c.main.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, -4)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('total'.tr(),
                        style: TextStyle(fontSize: 10.sp, color: c.hint)),
                    Text(
                      '\$${total.toStringAsFixed(total % 1 == 0 ? 0 : 2)}',
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: c.bodyText),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                    context.read<CartCubit>().placeOrder(
                      MakeOrderRequest(
                        cartId: state.cart.data?.firstOrNull?.id ?? -1,
                        address: state.fullAddress,
                        streetName: state.street,
                        buildingNumber: state.building,
                        lat: state.latitude ?? 0.0,
                        long: state.longitude ?? 0.0,
                        orderStatusId: 1,
                        totalPrice: total,
                        products: items
                            .map((item) => OrderProductItem(
                          productId: item.product!.id!,
                          sizeId: item.sizeId!,
                          quantity: item.quantity ?? 1,
                          colors: [item.color ?? ''],
                        ))
                            .toList(),
                      ),
                    );
                  },
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [c.main, c.sub]),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                            color: c.main.withOpacity(0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isLoading
                        ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: CircularProgressIndicator(
                          color: c.buttonText, strokeWidth: 2),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            color: c.buttonText, size: 18.r),
                        SizedBox(width: 6.w),
                        Text('place_order'.tr(),
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: c.buttonText)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                colors: [c.main, c.sub]),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(text,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: c.bodyText)),
      ],
    );
  }
}
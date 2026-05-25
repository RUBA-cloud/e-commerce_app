import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/presentation/home/widgets/app_network_image.dart';
import 'package:ecommerce_app/presentation/home/widgets/home_shared.dart';
import 'package:ecommerce_app/services/cart/cart_cubit.dart';
import 'package:ecommerce_app/services/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with UiUtility {
  late CartCubit cartCubit;

  @override
  void initState() {
    super.initState();
    cartCubit = CartCubit.get(context);
    cartCubit.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;

    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartFailed) {
          showSnackBar(context: context, message: state.message ?? 'error'.tr());
        }
      },
      builder: (context, state) {
        final cubit = context.read<CartCubit>();
        final isBusy = state is CartActionLoading;
        final cart = state is CartLoaded
            ? state.cart
            : state is CartActionLoading
            ? state.cart
            : cubit.currentCart;

        // ✅ safe access on nullable data list
        final items = cart?.data?.whereType<CartsDataEntity>().toList() ?? [];

        return Scaffold(
          backgroundColor: c.textField,
          body: SafeArea(
            child: Column(
              children: [
                _header(c, cubit, state),
                Expanded(
                  child: state is CartLoading
                      ? Center(child: CircularProgressIndicator(color: c.main))
                      : items.isNotEmpty
                      ? _cartBody(context, c, cubit, items, isBusy)
                      : _emptyState(c, cubit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(AppColors c, CartCubit cubit, CartState state) {
    final count = cubit.itemCount;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.main, c.sub]),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.shopping_cart_rounded, color: c.buttonText, size: 26.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'my_cart'.tr(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: c.bodyText,
                  ),
                ),
                Text(
                  '$count ${'items'.tr()}',
                  style: TextStyle(fontSize: 12.sp, color: c.hint),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: cubit.loadCart,
            icon: Icon(Icons.refresh_rounded, color: c.main),
          ),
        ],
      ),
    );
  }

  Widget _cartBody(
      BuildContext context,
      AppColors c,
      CartCubit cubit,
      List<CartsDataEntity> items,
      bool isBusy,
      ) {
    return Stack(
      children: [
        RefreshIndicator(
          color: c.main,
          onRefresh: cubit.loadCart,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 200.h),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => _CartItemCard(
              item: items[i],
              colors: c,
              onIncrement: () => cubit.updateQuantity(
                items[i],
                (items[i].quantity ?? 0) + 1,  // ✅ null-safe
              ),
              onDecrement: () {
                final qty = items[i].quantity ?? 0;
                if (qty > 1) {
                  cubit.updateQuantity(items[i], qty - 1);
                } else {
                  cubit.removeItem(items[i].id);
                }
              },
              onDelete: () => cubit.removeItem(items[i].id),
            ),
          ),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
          child: _summaryDock(c, cubit),
        ),
        if (isBusy)
          Positioned.fill(
            child: Container(
              color: c.card.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(color: c.main)),
            ),
          ),
      ],
    );
  }

  Widget _summaryDock(AppColors c, CartCubit cubit) {
    final subtotal = cubit.subtotal;
    const shipping = 0.0;
    final total = subtotal + shipping;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: c.main.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('subtotal'.tr(), subtotal, c),
          SizedBox(height: 6.h),
          _summaryRow('shipping'.tr(), shipping, c, muted: true),
          Divider(height: 20.h, color: c.hint.withOpacity(0.15)),
          _summaryRow('total'.tr(), total, c, bold: true),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.main, c.sub]),
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'checkout'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: c.buttonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      double amount,
      AppColors c, {
        bool bold = false,
        bool muted = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15.sp : 13.sp,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: muted ? c.hint : c.bodyText,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}',
          style: TextStyle(
            fontSize: bold ? 18.sp : 14.sp,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            color: bold ? c.main : c.bodyText,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(AppColors c, CartCubit cubit) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: c.main.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined, size: 48.r, color: c.main),
            ),
            SizedBox(height: 20.h),
            Text(
              'cart_empty'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: c.bodyText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'cart_empty_hint'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: c.hint),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: cubit.loadCart,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// CART ITEM CARD
// ══════════════════════════════════════════════════════════════════════════

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.colors,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final CartsDataEntity item;
  final AppColors colors;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = colors;

    // ✅ all nullable-safe accesses
    final name = localizedEnAr(
      context: context,
      nameEn: item.product?.nameEn ?? '',
      nameAr: item.product?.nameAr ?? '',
    );
    final sizeName = localizedEnAr(
      context: context,
      nameEn: item.size?.nameEn ?? '',
      nameAr: item.size?.nameAr ?? '',
    );
    final unitPrice = double.tryParse(item.product?.price ?? '0') ?? 0;
    final sizeExtra = (item.size?.price ?? 0).toDouble();
    final lineTotal = (unitPrice + sizeExtra) * (item.quantity ?? 0);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28.r),
      ),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: c.hint.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: SizedBox(
                width: 88.r,
                height: 88.r,
                child: AppNetworkImage(
                  url: item.product?.mainImage ?? '',  // ✅ null-safe
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: c.bodyText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$sizeName · ${item.color ?? ''}',  // ✅ null-safe
                    style: TextStyle(fontSize: 11.sp, color: c.hint),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '\$${lineTotal.toStringAsFixed(lineTotal % 1 == 0 ? 0 : 2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: c.main,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close_rounded, size: 20.r, color: c.hint),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: c.textField,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      _qtyBtn(Icons.remove, onDecrement, c),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          '${item.quantity ?? 0}',  // ✅ null-safe
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: c.bodyText,
                          ),
                        ),
                      ),
                      _qtyBtn(Icons.add, onIncrement, c),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, AppColors c) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: c.main.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 16.r, color: c.main),
      ),
    );
  }
}
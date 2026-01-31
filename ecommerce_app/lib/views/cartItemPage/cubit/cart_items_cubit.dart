// lib/views/cart/cubit/cart_cubit.dart

import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/repostery%20/cart_items_repostery.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());

  final _repo = InMemoryCartItemsRepository();

  void intial() {}

  /// تحميل السلة من الريبو
  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final result = await _repo.fetchAll(); // List<CartModel>

      _recompute(
        items: result,
        status: CartStatus.success,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> addItemFromApiResponse(
      CartModel response ) async {
    addItem(response, markAsNew: true);
  }

  /// إضافة/دمج عنصر للسلة
  void addItem(CartModel line, {bool markAsNew = false}) {
    final items = List<CartModel>.from(state.items);
    final idx = items.indexWhere((l) => l.id == line.id);

    if (idx >= 0) {
      // ندمج الكمية + نخليه selected
      final existing = items[idx];
      final merged = existing.copyWith(
        quantity: existing.quantity + line.quantity,
        selected: true,
      );
      items[idx] = merged;
    } else {
      items.add(line.copyWith(selected: true));
    }

    _recompute(
      items: items,
      status:
          markAsNew ? CartStatus.newItemAdded : CartStatus.idle,
    );
  }

  /// حذف عنصر من السلة
  Future<void> removeItem(int id) async {
    final result = await _repo.removeCartItem(id);
    if (result) {
      final items =
          state.items.where((l) => l.id != id).toList(); // ✅ الصحيح
      _recompute(
        items: items,
        status: CartStatus.removeItem,
      );
    }
  }

  Future<void> increaseQuantity(CartModel model) async {
    final newQuantity = model.quantity + 1;
    final ok =
        await _repo.updateQuantity(model.id!, newQuantity);

    if (ok) {
      final items = state.items
          .map((l) => l.id == model.id
              ? l.copyWith(quantity: newQuantity)
              : l)
          .toList();
emit(state.copyWith(cartQuantity: newQuantity));
      _recompute(items: items);
    }
  }

  Future<void> decreaseQuantity(CartModel model) async {
    final newQuantity = model.quantity - 1;

    if (newQuantity >= 1) {
      final ok =
          await _repo.updateQuantity(model.id!, newQuantity);
      if (ok) {
        final items = state.items
            .map((l) => l.id == model.id
                ? l.copyWith(quantity: newQuantity)
                : l)
            .toList();
emit(state.copyWith(cartQuantity: newQuantity));

        _recompute(items: items);
      }
    } else {
      // لو صار 0 نحذفه من السلة
      await removeItem(model.id!);
    }
  }

  /// لو حبيتي تستعمليها من صفحات أخرى لما يكون عندك CartModel جاهز
  void addNewItemFromOtherPages(CartModel model) {
    addItem(model, markAsNew: true);
  }

  void setQuantity(int id, int quantity) {
    final q = quantity.clamp(1, 9999);
    final items = state.items
        .map((l) => l.id == id ? l.copyWith(quantity: q) : l)
        .toList();

    _recompute(items: items);
  }

  void toggleSelect(int id) {
    final items = state.items
        .map((l) =>
            l.id == id ? l.copyWith(selected: !l.selected) : l)
        .toList();
    _recompute(items: items);
  }

  void toggleSelectAll(bool value) {
    final items =
        state.items.map((l) => l.copyWith(selected: value)).toList();
    _recompute(items: items);
  }

  void clear() {
    _recompute(items: <CartModel>[]);
  }

  /// كود بسيط للـ coupon – يتطبّق على subtotal
  void applyCoupon(String code) {
    final discountRate =
        code.trim().toUpperCase() == 'SAVE10' ? 0.10 : 0.0;
    _recompute(customDiscountRate: discountRate);
  }

  // ----- Helpers -----
  void _recompute({
    List<CartModel>? items,
    CartStatus status = CartStatus.idle,
    double? customDiscountRate,
  }) {
    final l = items ?? state.items;
    final sel = l.where((e) => e.selected).toList();

    final subtotal =
        sel.fold<double>(0.0, (p, e) => p + double.parse(e.lineTotal));

    // discount & shipping rules
    final discountRate = customDiscountRate ?? 0.0;
    final discount = subtotal * discountRate;

    final shipping =
        subtotal == 0 ? 0 : (subtotal >= 50 ? 0 : 4.99);

    final total =
        (subtotal - discount + shipping).clamp(0, double.infinity);

    final allSelected =
        l.isNotEmpty && l.every((e) => e.selected);

    emit(
      state.copyWith(
        items: l,
        subtotal: double.parse(subtotal.toStringAsFixed(2)),
        discount: double.parse(discount.toStringAsFixed(2)),
        shipping: double.parse(shipping.toStringAsFixed(2)),
        total: double.parse(total.toStringAsFixed(2)),
        allSelected: allSelected,
        status: status,
        error: null,
      ),
    );
  }
}

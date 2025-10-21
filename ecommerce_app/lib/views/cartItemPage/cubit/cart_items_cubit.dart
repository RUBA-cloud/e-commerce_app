// lib/views/cart/cubit/cart_cubit.dart
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final demo = <CartLine>[
        CartLine(
          id: '1',
          name: 'Classic Hoodie',
          variant: 'Black / L',
          unitPrice: 22.50,
          qty: 1,
          imageUrl: 'https://placehold.co/120x120?text=Hoodie',
        ),
        CartLine(
          id: '2',
          name: 'Sneakers',
          variant: '42 EU',
          unitPrice: 45.90,
          qty: 2,
          imageUrl: 'https://placehold.co/120x120?text=Sneakers',
        ),
      ];
      _recompute(lines: demo, status: CartStatus.idle);
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, error: e.toString()));
    }
  }

  void addLine(CartLine line) {
    final lines = List<CartLine>.from(state.lines);
    final idx = lines.indexWhere((l) => l.id == line.id);
    if (idx >= 0) {
      final merged =
          lines[idx].copyWith(qty: lines[idx].qty + line.qty, selected: true);
      lines[idx] = merged;
    } else {
      lines.add(line.copyWith(selected: true));
    }
    _recompute(lines: lines);
  }

  void removeLine(String id) {
    final lines = state.lines.where((l) => l.id != id).toList();
    _recompute(lines: lines);
  }

  void increaseQty(String id) {
    final lines = state.lines
        .map((l) => l.id == id ? l.copyWith(qty: l.qty + 1) : l)
        .toList();
    _recompute(lines: lines);
  }

  void decreaseQty(String id) {
    final lines = state.lines
        .map(
            (l) => l.id == id ? l.copyWith(qty: (l.qty - 1).clamp(1, 9999)) : l)
        .toList();
    _recompute(lines: lines);
  }

  void setQty(String id, int qty) {
    final q = qty.clamp(1, 9999);
    final lines =
        state.lines.map((l) => l.id == id ? l.copyWith(qty: q) : l).toList();
    _recompute(lines: lines);
  }

  void toggleSelect(String id) {
    final lines = state.lines
        .map((l) => l.id == id ? l.copyWith(selected: !l.selected) : l)
        .toList();
    _recompute(lines: lines);
  }

  void toggleSelectAll(bool value) {
    final lines = state.lines.map((l) => l.copyWith(selected: value)).toList();
    _recompute(lines: lines);
  }

  void clear() {
    _recompute(lines: []);
  }

  // Placeholder for coupon logic; adapt as needed
  void applyCoupon(String code) {
    // simple demo: 10% off if code == SAVE10
    final discountRate = code.trim().toUpperCase() == 'SAVE10' ? 0.10 : 0.0;
    _recompute(customDiscountRate: discountRate);
  }

  // ----- Helpers -----
  void _recompute({
    List<CartLine>? lines,
    CartStatus status = CartStatus.idle,
    double? customDiscountRate,
  }) {
    final l = (lines ?? state.lines);
    final sel = l.where((e) => e.selected).toList();

    final subtotal = sel.fold<double>(0.0, (p, e) => p + e.lineTotal);

    // discount and shipping rules – customize to your business logic
    final discountRate = customDiscountRate ??
        (state.discount > 0
            ? state.discount / (subtotal == 0 ? 1 : subtotal)
            : 0);
    final discount = subtotal * discountRate;

    final shipping = subtotal == 0
        ? 0
        : (subtotal >= 50 ? 0 : 4.99); // free shipping over 50

    final total = (subtotal - discount + shipping).clamp(0, double.infinity);
    final allSelected = l.isNotEmpty && l.every((e) => e.selected);

    emit(state.copyWith(
      lines: l,
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      discount: double.parse(discount.toStringAsFixed(2)),
      shipping: double.parse(shipping.toStringAsFixed(2)),
      total: double.parse(total.toStringAsFixed(2)),
      allSelected: allSelected,
      status: status,
      error: null,
    ));
  }
}

import 'package:ecommerce_app/views/cartItemPage/summary_total_bar/cubit/summary_total_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SummaryBarCubit extends Cubit<SummaryBarState> {
  SummaryBarCubit({
    required double subtotal,
    required double discount,
    required double shipping,
    required double total,
    required bool canCheckout,
  }) : super(SummaryBarState.initial(
          subtotal: subtotal,
          discount: discount,
          shipping: shipping,
          total: total,
          canCheckout: canCheckout,
        ));

  /// If parent cart recomputes totals, push them here
  void setTotals({
    required double subtotal,
    required double discount,
    required double shipping,
    required double total,
    bool? canCheckout,
  }) {
    emit(state.copyWith(
      subtotal: subtotal,
      discount: discount,
      shipping: shipping,
      total: total,
      canCheckout: canCheckout ?? state.canCheckout,
      status: SummaryStatus.idle,
      error: null,
    ));
  }

  void setCanCheckout(bool value) {
    emit(state.copyWith(canCheckout: value));
  }

  void setCouponText(String text) {
    emit(state.copyWith(couponCode: text, status: SummaryStatus.idle, error: null));
  }

  /// Simple example: SAVE10 => 10% off subtotal
  Future<void> applyCoupon() async {
    emit(state.copyWith(status: SummaryStatus.applying, error: null));

    final code = state.couponCode.trim().toUpperCase();
    double rate = 0.0;

    if (code.isEmpty) {
      emit(state.copyWith(status: SummaryStatus.error, error: 'empty_coupon'));
      return;
    }

    if (code == 'SAVE10') {
      rate = 0.10;
    } else {
      // Unknown code
      emit(state.copyWith(status: SummaryStatus.error, error: 'invalid_coupon'));
      return;
    }

    final discount = (state.subtotal * rate);
    final total = (state.subtotal - discount + state.shipping).clamp(0, double.infinity);

    emit(state.copyWith(
      discount: double.parse(discount.toStringAsFixed(2)),
      total: double.parse(total.toStringAsFixed(2)),
      status: SummaryStatus.idle,
      error: null,
    ));
  }
}

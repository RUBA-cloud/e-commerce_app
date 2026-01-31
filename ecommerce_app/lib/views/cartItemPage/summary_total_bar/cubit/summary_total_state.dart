import 'package:equatable/equatable.dart';

enum SummaryStatus { idle, applying, error }

class SummaryBarState extends Equatable {
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final bool canCheckout;

  /// The current coupon text typed by the user
  final String couponCode;

  final SummaryStatus status;
  final String? error;

  const SummaryBarState({
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.canCheckout,
    this.couponCode = '',
    this.status = SummaryStatus.idle,
    this.error,
  });

  factory SummaryBarState.initial({
    double subtotal = 0,
    double discount = 0,
    double shipping = 0,
    double total = 0,
    bool canCheckout = false,
  }) {
    return SummaryBarState(
      subtotal: subtotal,
      discount: discount,
      shipping: shipping,
      total: total,
      canCheckout: canCheckout,
    );
  }

  SummaryBarState copyWith({
    double? subtotal,
    double? discount,
    double? shipping,
    double? total,
    bool? canCheckout,
    String? couponCode,
    SummaryStatus? status,
    String? error,
  }) {
    return SummaryBarState(
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      canCheckout: canCheckout ?? this.canCheckout,
      couponCode: couponCode ?? this.couponCode,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [subtotal, discount, shipping, total, canCheckout, couponCode, status, error];
}

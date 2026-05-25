import 'dart:ui';

class PromoSlideData {
  const PromoSlideData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.discount,
    required this.gradient,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String discount;
  final List<Color> gradient;
}
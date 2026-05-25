import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Soft gradient blobs for background depth.
class HomeBackgroundDecor extends StatelessWidget {
  const HomeBackgroundDecor({super.key, required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60.h,
            right: -40.w,
            child: _Blob(color: colors.main.withOpacity(0.14), size: 180.r),
          ),
          Positioned(
            top: 120.h,
            left: -70.w,
            child: _Blob(color: colors.sub.withOpacity(0.10), size: 140.r),
          ),
          Positioned(
            bottom: 80.h,
            right: -20.w,
            child: _Blob(color: colors.button.withOpacity(0.08), size: 100.r),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    required this.colors,
    this.radius,
    this.padding,
    this.borderColor,
  });

  final Widget child;
  final AppColors colors;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card.withOpacity(0.88),
        borderRadius: BorderRadius.circular(radius ?? 16.r),
        border: Border.all(
          color: borderColor ?? colors.card.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.main.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}



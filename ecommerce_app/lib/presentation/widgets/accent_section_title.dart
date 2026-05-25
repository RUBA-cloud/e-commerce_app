import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccentSectionTitle extends StatelessWidget {
  const AccentSectionTitle({
    super.key,
    required this.title,
    required this.accentColor,
    this.subtitle,
    this.onSeeAll,
    this.seeAllLabel,
    this.accentSecondaryColor,
  });

  final String title;
  final String? subtitle;
  final Color accentColor;
  final Color? accentSecondaryColor;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = accentSecondaryColor ?? accentColor.withOpacity(0.6);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Accent bar ───────────────────────────────────────
          Container(
            width: 4.w,
            height: subtitle != null ? 32.h : 22.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accentColor, secondaryColor],
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 10.w),

          // ── Title + subtitle ─────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── See all pill ─────────────────────────────────────
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seeAllLabel ?? 'See all',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12.r,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
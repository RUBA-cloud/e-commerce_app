import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/core/utility/image_url_helper.dart';
import 'package:ecommerce_app/data/model/response/brand_entity.dart';
import 'package:ecommerce_app/presentation/home/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String localizedEnAr({
  required BuildContext context,
  required String nameEn,
  required String nameAr,
}) {
  if (context.locale.languageCode == 'ar' && nameAr.isNotEmpty) {
    return nameAr;
  }
  return nameEn;
}

Widget brandNetworkImage(BrandDataDataEntity brand, AppColors c) {
  final url = brandImageUrl(
    imageUrl: brand.imageUrl,
    image: brand.image,

  );
  return AppNetworkImage(
    url: url,
    fit: BoxFit.contain,
    placeholder: _BrandPlaceholder(c: c),
  );
}

class SeeAllScaffold extends StatelessWidget {
  const SeeAllScaffold({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
  });

  final String title;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Scaffold(
      backgroundColor: c.textField,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200.r,
              height: 200.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.main.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            children: [
              _ModernAppBar(title: title, colors: c),
              Expanded(child: child),
            ],
          ),
        ],
      ),
      bottomNavigationBar: bottom,
    );
  }
}

class _ModernAppBar extends StatelessWidget {
  const _ModernAppBar({required this.title, required this.colors});
  final String title;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, MediaQuery.paddingOf(context).top + 4.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: [
          BoxShadow(
            color: colors.hint.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: colors.textField,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16.r, color: colors.bodyText),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: colors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandPlaceholder extends StatelessWidget {
  const _BrandPlaceholder({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: c.textField,
      alignment: Alignment.center,
      child: Icon(Icons.storefront_rounded, size: 28.r, color: c.hint),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/constants/shared_decorations.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProductWidgetDesign extends StatelessWidget {
  final ProductModel p;

  const ProductWidgetDesign({
    super.key,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    final isArabic = Get.locale?.languageCode == 'ar';
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final title = (isArabic ? p.nameAr : p.nameEn);
    final priceText = '${p.price} JD';

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) => prev.favoriteProductIds != curr.favoriteProductIds,
      builder: (context, state) {
        final isFav = state.favoriteProductIds.contains(p.id);

        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => homeCubit.goToDetailsPage(p, context),
          child: Container(
           
            decoration: setBoxDecoration(
              color:redColor,
              radius: 22,
              
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // ====== IMAGE CARD (like first page) ======
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        
              child: AspectRatio(
                    
                    aspectRatio: 1.05,
                    child: Stack(
                      children: [
                        // image container
                        Positioned.fill(
                          child: Container(
                            decoration: setBoxDecoration(
                              // light background behind image like mock
                              color: cs.surfaceContainerHighest.withOpacity(0.35),
                              radius: 18,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: networkImageOrPlaceholder(
                              context: context,
                              url: p.mainImage,
                            ),
                          ),
                        ),

                        // ❤️ Fav (top corner)
                        Positioned(
                          top: 10,
                          right: isArabic ? null : 10,
                          left: isArabic ? 10 : null,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => homeCubit.toggleFavorite(p, context),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: setBoxDecoration(
                               
                                color: cs.surface.withOpacity(0.92),
                                radius: 999,
                                border: Border.all(
                                  
                                  color: cs.outline.withOpacity(0.10),
                                ),
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isFav ? redColor : cs.onSurface.withOpacity(0.55),
                              ),
                            ),
                          ),
                        ),

                        // ➕ Add (bottom corner)
                    
                      ],
                    ),
                  ),
                ),

                // ====== TEXT AREA ======
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12,5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1,
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                  
                  
                        Expanded(flex: 1,
                          child: Text(
                            priceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                          
                          Expanded(flex: 2,
                            child: Align(alignment: isArabic?Alignment.bottomLeft:Alignment.bottomRight,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    // اربطيها بدالة الكارت عندك
                                   homeCubit.goToDetailsPage(p, context);
                                  },
                                  child: Container(
                                    width: 44,
                                  
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: setBoxDecoration(
                                      color: redColor,
                                      radius: 14,
                                      boxShadow: [
                                        BoxShadow(
                                          color: blackColor.withOpacity(0.18),
                                          blurRadius: 14,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.add, color: whiteColor, size: 22),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget networkImageOrPlaceholder({
    required BuildContext context,
    String? url,
  }) {
    final cs = Theme.of(context).colorScheme;

    if (url == null || url.isEmpty) {
      return Center(
        child: Icon(
          Icons.image_outlined,
          size: 44,
          color: cs.outline,
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: cs.surfaceContainerHighest.withOpacity(0.30),
        child: const Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );
  }
}

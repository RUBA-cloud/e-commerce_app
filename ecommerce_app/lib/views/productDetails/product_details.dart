// lib/views/product/product_details_view.dart

import 'package:ecommerce_app/components/color_section.dart';
import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/constants/shared_decorations.dart';
import 'package:ecommerce_app/models/additional_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/product_size.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_state.dart';
import 'package:ecommerce_app/views/productDetails/cubit/product_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    // ✅ Safety: ensure we actually got a ProductModel
    if (args is! ProductModel) {
      return Scaffold(
        appBar: AppBar(title: Text('product_details_title'.tr)),
        body: Center(child: Text('product_details_missing_product'.tr)),
      );
    }

    final ProductModel product = args;
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return BlocProvider<ProductDetailsCubit>(
      create: (_) => ProductDetailsCubit(product: product, isArabic: isArabic),
      child: BlocConsumer<ProductDetailsCubit, HomeState>(
        listenWhen: (prev, curr) =>prev.message != curr.message && curr.additonals !=prev.additonals,
        listener: (context, state) {
          Fluttertoast.showToast(msg: state.additonals!.toString());
        debugPrint(state.additonals.toString());
        
          // optional: show toast/snackbar for messages
          
          
        },
        builder: (context, state) {
          final currentProduct = product;
          final isArabic = state.isArabic;

          final title = isArabic ? currentProduct.nameAr : currentProduct.nameEn;
          final description = isArabic
              ? currentProduct.descriptionAr
              : currentProduct.descriptionEn;

          final additionals = currentProduct.productsAdditonal ?? const <AdditionalModel>[];

          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'product_details_title'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          productImagesSection(
                            context: context,
                            mainImage: currentProduct.mainImage,
                            images: currentProduct.productImages,
                            isFavorite: state.isFavorite,
                            onToggleFavorite: () {
                              context
                                  .read<ProductDetailsCubit>()
                                  .toggleFavorite(currentProduct, context);
                            },
                          ),
                          const SizedBox(height: 16),

                          productHeaderSection(
                            context: context,
                            title: title,
                            price: currentProduct.price,
                            isActive: currentProduct.isActive,
                          ),
                          const SizedBox(height: 12),

                          // COLORS (with selection)
                          if (currentProduct.colors.isNotEmpty) ...[
                            ColorSection(
                              colors: currentProduct.colors,
                              selectedColor: state.selectedColor,
                              onSelect: (c) => context.read<ProductDetailsCubit>().selectColor(c),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // SIZES (with selection)
                          if (currentProduct.sizes.isNotEmpty) ...[
                            productSizesSection(
                              context: context,
                              sizes: currentProduct.sizes.toList(),
                              selectedSize: state.selectedSize,
                              onSelect: (s) => context.read<ProductDetailsCubit>().selectSize(s),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // ADDITIONALS (with selection)
                          if (additionals.isNotEmpty) ...[
                            productAdditionalsSection(
                              context: context,
                              additionals: additionals,
                              onSelect: (id) => context.read<ProductDetailsCubit>().selectAdditonal(id),
                            ),
                            const SizedBox(height: 16),
                          ],

                          productDescriptionSection(
                            context: context,
                            description: description,
                          ),
                          const SizedBox(height: 16),

                          metaInfoSection(
                            context: context,
                            product: currentProduct,
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  bottomActionBar(
                    context: context,
                    price: currentProduct.price,
                    onAddToCart: () => context.read<ProductDetailsCubit>().addToCart(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =======================
// Functions instead of widgets
// =======================

Widget productImagesSection({
  required BuildContext context,
  required String? mainImage,
  required List<String> images,
  required bool isFavorite,
  required VoidCallback onToggleFavorite,
}) {
  final hasImages = (mainImage != null && mainImage.isNotEmpty) || images.isNotEmpty;

  if (!hasImages) {
    return Container(
      height: 220,
      decoration: setBoxDecoration(color: Colors.white),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  final List<String> allImages = [];
  if (mainImage != null && mainImage.isNotEmpty) {
    allImages.add(mainImage);
  }
  allImages.addAll(images);

  return Container(
    height: 260,
    decoration: setBoxDecoration(color: redColor),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        PageView.builder(
          itemCount: allImages.length,
          itemBuilder: (context, index) {
            final url = allImages[index];
            return InkWell(
              onTap: () {},
              child: Hero(
                tag: 'product_image_${url}_$index',
                child: Image.network(
                  url,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: grayColor,
                    size: 40,
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 12,
          right: 12,
          left: 12,
          child: imageOverlayBar(
            context: context,
            count: allImages.length,
            isFavorite: isFavorite,
            onToggleFavorite: onToggleFavorite,
          ),
        ),
      ],
    ),
  );
}

Widget imageOverlayBar({
  required BuildContext context,
  required int count,
  required bool isFavorite,
  required VoidCallback onToggleFavorite,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: blackColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined, size: 16, color: whiteColor),
            const SizedBox(width: 4),
            Text('$count', style: setTextStyle(fontSize: 12, color: whiteColor)),
          ],
        ),
      ),
      const Spacer(),
      InkWell(
        onTap: onToggleFavorite,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 34,
          height: 34,
          // ignore: deprecated_member_use
          decoration: setBoxDecoration(color: blackColor.withOpacity(0.55), radius: 12),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.white,
            size: 20,
          ),
        ),
      ),
    ],
  );
}

Widget productHeaderSection({
  required BuildContext context,
  required String title,
  required String price,
  required bool isActive,
}) {
  final theme = Theme.of(context);
  final priceText = '$price ${'currency_symbol'.tr}';

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          blurRadius: 12,
          offset: const Offset(0, 6),
          // ignore: deprecated_member_use
          color: blackColor.withOpacity(0.04),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? 'product_no_name'.tr : title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: isActive ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isActive ? 'product_status_active'.tr : 'product_status_inactive'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              priceText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'price_label_per_unit'.tr,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget productSizesSection({
  required BuildContext context,
  required List<ProductSize> sizes,
  required int? selectedSize,
  required ValueChanged<int> onSelect,
}) {
  final isArabic = Get.locale?.languageCode == 'ar';

  return sectionCard(
    context: context,
    title: 'product_sizes_title'.tr,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((s) {
        final bool isSelected = selectedSize == s.id;

        return ChoiceChip(
          label: Text(isArabic ? s.nameAr : s.nameEn),
          selected: isSelected,
          onSelected: (_) => onSelect(s.id),
          // ignore: deprecated_member_use
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
          labelStyle: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    ),
  );
}

Widget productAdditionalsSection({
  required BuildContext context,
  required List<AdditionalModel> additionals,
  required ValueChanged<int> onSelect,
}) {
  final isArabic = Get.locale?.languageCode == 'ar';
          final cubit = context.watch<ProductDetailsCubit>();

  return sectionCard(
    context: context,
    title: 'product_additionals_title'.tr,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: additionals.map((a) {
        final id = a.id;
        final bool isSelected = cubit.state.additonals?.contains(id) ?? false;

    return ChoiceChip(
          label: Text(isArabic ? (a.nameAr ?? '-') : (a.nameEn ?? '-')),
          selected: isSelected,
          onSelected: (_) {
            if (id != null) onSelect(id);
          },
          // ignore: deprecated_member_use
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
          labelStyle: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    ),
  );
}

Widget productDescriptionSection({
  required BuildContext context,
  required String description,
}) {
  return sectionCard(
    context: context,
    title: 'product_description_title'.tr,
    child: Text(
      description.isEmpty ? 'product_no_description'.tr : description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
    ),
  );
}

Widget metaInfoSection({
  required BuildContext context,
  required ProductModel product,
}) {
  final created = product.createdAt;
  final updated = product.updatedAt;

  String formatDate(DateTime? dt) {
    if (dt == null) return '--';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  return sectionCard(
    context: context,
    title: 'product_meta_title'.tr,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        metaRow(context: context, label: 'product_created_at'.tr, value: formatDate(created)),
        const SizedBox(height: 4),
        metaRow(context: context, label: 'product_updated_at'.tr, value: formatDate(updated)),
        const SizedBox(height: 4),
        metaRow(context: context, label: 'product_category_id'.tr, value: product.categoryId.toString()),
        if (product.typeId != null) ...[
          const SizedBox(height: 4),
          metaRow(context: context, label: 'product_type_id'.tr, value: product.typeId.toString()),
        ],
      ],
    ),
  );
}

Widget metaRow({
  required BuildContext context,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      Text(
        '$label: ',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      Expanded(
        child: Text(value, style: Theme.of(context).textTheme.bodySmall),
      ),
    ],
  );
}

Widget sectionCard({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          offset: const Offset(0, 4),
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.03),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

Widget bottomActionBar({
  required BuildContext context,
  required String price,
  required VoidCallback onAddToCart,
}) {
  final theme = Theme.of(context);
  final priceText = '$price ${'currency_symbol'.tr}';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: theme.cardColor,
      boxShadow: [
        BoxShadow(
          blurRadius: 12,
          offset: const Offset(0, -4),
          // ignore: deprecated_member_use
          color: blackColor.withOpacity(0.06),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('total_label'.tr, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(
                priceText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onAddToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: Text('add_to_cart_button'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}

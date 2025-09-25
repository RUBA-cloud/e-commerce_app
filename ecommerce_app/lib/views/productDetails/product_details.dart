// lib/views/product_details/product_details_page.dart

import 'package:ecommerce_app/views/productDetails/cubit/product_details_cubit.dart';
import 'package:ecommerce_app/views/productDetails/cubit/product_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';

    return BlocProvider(
      create: (_) => ProductDetailsCubit(productId: productId)..load(),
      child: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
        listenWhen: (p, n) =>
            p.status != n.status && n.status == ProductDetailsStatus.loaded,
        listener: (ctx, _) {},
        builder: (context, state) {
          switch (state.status) {
            case ProductDetailsStatus.loading:
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            case ProductDetailsStatus.error:
              return Scaffold(
                appBar: AppBar(title: Text('product_details'.tr)),
                body: _ErrorView(
                  message: state.error ?? 'error'.tr,
                  onRetry: () => context.read<ProductDetailsCubit>().load(),
                ),
              );
            case ProductDetailsStatus.loaded:
            case ProductDetailsStatus.addingToCart:
              final p = state.product!;
              final theme = Theme.of(context);

              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    _GalleryAppBar(
                      images: p.images,
                      heroPrefix: p.id,
                      selected: state.selectedImage,
                      onSelect: (i) =>
                          context.read<ProductDetailsCubit>().selectImage(i),
                      isFavorite: state.isFavorite,
                      onToggleFavorite: () =>
                          context.read<ProductDetailsCubit>().toggleFavorite(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                        child: Column(
                          crossAxisAlignment: isAr
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Title + brand
                            Text(
                              p.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign:
                                  isAr ? TextAlign.right : TextAlign.left,
                            ),
                            if (p.brand != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                p.brand!,
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(color: theme.hintColor),
                              ),
                            ],
                            const SizedBox(height: 8),

                            // Rating + reviews
                            Row(
                              children: [
                                _Stars(rating: p.rating),
                                const SizedBox(width: 8),
                                Text('${p.rating.toStringAsFixed(1)} '
                                    '(${p.reviewsCount})'),
                                const Spacer(),
                                _PriceTag(price: p.price, oldPrice: p.oldPrice),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Color picker
                            if (p.colors.isNotEmpty) ...[
                              _SectionLabel('color'.tr),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: p.colors.map((hex) {
                                  final selected = state.selectedColor == hex;
                                  return _ColorDot(
                                    color: Color(hex),
                                    selected: selected,
                                    onTap: () => context
                                        .read<ProductDetailsCubit>()
                                        .selectColor(hex),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Size picker
                            if (p.sizes.isNotEmpty) ...[
                              _SectionLabel('size'.tr),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: p.sizes.map((s) {
                                  final selected = state.selectedSize == s;
                                  return ChoiceChip(
                                    label: Text(s),
                                    selected: selected,
                                    onSelected: (_) => context
                                        .read<ProductDetailsCubit>()
                                        .selectSize(s),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Qty
                            _SectionLabel('quantity'.tr),
                            const SizedBox(height: 8),
                            _QtyStepper(
                              qty: state.qty,
                              onMinus:
                                  context.read<ProductDetailsCubit>().decQty,
                              onPlus:
                                  context.read<ProductDetailsCubit>().incQty,
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _SectionLabel('description'.tr),
                            const SizedBox(height: 6),
                            _ExpandableText(
                              text: p.description,
                              expanded: state.expandedDesc,
                              onToggle: () => context
                                  .read<ProductDetailsCubit>()
                                  .toggleDesc(),
                            ),
                            const SizedBox(height: 16),

                            // Specs
                            if (p.specs.isNotEmpty) ...[
                              _SectionLabel('specs'.tr),
                              const SizedBox(height: 8),
                              _SpecsGrid(specs: p.specs),
                            ],

                            // (Optional) Recommendations / Reviews entry points can go here
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Sticky bottom
                bottomNavigationBar: _BottomBar(
                  price: p.price,
                  inStock: p.inStock,
                  adding: state.status == ProductDetailsStatus.addingToCart,
                  onAdd: () async {
                    await context.read<ProductDetailsCubit>().addToCart();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('added_to_cart'.tr)),
                      );
                    }
                  },
                  onBuy: () {
                    // TODO: Navigate to checkout flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('proceed_checkout'.tr)),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

// ---------- AppBar with gallery ----------
class _GalleryAppBar extends StatefulWidget {
  final List<String> images;
  final String heroPrefix;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _GalleryAppBar({
    required this.images,
    required this.heroPrefix,
    required this.selected,
    required this.onSelect,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<_GalleryAppBar> createState() => _GalleryAppBarState();
}

class _GalleryAppBarState extends State<_GalleryAppBar> {
  late final PageController _pc;

  @override
  void initState() {
    super.initState();
    _pc = PageController(initialPage: widget.selected);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 360,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      actions: [
        IconButton(
          onPressed: widget.onToggleFavorite,
          icon: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavorite ? Colors.red : null,
          ),
          tooltip: 'wishlist'.tr,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pc,
              onPageChanged: widget.onSelect,
              itemCount: widget.images.length,
              itemBuilder: (_, i) => Hero(
                tag: '${widget.heroPrefix}_img_$i',
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(.7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: _Dots(
                      count: widget.images.length,
                      index: widget.selected,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Widgets ----------
class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 10 : 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                active ? Theme.of(context).colorScheme.primary : Colors.black26,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full) return const Icon(Icons.star, size: 18);
        if (i == full && half) return const Icon(Icons.star_half, size: 18);
        return const Icon(Icons.star_border, size: 18);
      }),
    );
  }
}

class _PriceTag extends StatelessWidget {
  final double price;
  final double? oldPrice;
  const _PriceTag({required this.price, this.oldPrice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (oldPrice != null) ...[
          Text(
            _money(oldPrice!),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          _money(price),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  String _money(double v) => v.toStringAsFixed(2);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      );
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot(
      {required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: selected ? Theme.of(context).colorScheme.primary : Colors.black12,
      width: selected ? 2 : 1,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border,
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _QtyStepper(
      {required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('$qty', style: theme.textTheme.titleSmall),
          ),
          _StepBtn(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18),
        ),
      );
}

class _ExpandableText extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  const _ExpandableText(
      {required this.text, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxLines = expanded ? 100 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onToggle,
          child: Text(expanded ? 'show_less'.tr : 'show_more'.tr),
        ),
      ],
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final Map<String, String> specs;
  const _SpecsGrid({required this.specs});

  @override
  Widget build(BuildContext context) {
    final entries = specs.entries.toList();
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 64,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final e = entries[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 6),
              Text(e.value, style: theme.textTheme.bodyMedium),
            ],
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double price;
  final bool inStock;
  final bool adding;
  final VoidCallback onAdd;
  final VoidCallback onBuy;

  const _BottomBar({
    required this.price,
    required this.inStock,
    required this.adding,
    required this.onAdd,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('price'.tr, style: theme.textTheme.labelSmall),
                Text(price.toStringAsFixed(2),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: inStock && !adding ? onAdd : null,
              child: adding
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('add_to_cart'.tr),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: inStock ? onBuy : null,
              child: Text('buy_now'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('failed_to_load'.tr,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr),
              ),
            ],
          ),
        ),
      );
}

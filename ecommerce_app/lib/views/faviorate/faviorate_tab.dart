import 'package:ecommerce_app/components/basic_search.dart';
import 'package:ecommerce_app/components/empty_widget.dart';
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/models/faviorate.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_cubit.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: BlocConsumer<FavoriteCubit, FavoriteState>(
        // متى نسمع في الـ listener؟
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {

        
        },

        // متى نعيد بناء الصفحة؟
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.items != curr.items ||
            prev.sort != curr.sort ||
            prev.viewMode != curr.viewMode,
        builder: (context, state) {
          final cubit = context.read<FavoriteCubit>();
          final hasItems = state.items != null && state.items!.isNotEmpty;

          return Scaffold(
            appBar: AppBar(
              title: Text('favorites'.tr),
              actions: [
                IconButton(
                  tooltip: 'clear_all'.tr,
                  // ❗ تعطيل زر الحذف لما ما في عناصر
                  onPressed: hasItems
                      ? () => _confirmClearAll(context, cubit)
                      : null,
                  icon: const Icon(Icons.delete_sweep),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: BasicSearchBar(
                    onChanged: (s) => cubit.search(s),
                  ),
                ),
              ),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FavoriteState state) {
    // حالة التحميل
    if (state.status == FavoriteStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // حالة الخطأ
    if (state.status == FavoriteStatus.failure) {
      return Center(child: Text('${'error'.tr}: ${state.error}'));
    }

    final hasItems = state.items != null && state.items!.isNotEmpty;

    // حالة لا يوجد عناصر
    if (!hasItems) {
      return Center(
        child: EmptyWidget(
          iconData: Icons.favorite_border,
          titleText: 'no_favorites_yet'.tr,
        ),
      );
    }

    // حالة يوجد عناصر
    return Column(
      children: [
        toolBar(context),
        Expanded(
          child: favoritesBody(context),
        ),
      ],
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    FavoriteCubit cubit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('clear_all_title'.tr),
        content: Text('clear_all_desc'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('clear'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      cubit.clearAll();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cleared_success'.tr)),
      );
    }
  }
}

/* ------------------------------ Top-level widgets ------------------------------ */

Widget toolBar(BuildContext context) {
  final theme = Theme.of(context);

  return BlocBuilder<FavoriteCubit, FavoriteState>(
    buildWhen: (p, n) =>
        p.sort != n.sort ||
        p.viewMode != n.viewMode ||
        (p.items?.length ?? 0) != (n.items?.length ?? 0),
    builder: (context, state) {
      final cubit = context.read<FavoriteCubit>();
      final hasItems = state.items != null && state.items!.isNotEmpty;

      // ✅ لو الـ list فاضية أو تم مسحها، لا تعرض التولبار
      if (!hasItems) {
        return const SizedBox.shrink();
      }

      return Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded( flex: 5,
              child: SegmentedButton<FavoriteViewMode>(
                segments: [
                  ButtonSegment(
                    value: FavoriteViewMode.grid,
                    icon: const Icon(Icons.grid_view),
                    label: Text('grid'.tr),
                  ),
                  ButtonSegment(
                    value: FavoriteViewMode.list,
                    icon: const Icon(Icons.view_list),
                    label: Text('list'.tr),
                  ),
                ],
                selected: {state.viewMode},
                onSelectionChanged: (sel) => cubit.setView(sel.first),
                showSelectedIcon: false,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<FavoriteSort>(
              tooltip: 'sort'.tr,
              initialValue: state.sort,
              onSelected: cubit.setSort,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: FavoriteSort.newest,
                  child: Text('sort_newest'.tr),
                ),
                PopupMenuItem(
                  value: FavoriteSort.priceAsc,
                  child: Text('sort_price_asc'.tr),
                ),
                PopupMenuItem(
                  value: FavoriteSort.priceDesc,
                  child: Text('sort_price_desc'.tr),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.surfaceContainerHighest
                      // ignore: deprecated_member_use
                      .withOpacity(0.7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _sortLabel(state.sort).tr,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _sortLabel(FavoriteSort sort) {
  switch (sort) {
    case FavoriteSort.newest:
      return 'sort_newest';
    case FavoriteSort.priceAsc:
      return 'sort_price_asc';
    case FavoriteSort.priceDesc:
      return 'sort_price_desc';
  }
}

Widget favoritesBody(BuildContext context) {
  return BlocBuilder<FavoriteCubit, FavoriteState>(
    builder: (context, state) {
      final items = state.items ?? <FavoriteItem>[];

      if (items.isEmpty) {
        // في حالة حصل تحديث غريب، نرجع ويدجت فاضية
        return const SizedBox.shrink();
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: state.viewMode == FavoriteViewMode.grid
            ? gridView(context, items)
            : listView(items: items),
      );
    },
  );
}

Widget gridView(BuildContext context, List<FavoriteItem> items) {
  final width = MediaQuery.sizeOf(context).width;
  final cross = width > 900
      ? 4
      : width > 700
          ? 3
          : 2;

  return GridView.builder(
    padding: const EdgeInsets.all(12),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cross,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: .78,
    ),
    itemCount: items.length,
    itemBuilder: (_, i) => favCard(item: items[i], context: context),
  );
}

Widget listView({required List<FavoriteItem> items}) => ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, i) => favTile(item: items[i], context: context),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: items.length,
    );

Widget favCard({required FavoriteItem item, required BuildContext context}) {
  final cubit = context.read<FavoriteCubit>();
  final theme = Theme.of(context);
  final product = item.product;
  final imageUrl = product.mainImage ?? '';

  final currency = 'currency_symbol'.tr.isEmpty
      ? 'JOD'
      : 'currency_symbol'.tr;

  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      // Get.toNamed(AppRoutes.details, arguments: product);
    },
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 8,
            child: imageUrl.isNotEmpty
                ? Ink.image(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : Container(
                    // ignore: deprecated_member_use
                    color: theme.colorScheme.surfaceContainerHighest
                        // ignore: deprecated_member_use
                        .withOpacity(.4),
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.nameAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: theme.colorScheme.onSurface.withOpacity(.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${product.price} $currency',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor:
                            // ignore: deprecated_member_use
                            theme.colorScheme.errorContainer
                                // ignore: deprecated_member_use
                                .withOpacity(.2),
                      ),
                      onPressed: () => cubit.remove(item,context),
                      icon: Icon(
                        Icons.favorite,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget favTile({required FavoriteItem item, required BuildContext context}) {
  final cubit = context.read<FavoriteCubit>();
  final theme = Theme.of(context);
  final product = item.product;
  final imageUrl = product.mainImage ?? '';

  final currency = 'currency_symbol'.tr.isEmpty
      ? 'JOD'
      : 'currency_symbol'.tr;

  return Dismissible(
    key: ValueKey(item.id),
    background: Container(
      // ignore: deprecated_member_use
      color: theme.colorScheme.errorContainer.withOpacity(.4),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.delete),
          SizedBox(width: 6),
        ],
      ),
    ),
    secondaryBackground: Container(
      height: 100,
      // ignore: deprecated_member_use
      color: theme.colorScheme.errorContainer.withOpacity(.4),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:           const Icon(Icons.delete),
  
      
    ),
    confirmDismiss: (_) async {
      cubit.remove(item,context);
      return true;
    },
    child: Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () {
           Get.toNamed(AppRoutes.details, arguments: product);
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 64,
                  height: 64,
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.surfaceContainerHighest
                      // ignore: deprecated_member_use
                      .withOpacity(0.4),
                  child: const Icon(Icons.image),
                ),
        ),
        title: Text(
          product.nameEn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          product.nameAr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                '${product.price} $currency',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: IconButton(
                onPressed: () => cubit.remove(item,context),
                icon: Icon(
                  Icons.favorite,
                  color: theme.colorScheme.error,
                ),
                
                
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

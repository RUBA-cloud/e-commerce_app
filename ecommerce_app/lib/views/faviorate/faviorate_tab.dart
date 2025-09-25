import 'package:ecommerce_app/models/faviorate.dart';
import 'package:ecommerce_app/repostery%20/faviorate_repostery.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_cubit.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoriteCubit(InMemoryFavoriteRepository())..load(),
      child: const _FavoriteScaffold(),
    );
  }
}

class _FavoriteScaffold extends StatelessWidget {
  const _FavoriteScaffold();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoriteCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr),
        actions: [
          IconButton(
            tooltip: 'clear_all'.tr,
            onPressed: () => _confirmClearAll(context),
            icon: const Icon(Icons.delete_sweep),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: _SearchBar(onChanged: cubit.setQuery),
          ),
        ),
      ),
      body: Column(
        children: const [
          _Toolbar(),
          Expanded(child: _Body()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final id = DateTime.now().millisecondsSinceEpoch.toString();
          cubit.add(FavoriteItem(
            id: id,
            nameEn: 'demo_apartment'.trParams({'id': id}),
            nameAr: 'demo_apartment_ar'.trParams({'id': id}),
            imageUrl: 'https://picsum.photos/seed/$id/400/300',
            price: (50 + (id.hashCode % 450)).toDouble(),
          ));
        },
        icon: const Icon(Icons.favorite),
        label: Text('add_demo'.tr),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('clear_all_title'.tr),
        content: Text('clear_all_desc'.tr),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text('cancel'.tr)),
          FilledButton(
              onPressed: () => Navigator.pop(c, true), child: Text('clear'.tr)),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      buildWhen: (p, n) =>
          p.sort != n.sort ||
          p.viewMode != n.viewMode ||
          p.items.length != n.items.length,
      builder: (context, state) {
        final cubit = context.read<FavoriteCubit>();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SegmentedButton<FavoriteViewMode>(
                segments: [
                  ButtonSegment(
                      value: FavoriteViewMode.grid,
                      icon: const Icon(Icons.grid_view),
                      label: Text('grid'.tr)),
                  ButtonSegment(
                      value: FavoriteViewMode.list,
                      icon: const Icon(Icons.view_list),
                      label: Text('list'.tr)),
                ],
                selected: {state.viewMode},
                onSelectionChanged: (sel) => cubit.setView(sel.first),
              ),
              const Spacer(),
              PopupMenuButton<FavoriteSort>(
                tooltip: 'sort'.tr,
                initialValue: state.sort,
                onSelected: cubit.setSort,
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: FavoriteSort.newest,
                      child: Text('sort_newest'.tr)),
                  PopupMenuItem(
                      value: FavoriteSort.priceAsc,
                      child: Text('sort_price_asc'.tr)),
                  PopupMenuItem(
                      value: FavoriteSort.priceDesc,
                      child: Text('sort_price_desc'.tr)),
                ],
                child: Row(
                  children: [
                    const Icon(Icons.sort),
                    const SizedBox(width: 6),
                    Text(_sortLabel(state.sort).tr),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _sortLabel(FavoriteSort s) {
    switch (s) {
      case FavoriteSort.priceAsc:
        return 'sort_price_asc';
      case FavoriteSort.priceDesc:
        return 'sort_price_desc';
      case FavoriteSort.newest:
        return 'sort_newest';
    }
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      builder: (context, state) {
        if (state.status == FavoriteStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == FavoriteStatus.failure) {
          return Center(child: Text('${'error'.tr}: ${state.error}'));
        }
        final list = state.visible;
        if (list.isEmpty) {
          return const _EmptyState();
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state.viewMode == FavoriteViewMode.grid
              ? _GridView(items: list)
              : _ListView(items: list),
        );
      },
    );
  }
}

class _GridView extends StatelessWidget {
  final List<FavoriteItem> items;
  const _GridView({required this.items});

  @override
  Widget build(BuildContext context) {
    final cross = MediaQuery.sizeOf(context).width > 700 ? 3 : 2;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .78,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _FavCard(item: items[i]),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<FavoriteItem> items;
  const _ListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, i) => _FavTile(item: items[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: items.length,
    );
  }
}

class _FavCard extends StatelessWidget {
  final FavoriteItem item;
  const _FavCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoriteCubit>();
    return InkWell(
      onTap: () {
        // open details with Get.toNamed('/details', arguments: item.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // ignore: deprecated_member_use
            BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(.06))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 11,
              child: Ink.image(
                image: NetworkImage(item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nameEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.nameAr,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('\$${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: () => cubit.remove(item.id),
                        icon: const Icon(Icons.favorite),
                        tooltip: 'remove'.tr,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavTile extends StatelessWidget {
  final FavoriteItem item;
  const _FavTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoriteCubit>();
    return Dismissible(
      key: ValueKey(item.id),
      background: Container(
        // ignore: deprecated_member_use
        color: Colors.red.withOpacity(.12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          const Icon(Icons.delete),
          const SizedBox(width: 6),
          Text('remove'.tr)
        ]),
      ),
      secondaryBackground: Container(
        // ignore: deprecated_member_use
        color: Colors.red.withOpacity(.12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('remove'.tr),
          const SizedBox(width: 6),
          const Icon(Icons.delete)
        ]),
      ),
      confirmDismiss: (_) async {
        cubit.remove(item.id);
        return true;
      },
      child: ListTile(
        onTap: () {/* open details */},
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(item.imageUrl,
              width: 64, height: 64, fit: BoxFit.cover),
        ),
        title: Text(item.nameEn, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle:
            Text(item.nameAr, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${item.price.toStringAsFixed(0)}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () => cubit.remove(item.id),
              icon: const Icon(Icons.favorite),
              label: Text('remove'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'search_favorites'.tr,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('no_favorites'.tr,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('add_favorites_hint'.tr,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

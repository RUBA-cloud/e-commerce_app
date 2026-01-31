import 'package:ecommerce_app/components/basic_widget.dart';
import 'package:ecommerce_app/views/cartItemPage/cubit/cart_items_cubit.dart';
import 'package:ecommerce_app/views/faviorate/cubit/faviorate_cubit.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_cubit.dart';
import 'package:ecommerce_app/views/home/cubit%20/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:ecommerce_app/views/cartItemPage/cart_items.dart';
import 'package:ecommerce_app/views/faviorate/faviorate_tab.dart';
import 'package:ecommerce_app/views/home/home_tab.dart';
import 'package:ecommerce_app/views/home/more_tab.dart';

/// Root tabs shell
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // نسمع لتغيّر السلة و نبلغ الـ HomeCubit
        BlocListener<CartCubit, dynamic>(
          listenWhen: (prev, curr) =>
              (prev.items?.length ?? 0) != (curr.items?.length ?? 0),
          listener: (context, cartState) {
            final int len = cartState.items?.length ?? 0;
            context.read<HomeCubit>().onCartItemsChanged(len);
          },
        ),
    
        // لو حابة كل ما تتغير المفضلة نحدّث البادج في الهوم
        BlocListener<FavoriteCubit, dynamic>(
          listenWhen: (prev, curr) =>
              (prev.items?.length ?? 0) != (curr.items?.length ?? 0),
          listener: (context, favState) {
            context.read<HomeCubit>().refreshFavoriteBadge();
          },
        ),
      ],
      // ====== هنا صار BlocConsumer لـ HomeCubit ======
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (prev, curr) =>
            prev.productHomeState != curr.productHomeState ||
            prev.addToFavorate != curr.addToFavorate,
        listener: (context, state) {
         
        },
        builder: (context, state) {
          final homeCubit = context.read<HomeCubit>();
  
          // طول المفضلة من FavoriteCubit (للبادج)
          final int favoriteCount = context.select<FavoriteCubit, int>(
            (c) => c.state.items?.length ?? 0,
          );
      final int cartCount = context.select<CartCubit, int>(
            (c) => c.state.items.length ,
          );
          return Scaffold(
            body: IndexedStack(
              index: state.selectedTabIndex,
              children: const [
                HomeTab(),
                FavoriteTab(),
                CartTab(),
                MoreTab(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: state.selectedTabIndex,
              onDestinationSelected: homeCubit.setTab,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: 'home'.tr,
                ),
    
                // ======= FAVORITES WITH BADGE =======
                NavigationDestination(
                  icon: BadgeIcon(
                    icon: Icons.favorite_border,
                    count: favoriteCount,
                  ),
                  selectedIcon: BadgeIcon(
                    icon: Icons.favorite,
                    count: favoriteCount,
                    selected: true,
                  ),
                  label: 'favorites'.tr,
                ),
    
                // ======= CART WITH BADGE =======
                NavigationDestination(
                  icon: BadgeIcon(
                    icon: Icons.shopping_cart_outlined,
                    count: cartCount,
                  ),
                  selectedIcon: BadgeIcon(
                    icon: Icons.shopping_cart,
                    count: cartCount,
                    selected: true,
                  ),
                  label: 'cart'.tr,
                ),
    
                NavigationDestination(
                  icon: const Icon(Icons.more_horiz),
                  selectedIcon: const Icon(Icons.more),
                  label: 'more'.tr,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

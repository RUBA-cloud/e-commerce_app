// lib/features/shell/home_shell.dart
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/views/home/cart_tab.dart';

import 'package:ecommerce_app/views/home/cubit/home_cubit.dart';
import 'package:ecommerce_app/views/home/faviorate_tab.dart';
import 'package:ecommerce_app/views/home/home_tab.dart';
import 'package:ecommerce_app/views/home/more_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Tabs
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(
        builder: (context, index) {
          final cubit = context.read<HomeCubit>();

          return WillPopScope(
            onWillPop: () async {
              if (index != 0) {
                cubit.setTab(0);
                return false;
              }
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.aboutUs),
                      child: Text('notification'.tr),
                    ),
                  ],
                ),
              ),

              body: IndexedStack(
                index: index,
                children: const [
                  HomeTabe(),
                  FaviorateTab(),
                  CartTab(),
                  MoreTab(),
                ],
              ),

              bottomNavigationBar: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: cubit.setTab,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                    label: 'home'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_border),
                    selectedIcon: const Icon(Icons.favorite),
                    label: 'favorites'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    selectedIcon: const Icon(Icons.shopping_cart),
                    label: 'cart'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.more_horiz),
                    selectedIcon: const Icon(Icons.more),
                    label: 'more'.tr,
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

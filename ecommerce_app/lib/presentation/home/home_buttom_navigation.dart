// lib/presentation/home/button_home_navigation_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/presentation/home/chat_screen.dart';
import 'package:ecommerce_app/presentation/home/profile_screen.dart';
import 'package:ecommerce_app/presentation/cart/cart_screen.dart';
import 'package:ecommerce_app/presentation/home_screen.dart';
import 'package:ecommerce_app/services/cart/cart_cubit.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:ecommerce_app/services/profile/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonHomeNavigationScreen extends StatefulWidget {
  const ButtonHomeNavigationScreen({super.key});

  static void goToCart(BuildContext context) {
    context
        .findAncestorStateOfType<_ButtonHomeNavigationScreenState>()
        ?.homeCubit
        .homeTabChange(1);
  }

  @override
  State<ButtonHomeNavigationScreen> createState() =>
      _ButtonHomeNavigationScreenState();
}

class _ButtonHomeNavigationScreenState
    extends State<ButtonHomeNavigationScreen> {
  late HomeCubit homeCubit;

  // Screens initialized after homeCubit is ready.
  // All 4 always present — IndexedStack needs a fixed length.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    homeCubit = HomeCubit.get(context);

    _screens = [

      BlocProvider.value(
        value: homeCubit,
        child: const HomeScreen(),
      ),

      BlocProvider(
        create: (_) => CartCubit(),
        child: const CartScreen(),
      ),

      const ChatScreen(),
      BlocProvider(
        create: (_) => ProfileCubit(),
        child: const ProfileScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;

    return BlocBuilder<HomeCubit, HomeState>(
      bloc: homeCubit,
      // FIX: the old buildWhen mapped any non-HomeLoaded state to tab 0,
      // so emitting HomeFilterLoading or HomeFailed while you were on the
      // cart/profile tab made the UI jump back to the home tab.
      // The cubit's `selectedTab` field is the single source of truth, so
      // we just rebuild on every state and read it directly.
      builder: (context, state) {
        final selectedTab = homeCubit.selectedTab;

        return Scaffold(
          backgroundColor: c.textField,
          extendBody: true,
          body: IndexedStack(
            index: selectedTab,
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNav(selectedTab),
        );
      },
    );
  }

  Widget _buildBottomNav(int selectedTab) {
    final c = Theme.of(context).appColors;

    final items = [
      {
        'icon':   Icons.home_outlined,
        'active': Icons.home_rounded,
        'label':  'home'.tr(),
      },
      {
        'icon':   Icons.shopping_bag_outlined,
        'active': Icons.shopping_bag_rounded,
        'label':  'cart'.tr(),
      },
      {
        'icon':   Icons.chat_outlined,
        'active': Icons.chat_rounded,
        'label':  'chat'.tr(),
      },
      {
        'icon':   Icons.person_outline,
        'active': Icons.person_rounded,
        'label':  'profile'.tr(),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: c.textField,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset:     const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = selectedTab == index;
              final icon = isSelected
                  ? items[index]['active'] as IconData
                  : items[index]['icon'] as IconData;
              final label = items[index]['label'] as String;

              return GestureDetector(
                // FIX: the cubit's homeTabChange now emits again (it was
                // commented out, so taps did nothing). The extra setState
                // is a safety net: it keeps the nav responsive even if the
                // home data failed to load (in that case the cubit can't
                // emit HomeLoaded, but the IndexedStack should still switch).
                onTap: () {
                  homeCubit.homeTabChange(index);
                  setState(() {});
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 70.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size:  24.sp,
                        color: isSelected ? c.main : c.hint,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color:    isSelected ? c.main : c.hint,
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/presentation/home/chat_screen.dart';
import 'package:ecommerce_app/presentation/home/profile_screen.dart';
import 'package:ecommerce_app/presentation/cart/cart_screen.dart';
import 'package:ecommerce_app/presentation/home_screen.dart';
import 'package:ecommerce_app/services/cart/cart_cubit.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
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

  // ✅ Declare screens as a late list, initialized after homeCubit is ready
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    homeCubit = HomeCubit()..loadHome();

    // ✅ All 4 screens always present — no conditionals — IndexedStack needs fixed length
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
      const ProfileScreen(),
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
      buildWhen: (prev, curr) {
        final prevTab = prev is HomeLoaded ? prev.selectedTab : 0;
        final currTab = curr is HomeLoaded ? curr.selectedTab : 0;
        return prevTab != currTab;
      },
      builder: (context, state) {
        final selectedTab = state is HomeLoaded ? state.selectedTab : 0;

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
        'icon': Icons.home_outlined,
        'active': Icons.home_rounded,
        'label': 'home'.tr(),
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'active': Icons.shopping_bag_rounded,
        'label': 'cart'.tr(),
      },
      {
        'icon': Icons.chat_outlined,
        'active': Icons.chat_rounded,
        'label': 'chat'.tr(),
      },
      {
        'icon': Icons.person_outline,
        'active': Icons.person_rounded,
        'label': 'profile'.tr(),
      },
    ];

    // ✅ Completed bottom nav implementation
    return Container(
      decoration: BoxDecoration(
        color: c.textField,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
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
                onTap: () => homeCubit.homeTabChange(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 70.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 24.sp,
                        color: isSelected ? c.main : c.hint,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isSelected ? c.main : c.hint,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
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
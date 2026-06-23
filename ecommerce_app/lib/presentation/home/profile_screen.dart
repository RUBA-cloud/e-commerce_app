// lib/presentation/profile/profile_screen.dart

import "package:easy_localization/easy_localization.dart";
import "package:ecommerce_app/core/utility/ui_utility.dart";
import "package:ecommerce_app/presentation/auth/login_screen.dart";
import "package:ecommerce_app/presentation/profile/about_us_screen.dart";
import "package:ecommerce_app/presentation/profile/change_password_screen.dart";
import "package:ecommerce_app/presentation/profile/company_branches_screen.dart";
import "package:ecommerce_app/presentation/profile/edit_profile_screen.dart";
import "package:ecommerce_app/presentation/profile/payment_screen.dart";
import "package:ecommerce_app/services/company_info/app_main_cubit.dart";
import "package:ecommerce_app/services/company_info/app_main_state.dart";
import "package:ecommerce_app/services/login/login_cubit.dart";
import "package:ecommerce_app/services/profile/profile_cubit.dart";
import "package:ecommerce_app/services/profile/profile_state.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with UiUtility {
  late ProfileCubit _cubit;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit.get(context);
    _cubit.loadUserProfile();
  }

  void _handleState(BuildContext ctx, ProfileState state) {
    if (state is ProfileLogoutSuccessState) {
      navigateTo(
        context: ctx,
        replace: true,
        page: BlocProvider(create: (_) => LoginCubit(), child: const LoginScreen()),
      );
      return;
    }
    if (state is GoToEditProfile) {
      navigateTo(
        context: ctx,
        page: BlocProvider.value(value: _cubit, child: const EditProfileScreen()),
      );
      return;
    }
    if (state is GoToChangePassword) {
      navigateTo(
        context: ctx,
        page: BlocProvider.value(value: _cubit, child: const ChangePasswordScreen()),
      );
      return;
    }
    if (state is GoToPayment) {
      navigateTo(
        context: ctx,
        page: BlocProvider.value(value: _cubit, child: const PaymentOptionsScreen()),
      );
      return;
    }
    if (state is ProfileLogoutFailed) {
      showSnackBar(context: ctx, message: state.message ?? "logout_failed".tr(), success: false);
      return;
    }
    if (state is GoToAboutUs) {
      navigateTo(context: ctx, page: BlocProvider.value(value: _cubit, child: const AboutUsScreen()));
      return;
    }
    if (state is GoToCompanyBranches) {
      navigateTo(context: ctx, page: BlocProvider.value(value: _cubit, child: const CompanyBranchesScreen()));
      return;
    }
  }

  Future<void> _toggleLanguage() async {
    final next = context.locale.languageCode == "en"
        ? const Locale("ar")
        : const Locale("en");
    await EasyLocalization.of(context)!.setLocale(next);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppMainCubit, AppMainState>(
      buildWhen: (_, s) =>
      s is ThemeChangedState ||
          s is CompanyInfoLoaded ||
          s is CompanyInfoUpdated,
      builder: (ctx, companyState) {
        final cs = Theme.of(ctx).colorScheme;

        return BlocListener<ProfileCubit, ProfileState>(
          listener: _handleState,
          child: Scaffold(
            backgroundColor: cs.surface,
            body: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (ctx2, state) {
                if (state is ProfileLoadingState) {
                  return Center(
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(cs.primary),
                    ),
                  );
                }
                if (state is ProfileLoadFailedState) {
                  return getErrorView(
                    context: context,
                    message: state.message,
                    onRetry: _cubit.loadUserProfile,
                  );
                }

                final isLoaded = state is ProfileLoadedState;
                final name     = isLoaded ? (state.name  ?? "") : "";
                final email    = isLoaded ? (state.email ?? "") : "";
                final initials = isLoaded ? (state.avatarInitials ?? "?") : "?";

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [

                    // ── Hero Banner ─────────────────────────────
                    SliverToBoxAdapter(
                      child: HeroBannerWidget(name: 'profile'.tr()),
                    ),

                    // ── Avatar + User Info + Stats ───────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 28.h),

                            // Avatar
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 88.r, height: 88.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.primary.withOpacity(0.15),
                                    border: Border.all(
                                        color: cs.primary.withOpacity(0.30), width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color:      cs.primary.withOpacity(0.35),
                                        blurRadius: 24,
                                        offset:     const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        fontSize:   26.sp,
                                        fontWeight: FontWeight.w800,
                                        color:      cs.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 24.r, height: 24.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:  cs.secondary,
                                    border: Border.all(
                                        color: cs.surfaceContainerHigh, width: 2),
                                  ),
                                  child: Icon(Icons.verified_rounded,
                                      size: 13.r, color: cs.onSecondary),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            if (isLoaded) ...[
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize:      18.sp,
                                  fontWeight:    FontWeight.w700,
                                  color:         cs.onSurface,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                      color: cs.primary.withOpacity(0.18)),
                                ),
                                child: Text(
                                  email,
                                  style: TextStyle(
                                      fontSize: 12.sp, color: cs.onSurfaceVariant),
                                ),
                              ),
                            ] else ...[
                              _SkeletonLine(
                                  width: 130.w,
                                  color: cs.onSurface.withOpacity(0.15)),
                              SizedBox(height: 8.h),
                              _SkeletonLine(
                                  width: 180.w,
                                  color: cs.onSurface.withOpacity(0.10)),
                            ],

                            SizedBox(height: 28.h),

                            if (isLoaded)
                              Row(children: [
                                _StatChip(label: "orders".tr(),   value: "24"),
                                SizedBox(width: 10.w),
                                _StatChip(label: "wishlist".tr(), value: "11"),
                                SizedBox(width: 10.w),
                                _StatChip(label: "reviews".tr(),  value: "7"),
                              ]),

                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                    // ── Settings ────────────────────────────────
                    SliverToBoxAdapter(
                      child: _SectionCard(
                        label: "settings".tr(),
                        icon:  Icons.settings_rounded,
                        children: [

                          // ✅ Notification toggle
                          _NotificationTile(
                            enabled: _notificationsEnabled,
                            onToggle: (val) =>
                                setState(() => _notificationsEnabled = val),
                          ),
                          const _TileDivider(),

                          // ✅ Dark mode toggle
                          _DarkModeTile(
                            onToggle: () => AppMainCubit.get(ctx).toggleTheme(),
                          ),
                          const _TileDivider(),

                          _LanguageTile(
                            isArabic: context.locale.languageCode =="ar",
                            onToggle: _toggleLanguage,
                          ),
                          const _TileDivider(),

                          _Tile(
                            icon:   Icons.payment_rounded,
                            label:  "payment".tr(),
                            accent: cs.primary,
                            onTap:  () => _cubit.goToPaymentScreen(),
                          ),
                          const _TileDivider(),

                          _Tile(
                            icon:   Icons.edit_outlined,
                            label:  "edit_profile".tr(),
                            accent: cs.primary,
                            onTap:  () => _cubit.goToEditProfile(),
                          ),
                          const _TileDivider(),

                          _Tile(
                            icon:   Icons.lock_outline_rounded,
                            label:  "change_password".tr(),
                            accent: cs.secondary,
                            onTap:  () => _cubit.goToChangePassword(),
                          ),
                        ],
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                    // ── Company ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: _SectionCard(
                        label: "company".tr(),
                        icon:  Icons.business_rounded,
                        children: [
                          _Tile(
                            icon:     Icons.store_outlined,
                            label:    "branches".tr(),
                            accent:   cs.secondary,
                            trailing: _BadgeChip(label: isLoaded ? "6" : "—"),
                            onTap:    () => _cubit.goToCompanyBranches(),
                          ),
                          const _TileDivider(),
                          _Tile(
                            icon:   Icons.info_outline_rounded,
                            label:  "about_us".tr(),
                            accent: cs.primary,
                            onTap:  () => _cubit.goToAboutUs(),
                          ),
                        ],
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                    // ── Logout ───────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _LogoutButton(
                          onTap: () => _showLogoutDialog(ctx2),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 40.h)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (_) => _LogoutDialog(
        onConfirm: () { Navigator.pop(ctx); _cubit.logout(); },
        onCancel:  () => Navigator.pop(ctx),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final List<Widget> children;

  const _SectionCard({
    required this.label,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Row(children: [
              Icon(icon, size: 14.r, color: cs.onSurfaceVariant),
              SizedBox(width: 6.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize:      11.sp,
                  fontWeight:    FontWeight.w700,
                  color:         cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ]),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color:        cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16.r),
              border:       Border.all(color: cs.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color:      cs.primary.withOpacity(isDark ? 0.04 : 0.06),
                  blurRadius: 16,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Generic Tile
// ─────────────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        accent;
  final VoidCallback onTap;
  final Widget?      trailing;

  const _Tile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap:          onTap,
      splashColor:    accent.withOpacity(0.07),
      highlightColor: accent.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(children: [
          Container(
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(
              color:        accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 20.r, color: accent),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize:   14.sp,
                fontWeight: FontWeight.w500,
                color:      cs.onSurface,
              ),
            ),
          ),
          if (trailing != null) ...[trailing!, SizedBox(width: 8.w)],
          Icon(Icons.chevron_right_rounded, size: 18.r, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Notification Toggle Tile
// ─────────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final bool               enabled;
  final ValueChanged<bool> onToggle;

  const _NotificationTile({
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap:          () => onToggle(!enabled),
      splashColor:    cs.primary.withOpacity(0.07),
      highlightColor: cs.primary.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(children: [
          // icon changes with state
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(
              color: enabled
                  ? cs.primary.withOpacity(0.12)
                  : cs.onSurfaceVariant.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              size:  20.r,
              color: enabled ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "notifications".tr(),
                  style: TextStyle(
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w500,
                    color:      cs.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    key: ValueKey(enabled),
                    enabled
                        ? "notifications_on".tr()
                        : "notifications_off".tr(),
                    style: TextStyle(
                      fontSize:   11.sp,
                      color:      enabled ? cs.primary : cs.onSurfaceVariant,
                      fontWeight: enabled
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // animated pill toggle — primary when on
          GestureDetector(
            onTap: () => onToggle(!enabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width:   52.w,
              height:  28.h,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: enabled
                    ? cs.primary
                    : cs.onSurfaceVariant.withOpacity(0.3),
              ),
              child: AnimatedAlign(
                duration:  const Duration(milliseconds: 220),
                curve:     Curves.easeInOut,
                alignment: enabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width:  22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.onPrimary,
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dark Mode Toggle Tile
// ─────────────────────────────────────────────────────────────
class _DarkModeTile extends StatelessWidget {
  final VoidCallback onToggle;

  const _DarkModeTile({required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap:          onToggle,
      splashColor:    cs.secondary.withOpacity(0.07),
      highlightColor: cs.secondary.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(
              color:        cs.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              size:  20.r,
              color: cs.secondary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "dark_mode".tr(),
                  style: TextStyle(
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w500,
                    color:      cs.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    key: ValueKey(isDark),
                    isDark ? "dark_mode_on".tr() : "dark_mode_off".tr(),
                    style: TextStyle(
                      fontSize:   11.sp,
                      color:      isDark ? cs.secondary : cs.onSurfaceVariant,
                      fontWeight: isDark ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // animated pill toggle — secondary when on
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width:   52.w,
              height:  28.h,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: isDark
                    ? cs.secondary
                    : cs.onSurfaceVariant.withOpacity(0.3),
              ),
              child: AnimatedAlign(
                duration:  const Duration(milliseconds: 220),
                curve:     Curves.easeInOut,
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width:  22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.onSecondary,
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Language Tile
// ─────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final bool         isArabic;
  final VoidCallback onToggle;

  const _LanguageTile({
    required this.isArabic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap:          onToggle,
      splashColor:    cs.secondary.withOpacity(0.07),
      highlightColor: cs.secondary.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(children: [
          Container(
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(
              color:        cs.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.language_rounded, size: 20.r, color: cs.secondary),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "language".tr(),
                  style: TextStyle(
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w500,
                    color:      cs.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isArabic ? "العربية" : "English",
                  style: TextStyle(
                    fontSize:   11.sp,
                    color:      cs.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // EN/AR animated pill — secondary
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width:   72.w,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color:        cs.secondary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20.r),
                border:       Border.all(color: cs.secondary.withOpacity(0.35)),
              ),
              child: Stack(children: [
                AnimatedAlign(
                  duration:  const Duration(milliseconds: 220),
                  curve:     Curves.easeInOut,
                  alignment: isArabic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width:   32.w,
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    decoration: BoxDecoration(
                      color:        cs.secondary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text(
                        isArabic ? "AR" : "EN",
                        style: TextStyle(
                          fontSize:   10.sp,
                          fontWeight: FontWeight.w800,
                          color:      cs.onSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: isArabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        isArabic ? "EN" : "AR",
                        style: TextStyle(
                          fontSize:   10.sp,
                          fontWeight: FontWeight.w600,
                          color:      cs.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tile Divider
// ─────────────────────────────────────────────────────────────
class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) => Divider(
    height:    1,
    indent:    70.w,
    endIndent: 0,
    color:     Theme.of(context).colorScheme.outlineVariant,
  );
}

// ─────────────────────────────────────────────────────────────
// Badge Chip
// ─────────────────────────────────────────────────────────────
class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color:        cs.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: cs.secondary.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11.sp,
          fontWeight: FontWeight.w700,
          color:      cs.secondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat Chip
// ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color:        cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border:       Border.all(color: cs.primary.withOpacity(0.15)),
        ),
        child: Column(children: [
          Text(
            value,
            style: TextStyle(
              fontSize:   16.sp,
              fontWeight: FontWeight.w800,
              color:      cs.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: cs.onSurfaceVariant),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logout Button
// ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs         = Theme.of(context).colorScheme;
    final errorColor = cs.error;

    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color:        cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16.r),
          border:       Border.all(color: errorColor.withOpacity(0.28)),
          boxShadow: [
            BoxShadow(
              color:      errorColor.withOpacity(0.07),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(
              color:        errorColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.logout_rounded, size: 20.r, color: errorColor),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              "logout".tr(),
              style: TextStyle(
                fontSize:   14.sp,
                fontWeight: FontWeight.w600,
                color:      errorColor,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 18.r, color: errorColor.withOpacity(0.40)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logout Dialog
// ─────────────────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _LogoutDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cs         = Theme.of(context).colorScheme;
    final errorColor = cs.error;

    return Dialog(
      shape:           RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: cs.surfaceContainerHigh,
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r, height: 64.r,
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, size: 28.r, color: errorColor),
            ),
            SizedBox(height: 16.h),
            Text(
              "logout".tr(),
              style: TextStyle(
                fontSize:   17.sp,
                fontWeight: FontWeight.w700,
                color:      cs.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "logout_confirm".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color:    cs.onSurfaceVariant,
                height:   1.5,
              ),
            ),
            SizedBox(height: 24.h),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurfaceVariant,
                    side:    BorderSide(color: cs.outlineVariant),
                    shape:   RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                  ),
                  child: Text("cancel".tr(),
                      style: TextStyle(fontSize: 14.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: cs.onError,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                  ),
                  child: Text(
                    "logout".tr(),
                    style: TextStyle(
                        fontSize:   14.sp,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Skeleton Line
// ─────────────────────────────────────────────────────────────
class _SkeletonLine extends StatelessWidget {
  final double width;
  final Color  color;
  const _SkeletonLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 13.h,
    decoration: BoxDecoration(
      color:        color,
      borderRadius: BorderRadius.circular(6.r),
    ),
  );
}
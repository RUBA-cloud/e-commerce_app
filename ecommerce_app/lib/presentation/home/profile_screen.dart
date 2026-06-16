// ============================================================
//  edit_profile_screen.dart  –  100% theme-driven, no _T class
//  Colors come from: Theme.of(context).colorScheme  +
//                    UiUtility.companyColors(state)
// ============================================================

import "package:easy_localization/easy_localization.dart";
import "package:ecommerce_app/core/utility/ui_utility.dart";
import "package:ecommerce_app/presentation/auth/login_screen.dart";
import "package:ecommerce_app/presentation/profile/about_us_screen.dart";
import "package:ecommerce_app/presentation/profile/company_branches_screen.dart";
import "package:ecommerce_app/presentation/profile/edit_profile_screen.dart";
import "package:ecommerce_app/services/login/login_cubit.dart";
import "package:ecommerce_app/services/profile/profile_cubit.dart";
import "package:ecommerce_app/services/profile/profile_state.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

// ─────────────────────────────────────────────────────────────
// ColorScheme extension — maps semantic names to real slots
// ─────────────────────────────────────────────────────────────
extension _CS on ColorScheme {
  // backgrounds
  Color get pageBackground  => brightness == Brightness.dark
      ? surface.withOpacity(0.95)
      : surface;
  Color get cardBackground  => brightness == Brightness.dark
      ? surfaceVariant
      : onInverseSurface;      // near-white in light, elevated in dark

  // text
  Color get textPrimary     => onSurface;
  Color get textMuted       => onSurface.withOpacity(0.50);

  // divider
  Color get dividerColor    => outline.withOpacity(0.25);

  // card shadow
  Color get shadowColor     => brightness == Brightness.dark
      ? Colors.black
      : shadow;
}

// ─────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with UiUtility {
  late ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit.get(context);
    _cubit.loadCompanyInfo();
  }

  // ── BLoC navigation listener ──────────────────────────────
  void _handleState(BuildContext ctx, ProfileState state) {
    if (state is ProfileLogoutSuccessState) {
      navigateTo(
        context: ctx,
        replace: true,
        page: BlocProvider(
          create: (_) => LoginCubit(),
          child: const LoginScreen(),
        ),
      );
      return;
    }
    if (state is ProfileLogoutFailed) {
      showSnackBar(
        context: ctx,
        message: state.message ?? "logout_failed".tr(),
        success: false,
      );
      return;
    }
    if (state is GoToAboutUs) {
      navigateTo(
        context: ctx,
        page: BlocProvider.value(value: _cubit, child: const AboutUsScreen()),
      );
      return;
    }
    if (state is GoToCompanyBranches) {
      navigateTo(
        context: ctx,
        page: BlocProvider.value(value: _cubit, child: const CompanyBranchesScreen()),
      );
      return;
    }
  }

  // ── Language toggle ───────────────────────────────────────
  Future<void> _toggleLanguage(BuildContext ctx) async {
    final next = ctx.locale.languageCode == "en"
        ? const Locale("ar")
        : const Locale("en");
   await EasyLocalization.of(context)!.setLocale(next);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: cs.pageBackground,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (ctx, state) {

            if (state is ProfileLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: cs.primary,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (state is ProfileLoadFailedState) {
              return _ErrorBody(
                message: state.message,
                onRetry: _cubit.loadCompanyInfo,
              );
            }

            final isLoaded = state is ProfileLoadedState;
            final name     = isLoaded ? (state.name  ?? "") : "";
            final email    = isLoaded ? (state.email ?? "") : "";
            final initials = isLoaded ? (state.avatarInitials ?? "?") : "?";
            final isArabic = ctx.locale.languageCode == "ar";

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                // ── Header ────────────────────────────────
                SliverToBoxAdapter(
                  child:  Container(
                    // Header uses primary → primaryContainer gradient — theme-driven
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.primaryContainer],
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
                        child: Column(children: [

                          // Top row
                          Row(children: [
                            Text(
                              "profile".tr(),
                              style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.w700,
                                color: cs.onPrimary, letterSpacing: -0.3,
                              ),
                            ),
                            const Spacer(),
                            _IconBtn(
                              icon: Icons.edit_outlined,
                              onTap: () {navigateTo(context: context,replace: true,page: BlocProvider.value(value: _cubit,child: EditProfileScreen(),));},
                              tooltip: "edit_profile".tr(),
                            ),
                          ]),

                          SizedBox(height: 28.h),

                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 88.r, height: 88.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.onPrimary.withOpacity(0.15),
                                  border: Border.all(
                                      color: cs.onPrimary.withOpacity(0.30), width: 3),
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
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 24.r, height: 24.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.secondary,
                                  border: Border.all(color: cs.primary, width: 2),
                                ),
                                child: Icon(Icons.verified_rounded,
                                    size: 13.r, color: cs.onSecondary),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Name / email / skeleton
                          if (isLoaded) ...[
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w700,
                                color: cs.onPrimary, letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: cs.onPrimary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: cs.onPrimary.withOpacity(0.18)),
                              ),
                              child: Text(
                                email,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: cs.onPrimary.withOpacity(0.78),
                                ),
                              ),
                            ),
                          ] else ...[
                            _SkeletonLine(
                                width: 130.w, color: cs.onPrimary.withOpacity(0.30)),
                            SizedBox(height: 8.h),
                            _SkeletonLine(
                                width: 180.w, color: cs.onPrimary.withOpacity(0.20)),
                          ],

                          SizedBox(height: 28.h),

                          // Stats
                          if (isLoaded)
                            Row(children: [
                              _StatChip(label: "orders".tr(),   value: "24"),
                              SizedBox(width: 10.w),
                              _StatChip(label: "wishlist".tr(), value: "11"),
                              SizedBox(width: 10.w),
                              _StatChip(label: "reviews".tr(),  value: "7"),
                            ]),
                        ]),
                      ),
                    ),
                  )
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // ── Settings ──────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionCard(
                    label: "settings".tr(),
                    icon:  Icons.settings_rounded,
                    children: [
                      _Tile(
                        icon:   Icons.notifications_none_rounded,
                        label:  "notifications".tr(),
                        accent: cs.primary,
                        onTap:  () {},
                      ),
                      _TileDivider(),
                      _LanguageTile(
                        isArabic: isArabic,
                        onToggle: () => _toggleLanguage(ctx),
                      ),
                      _TileDivider(),
                      _Tile(
                        icon:   Icons.lock_outline_rounded,
                        label:  "change_password".tr(),
                        accent: cs.secondary,
                        onTap:  () {},
                      ),
                      _TileDivider(),
                      _Tile(
                        icon:   Icons.payment_rounded,
                        label:  "payment_options".tr(),
                        accent: cs.tertiary,
                        onTap:  () {},
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                // ── Company ───────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionCard(
                    label: "company".tr(),
                    icon:  Icons.business_rounded,
                    children: [
                      _Tile(
                        icon:     Icons.store_outlined,
                        label:    "branches".tr(),
                        accent:   cs.secondary,
                        trailing: _BadgeChip(label: isLoaded ? "6": "—"),
                        onTap:    () => _cubit.goToCompanyBranches(),
                      ),
                      _TileDivider(),
                      _Tile(
                        icon:   Icons.headset_mic_outlined,
                        label:  "contact_us".tr(),
                        accent: cs.primary,
                        onTap:  () => _cubit.goToAboutUs(),
                      ),
                      _TileDivider(),
                      _Tile(
                        icon:   Icons.info_outline_rounded,
                        label:  "about_us".tr(),
                        accent: cs.tertiary,
                        onTap:  () => _cubit.goToAboutUs(),
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                // ── Logout ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _LogoutButton(
                      onTap: () => _showLogoutDialog(context),
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
  }

  // ── Logout dialog ─────────────────────────────────────────
  void _showLogoutDialog(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;

    showDialog<void>(
      context: ctx,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: cs.cardBackground,
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r, height: 64.r,
                decoration: BoxDecoration(
                  color: cs.error.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded,
                    size: 28.r, color: cs.error),
              ),
              SizedBox(height: 16.h),
              Text(
                "logout".tr(),
                style: TextStyle(
                  fontSize: 17.sp, fontWeight: FontWeight.w700,
                  color: cs.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "logout_confirm".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: cs.textMuted,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.textMuted,
                      side: BorderSide(color: cs.dividerColor),
                      shape: RoundedRectangleBorder(
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
                    onPressed: () {
                      Navigator.pop(ctx);
                      _cubit.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                    ),
                    child: Text("logout".tr(),
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
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
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Row(children: [
              Icon(icon, size: 14.r, color: cs.textMuted),
              SizedBox(width: 6.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.sp, fontWeight: FontWeight.w700,
                  color: cs.textMuted, letterSpacing: 1.0,
                ),
              ),
            ]),
          ),
          // Card
          Container(
            decoration: BoxDecoration(
              color: cs.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: cs.dividerColor),
              boxShadow: [
                BoxShadow(
                  color:      cs.shadowColor.withOpacity(0.06),
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
  final Color        accent;   // from ColorScheme at call site
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
      onTap: onTap,
      splashColor:    accent.withOpacity(0.07),
      highlightColor: accent.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 16.w, vertical: 14.h),
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: cs.textPrimary,
              ),
            ),
          ),
          if (trailing != null) ...[trailing!, SizedBox(width: 8.w)],
          Icon(Icons.chevron_right_rounded,
              size: 18.r, color: cs.textMuted),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Language Tile  (animated EN / AR pill toggle)
// ─────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final bool         isArabic;
  final VoidCallback onToggle;

  const _LanguageTile({required this.isArabic, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onToggle,
      splashColor:    cs.secondary.withOpacity(0.07),
      highlightColor: cs.secondary.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(children: [
          // Icon badge
          Container(
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(
              color:        cs.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.language_rounded,
                size: 20.r, color: cs.secondary),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              "language".tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: cs.textPrimary,
              ),
            ),
          ),

          // Pill toggle
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 72.w,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color:        cs.secondary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: cs.secondary.withOpacity(0.35)),
              ),
              child: Stack(
                children: [
                  // Sliding thumb
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 220),
                    curve:    Curves.easeInOut,
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 32.w,
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      decoration: BoxDecoration(
                        color:        cs.secondary,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Text(
                          isArabic ? "AR": "EN",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: cs.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Inactive label
                  Positioned.fill(
                    child: Align(
                      alignment: isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          isArabic ? "EN": "AR",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: cs.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 70.w,
    endIndent: 0,
    color: Theme.of(context).colorScheme.dividerColor,
  );
}

// ─────────────────────────────────────────────────────────────
// Badge Chip  (branch count)
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
        border: Border.all(color: cs.secondary.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp, fontWeight: FontWeight.w700,
          color: cs.secondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat Chip  (orders / wishlist / reviews in header)
// ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color:        cs.onPrimary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: cs.onPrimary.withOpacity(0.15)),
        ),
        child: Column(children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp, fontWeight: FontWeight.w800,
              color: cs.onPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: cs.onPrimary.withOpacity(0.60),
            ),
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
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color:        cs.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cs.error.withOpacity(0.28)),
          boxShadow: [
            BoxShadow(
              color:      cs.error.withOpacity(0.07),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(
              color:        cs.error.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.logout_rounded,
                size: 20.r, color: cs.error),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              "logout".tr(),
              style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w600,
                color: cs.error,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 18.r, color: cs.error.withOpacity(0.40)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Icon Button  (edit in header)
// ─────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final String       tooltip;
  const _IconBtn({required this.icon, required this.onTap,
    required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38.r, height: 38.r,
          decoration: BoxDecoration(
            color:        cs.onPrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
                color: cs.onPrimary.withOpacity(0.18)),
          ),
          child: Icon(icon, size: 18.r, color: cs.onPrimary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error Body
// ─────────────────────────────────────────────────────────────
class _ErrorBody extends StatelessWidget {
  final String?      message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded,
              size: 52.r, color: cs.textMuted),
          SizedBox(height: 14.h),
          Text(
            message ?? "something_went_wrong".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: cs.textMuted,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon:  Icon(Icons.refresh_rounded, size: 16.r),
            label: Text("retry".tr(),
                style: TextStyle(fontSize: 13.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(
                  horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ]),
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
    width: width, height: 13.h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6.r),
    ),
  );
}


// ============================================================
//  HOW COLORS MAP
// ============================================================
//
//  Header gradient   → cs.primary  →  cs.primaryContainer
//  Header text/icon  → cs.onPrimary
//  Avatar badge      → cs.secondary  /  cs.onSecondary
//  Section card bg   → cs.cardBackground  (extension above)
//  Tile accent 1     → cs.primary        (notifications, contact)
//  Tile accent 2     → cs.secondary      (language, branches)
//  Tile accent 3     → cs.tertiary       (password, about)
//  Logout / error    → cs.error  /  cs.onError
//  Muted text        → cs.onSurface.withOpacity(0.50)
//  Dividers          → cs.outline.withOpacity(0.25)
//
//  Your buildTheme() in UiUtility already sets all of these
//  from CompanyColors, so no extra wiring is needed.
//
// ============================================================
//  ColorScheme fields used  (set in UiUtility.buildTheme)
// ============================================================
//
//  primary          → c.main
//  primaryContainer → Color.lerp(c.main, c.sub, 0.5)  or c.sub
//  onPrimary        → c.buttonText
//  secondary        → c.sub
//  onSecondary      → c.buttonText
//  tertiary         → any third accent you want (e.g. c.icon)
//  onTertiary       → c.buttonText
//  surface          → c.card
//  onSurface        → c.text
//  outline          → c.sub.withOpacity(0.4)
//  error            → Color(0xFFE24B4A)
//  onError          → Colors.white
//
//  Add tertiary / onTertiary to ColorScheme.fromSeed(…) call:
//    tertiary:   c.icon,
//    onTertiary: c.buttonText,
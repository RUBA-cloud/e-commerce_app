import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/response/carts/company_branch_entity.dart';
import 'package:ecommerce_app/services/profile/profile_cubit.dart';
import 'package:ecommerce_app/services/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class CompanyBranchesScreen extends StatefulWidget {
  const CompanyBranchesScreen({super.key});

  @override
  State<CompanyBranchesScreen> createState() => _CompanyBranchesScreenState();
}

class _CompanyBranchesScreenState extends State<CompanyBranchesScreen> with UiUtility {
  late ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit.get(context);
    _cubit.loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (ctx, state) {
          int? count;
          if (state is ProfileBranchLoaded) {
            count = state.companyBranchEntity.branches.data.length;
          }

          return Column(
            children: [
              // ── Custom App Bar ───────────────────────────
              _CustomAppBar(isAr: isAr, branchCount: count),

              // ── Body ─────────────────────────────────────
              Expanded(child: _buildBody(state, isAr)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ProfileState state, bool isAr) {
    if (state is ProfileBranchLoading) {
      return const _LoadingView();
    }
    if (state is ProfileBranchFailed) {
      return getErrorView(context: context,
        message: state.message,
        onRetry: () => _cubit.loadBranches());

    }




    if (state is ProfileBranchLoaded) {
      final branches = state.companyBranchEntity.branches.data;
      if (branches.isEmpty) return  buildEmptyState(context: context, title: "no_branches".tr(), subtitle: "subtitle");

      return ListView.separated(
        physics:          const BouncingScrollPhysics(),
        padding:          EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        itemCount:        branches.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder:      (_, i) => _BranchCard(
          branch: branches[i],
          isAr:   isAr,
          index:  i,
        ),
      );
    }
    return const _LoadingView();
  }
}

// ─────────────────────────────────────────────────────────────
// Custom App Bar  — simple, theme-aware
// ─────────────────────────────────────────────────────────────
class _CustomAppBar extends StatelessWidget {
  final bool isAr;
  final int? branchCount;
  const _CustomAppBar({required this.isAr, this.branchCount});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final top    = MediaQuery.of(context).padding.top;

    return Container(
      color: cs.surface,
      padding: EdgeInsets.only(top: top),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Main row ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Row(
              children: [
                // Back button
                _AppBarIconButton(
                  icon:    isAr
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  onTap:   () => Navigator.maybePop(context),
                ),

                SizedBox(width: 8.w),

                // Title
                Expanded(
                  child: Text(
                    'branches'.tr(),
                    style: TextStyle(
                      fontSize:      18.sp,
                      fontWeight:    FontWeight.w700,
                      color:         cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // Branch count chip
                if (branchCount != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color:        cs.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: cs.primary.withOpacity(0.18)),
                    ),
                    child: Text(
                      '$branchCount ${'branches'.tr()}',
                      style: TextStyle(
                        fontSize:   12.sp,
                        fontWeight: FontWeight.w600,
                        color:      cs.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Thin divider ──────────────────────────────────
          Divider(
            height:  1,
            thickness: 1,
            color:   cs.outline.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// App bar icon button
// ─────────────────────────────────────────────────────────────
class _AppBarIconButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color:        cs.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10.r),
          border:       Border.all(color: cs.primary.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 15.r, color: cs.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Branch card  (kept exactly — only _T tokens → cs equivalents)
// ─────────────────────────────────────────────────────────────
class _BranchCard extends StatelessWidget {
  final CompanyBranchBranchesDataEntity branch;
  final bool isAr;
  final int  index;

  const _BranchCard({
    required this.branch,
    required this.isAr,
    required this.index,
  });

  String _loc(String en, String ar) => isAr ? ar : en;

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final name    = _loc(branch.nameEn, branch.nameAr);
    final address = _loc(branch.addressEn ?? '', branch.addressAr ?? '');

    return Container(
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(color: cs.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color:      primary.withOpacity(0.06),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Primary-color left accent stripe ─────────
              Container(
                width: 4.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topCenter,
                    end:    Alignment.bottomCenter,
                    colors: [primary, primary.withOpacity(0.6)],
                  ),
                ),
              ),

              // ── Card body ─────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Index badge
                          Container(
                            width:  36.r,
                            height: 36.r,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin:  Alignment.topCenter,
                                end:    Alignment.bottomCenter,
                                colors: [primary, primary.withOpacity(0.75)],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize:   14.sp,
                                  fontWeight: FontWeight.w900,
                                  color:      cs.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),

                          // Name + address
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize:   14.sp,
                                    fontWeight: FontWeight.w700,
                                    color:      cs.onSurface,
                                    height:     1.2,
                                  ),
                                ),
                                if (address.isNotEmpty) ...[
                                  SizedBox(height: 3.h),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size:  11.r,
                                          color: cs.onSurface.withOpacity(0.45)),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Text(
                                          address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color:    cs.onSurface.withOpacity(0.45),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(width: 8.w),
                          _ActiveBadge(isActive: branch.isActive),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Divider
                      Container(
                        height: 1,
                        color:  cs.outline.withOpacity(0.10),
                      ),

                      SizedBox(height: 12.h),

                      // Contact info
                      if (branch.phone.isNotEmpty)
                        _InfoRow(
                          icon:  Icons.phone_outlined,
                          label: branch.phone,
                        ),
                      if (branch.email.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _InfoRow(
                          icon:  Icons.email_outlined,
                          label: branch.email,
                        ),
                      ],

                      SizedBox(height: 12.h),

                      // Footer pills
                      if ((branch.workingHoursFrom.isNotEmpty) ||
                          (branch.workingDays.isNotEmpty))
                        _CardFooter(branch: branch),

                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Active badge
// ─────────────────────────────────────────────────────────────
class _ActiveBadge extends StatelessWidget {
  final bool isActive;
  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final activeColor = Colors.green.shade600;
    final bgColor     = isActive
        ? Colors.green.withOpacity(0.10)
        : cs.error.withOpacity(0.10);
    final dotColor    = isActive ? activeColor : cs.error;
    final textColor   = isActive ? activeColor : cs.error;
    final borderColor = isActive
        ? Colors.green.withOpacity(0.25)
        : cs.error.withOpacity(0.25);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  5.r, height: 5.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            isActive ? 'active'.tr() : 'inactive'.tr(),
            style: TextStyle(
              fontSize:   10.sp,
              fontWeight: FontWeight.w700,
              color:      textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card footer — hours + days pills
// ─────────────────────────────────────────────────────────────
class _CardFooter extends StatelessWidget {
  final CompanyBranchBranchesDataEntity branch;
  const _CardFooter({required this.branch});

  @override
  Widget build(BuildContext context) {
    final hasHours = branch.workingHoursFrom != null &&
        branch.workingHoursTo != null;
    final hasDays  = branch.workingDays != null &&
        branch.workingDays!.isNotEmpty;

    return Wrap(
      spacing:    8.w,
      runSpacing: 6.h,
      children: [
        if (hasHours)
          _FooterPill(
            icon:  Icons.access_time_rounded,
            label: '${branch.workingHoursFrom} – ${branch.workingHoursTo}',
          ),
        if (hasDays)
          _FooterPill(
            icon:  Icons.calendar_today_outlined,
            label: branch.workingDays!,
          ),
      ],
    );
  }
}

class _FooterPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _FooterPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color:        cs.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: cs.primary.withOpacity(0.8)),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize:   11.sp,
              color:      cs.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Info row
// ─────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width:  28.r, height: 28.r,
          decoration: BoxDecoration(
            color:        cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 13.r, color: cs.primary.withOpacity(0.85)),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color:    cs.onSurface.withOpacity(0.60),
              height:   1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading view
// ─────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width:  40.r, height: 40.r,
            child: CircularProgressIndicator(
              color:       cs.primary,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'loading'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              color:    cs.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }

}
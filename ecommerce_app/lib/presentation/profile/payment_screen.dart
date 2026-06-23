// lib/presentation/profile/payment_options_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/data/model/response/profile/payment_entity.dart';
import 'package:ecommerce_app/services/profile/profile_cubit.dart';
import 'package:ecommerce_app/services/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  late ProfileCubit cubit; // ✅ removed misplaced @override, fixed nullable

  @override
  void initState() {
    super.initState();
    cubit = ProfileCubit.get(context);
    cubit.loadPayments(); // ✅ load payments on init
  }

  @override
  Widget build(BuildContext context) {
    return _paymentView(context);
  }

  // ✅ moved inside class, prefixed with underscore
  Widget _paymentView(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final isAr = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _AppBar(isAr: isAr),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                // ── Loading ──────────────────────────────────
                if (state is PaymentLoadingState) {
                  return Center(
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(cs.primary),
                    ),
                  );
                }

                // ── Error ────────────────────────────────────
                if (state is PaymentLoadFailedState) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<ProfileCubit>().loadPayments(), // ✅ fixed
                  );
                }

                // ── Resolve payments + selectedId ────────────
                List<PaymentDataEntity> payments = [];
                int? selectedId;

                if (state is PaymentLoadedState) {
                  payments   = List<PaymentDataEntity>.from(state.payments);
                  selectedId = state.selectedId;
                } else if (state is PaymentSelectedState) {
                  final cubit = context.read<ProfileCubit>(); // ✅ was PaymentCubit
                  selectedId  = cubit.selectedId;
                  // keep last known list — re-load if empty
                  if (payments.isEmpty) cubit.loadPayments();
                }

                // ── Empty ────────────────────────────────────
                if (payments.isEmpty && state is! PaymentSelectedState) {
                  return _EmptyView(
                    onRetry: () =>
                        context.read<ProfileCubit>().loadPayments(), // ✅ fixed
                  );
                }

                return _PaymentList(
                  payments:   payments,
                  selectedId: selectedId,
                  isAr:       isAr,
                );
              },
            ),
          ),

          // ── Confirm button ───────────────────────────────
          const _ConfirmBar(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Payment List
// ─────────────────────────────────────────────────────────────
class _PaymentList extends StatelessWidget {
  final List<PaymentDataEntity> payments;
  final int?                    selectedId;
  final bool                    isAr;

  const _PaymentList({
    required this.payments,
    required this.selectedId,
    required this.isAr,
  });

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('cash'))   return Icons.payments_outlined;
    if (n.contains('card') || n.contains('credit') || n.contains('visa'))
      return Icons.credit_card_rounded;
    if (n.contains('bank') || n.contains('transfer'))
      return Icons.account_balance_outlined;
    if (n.contains('wallet') || n.contains('apple') || n.contains('google'))
      return Icons.account_balance_wallet_outlined;
    if (n.contains('cod'))    return Icons.local_shipping_outlined;
    return Icons.payment_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    final active   = payments.where((p) => p.isActive == 1).toList();
    final inactive = payments.where((p) => p.isActive != 1).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
      children: [
        const _InfoBanner(),
        SizedBox(height: 20.h),

        _SectionLabel(
          label: 'available_payment_methods'.tr(),
          icon:  Icons.check_circle_outline_rounded,
          color: primary,
        ),
        SizedBox(height: 10.h),

        // ✅ Radio-style selection — passes selectedId down
        ...active.map((p) => _PaymentCard(
          data:       p,
          isSelected: selectedId == p.id,
          isActive:   true,
          isAr:       isAr,
          icon:       _iconFor(isAr ? p.nameAr : p.nameEn),
          onTap: () => context.read<ProfileCubit>().selectPayment(p.id),
        )),

        if (inactive.isNotEmpty) ...[
          SizedBox(height: 20.h),
          _SectionLabel(
            label: 'unavailable_methods'.tr(),
            icon:  Icons.block_rounded,
            color: cs.onSurface.withOpacity(0.35),
          ),
          SizedBox(height: 10.h),
          ...inactive.map((p) => _PaymentCard(
            data:       p,
            isSelected: false,
            isActive:   false,
            isAr:       isAr,
            icon:       _iconFor(isAr ? p.nameAr : p.nameEn),
            onTap:      null,
          )),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Payment Card  (radio button UI)
// ─────────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final PaymentDataEntity data;
  final bool              isSelected;
  final bool              isActive;
  final bool              isAr;
  final IconData          icon;
  final VoidCallback?     onTap;

  const _PaymentCard({
    required this.data,
    required this.isSelected,
    required this.isActive,
    required this.isAr,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final name    = isAr ? data.nameAr : data.nameEn;

    final borderColor = isSelected
        ? primary
        : isActive
        ? cs.outline.withOpacity(0.18)
        : cs.outline.withOpacity(0.10);

    final bgColor = isSelected
        ? primary.withOpacity(0.05)
        : isActive
        ? cs.surface
        : cs.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color:        bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color:      primary.withOpacity(0.12),
              blurRadius: 16,
              offset:     const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color:      cs.shadow.withOpacity(0.04),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap:        isActive ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          splashColor:  primary.withOpacity(0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // ── Icon ──────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width:  46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primary.withOpacity(0.12)
                        : isActive
                        ? cs.surfaceContainerHighest.withOpacity(0.60)
                        : cs.outline.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13.r),
                    border: isSelected
                        ? Border.all(color: primary.withOpacity(0.30))
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 22.r,
                    color: isSelected
                        ? primary
                        : isActive
                        ? cs.onSurface.withOpacity(0.55)
                        : cs.onSurface.withOpacity(0.25),
                  ),
                ),

                SizedBox(width: 14.w),

                // ── Name + status ─────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize:   14.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? cs.onSurface
                              : cs.onSurface.withOpacity(0.35),
                        ),
                      ),
                      if (!isActive) ...[
                        SizedBox(height: 3.h),
                        Text(
                          'currently_unavailable'.tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:    cs.onSurface.withOpacity(0.30),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Radio indicator ───────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Container(
                    key: const ValueKey('selected'),
                    width:  22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size:  13.r,
                      color: cs.onPrimary,
                    ),
                  )
                      : Container(
                    key: const ValueKey('unselected'),
                    width:  22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? cs.outline.withOpacity(0.35)
                            : cs.outline.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Confirm Bar  — calls submitPaymentSelectedOption
// ─────────────────────────────────────────────────────────────
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // ✅ show feedback after submit
        if (state is PaymentSubmitSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text('payment_method_saved'.tr()),
              backgroundColor: Colors.green.shade600,
              behavior:        SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
          );
          Navigator.maybePop(context);
        }
        if (state is PaymentSubmitFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message ?? 'something_went_wrong'.tr()),
              backgroundColor: cs.error,
              behavior:        SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit       = context.read<ProfileCubit>();
        final hasSelected = cubit.selectedId != null;
        final isLoading   = state is PaymentSubmitLoadingState;

        return Container(
          padding: EdgeInsets.fromLTRB(
            16.w,
            12.h,
            16.w,
            MediaQuery.of(context).padding.bottom + 12.h,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              top: BorderSide(color: cs.outline.withOpacity(0.10)),
            ),
            boxShadow: [
              BoxShadow(
                color:      cs.shadow.withOpacity(0.06),
                blurRadius: 12,
                offset:     const Offset(0, -4),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: (hasSelected && !isLoading)
                ? () => cubit.submitPayment() // ✅ calls cubit submit
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50.h,
              decoration: BoxDecoration(
                color: hasSelected
                    ? cs.primary
                    : cs.primary.withOpacity(0.40),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: hasSelected
                    ? [
                  BoxShadow(
                    color:      cs.primary.withOpacity(0.30),
                    blurRadius: 12,
                    offset:     const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                  width:  20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color:       cs.onPrimary,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 18.r, color: cs.onPrimary),
                    SizedBox(width: 8.w),
                    Text(
                      'confirm_payment_method'.tr(),
                      style: TextStyle(
                        fontSize:   15.sp,
                        fontWeight: FontWeight.w700,
                        color:      cs.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Info Banner
// ─────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border:       Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width:  40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color:        primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.shield_outlined, size: 20.r, color: primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'secure_payment'.tr(),
                  style: TextStyle(
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w700,
                    color:      cs.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'payment_tip'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:    cs.onSurface.withOpacity(0.55),
                    height:   1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    color;

  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.r, color: color),
        SizedBox(width: 6.w),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize:      11.sp,
            fontWeight:    FontWeight.w700,
            color:         color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Custom App Bar
// ─────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final bool isAr;
  const _AppBar({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color:   cs.surface,
      padding: EdgeInsets.only(top: top),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Row(
              children: [
                _IconBtn(
                  icon: isAr
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'payment_options'.tr(),
                    style: TextStyle(
                      fontSize:      18.sp,
                      fontWeight:    FontWeight.w700,
                      color:         cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                _IconBtn(
                  icon:  Icons.refresh_rounded,
                  onTap: () => context.read<ProfileCubit>().loadPayments(),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: cs.outline.withOpacity(0.10)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

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
          border: Border.all(color: cs.primary.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 15.r, color: cs.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error View
// ─────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String?      message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: cs.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 28.r, color: cs.error),
            ),
            SizedBox(height: 16.h),
            Text(
              message ?? 'something_went_wrong'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color:    cs.onSurface.withOpacity(0.55),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:  Icon(Icons.refresh_rounded, size: 16.r),
              label: Text('retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty View
// ─────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_off_rounded,
              size:  48.r,
              color: cs.onSurface.withOpacity(0.20)),
          SizedBox(height: 14.h),
          Text(
            'no_payment_methods'.tr(),
            style: TextStyle(
              fontSize:   14.sp,
              color:      cs.onSurface.withOpacity(0.45),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.h),
          TextButton.icon(
            onPressed: onRetry,
            icon:  Icon(Icons.refresh_rounded, size: 16.r),
            label: Text('refresh'.tr()),
          ),
        ],
      ),
    );
  }
}
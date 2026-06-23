// ============================================================
//  about_us_screen.dart
// ============================================================

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/utility/ui_utility.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/services/company_info/app_main_cubit.dart';
import 'package:ecommerce_app/services/company_info/app_main_state.dart';
import 'package:ecommerce_app/services/profile/profile_cubit.dart';
import 'package:ecommerce_app/services/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with UiUtility, TickerProviderStateMixin {
  late ProfileCubit        _profileCubit;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit.get(context);
    final current = _profileCubit.state;
    if (current is! ProfileLoadedState) {
      _profileCubit.loadCompanyInfo();
    }

    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation:   0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Icon(
              isAr
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: 16.r,
            ),
          ),
        ),
        title: Text(
          "about_us".tr(),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(color: Theme.of(context).colorScheme.surface,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (ctx, state) {
            if (state is ProfileLoadingState) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is ProfileLoadFailedState) {
              return getErrorView(           // ← FIXED: was missing return
                context: context,
                message: state.message ?? 'something_went_wrong'.tr(),
                onRetry: () => _profileCubit.loadCompanyInfo(),
              );
            }

            if (state is ProfileLoadedState) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _AboutUsBody(
                    company: state.company,
                    isAr:    isAr,
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator.adaptive());
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main scrollable body
// ─────────────────────────────────────────────────────────────
class _AboutUsBody extends StatelessWidget {
  final CompanyInfoCompanyEntity? company;
  final bool                      isAr;

  const _AboutUsBody({required this.company, required this.isAr});

  String _loc(String? en, String? ar) =>
      isAr ? (ar ?? en ?? '') : (en ?? ar ?? '');

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final name    = _loc(company?.nameEn,    company?.nameAr);
    final about   = _loc(company?.aboutUsEn, company?.aboutUsAr);
    final mission = _loc(company?.missionEn, company?.missionAr);
    final vision  = _loc(company?.visionEn,  company?.visionAr);
    final address = _loc(company?.addressEn, company?.addressAr);
    final phone   = company?.phone    ?? '';
    final email   = company?.email    ?? '';
    final fb      = company?.facebook?.toString();
    final ig      = company?.instagram?.toString();
    final tw      = company?.twitter?.toString();
    final imageUrl = company?.image;

    return SingleChildScrollView(

      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeroBannerWidget(name: name, image: imageUrl),

          SizedBox(height: 24.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── About ──────────────────────────────────
                if (about.isNotEmpty) ...[
                  _SectionCard(
                    icon:    Icons.info_outline_rounded,
                    title:   'about_us'.tr(),
                    content: about,
                  ),
                  SizedBox(height: 16.h),
                ],

                // ── Mission & Vision ───────────────────────
                if (mission.isNotEmpty || vision.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mission.isNotEmpty)
                        Expanded(
                          child: _PillCard(
                            icon:    Icons.flag_outlined,
                            title:   'mission'.tr(),
                            content: mission,
                          ),
                        ),
                      if (mission.isNotEmpty && vision.isNotEmpty)
                        SizedBox(width: 12.w),
                      if (vision.isNotEmpty)
                        Expanded(
                          child: _PillCard(
                            icon:    Icons.visibility_outlined,
                            title:   'vision'.tr(),
                            content: vision,
                            accent:  cs.secondary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],

                // ── Contact ────────────────────────────────
                if (phone.isNotEmpty || email.isNotEmpty || address.isNotEmpty)
                  _SectionCard(
                    icon:    Icons.contact_phone_outlined,
                    title:   "contact_us".tr(),
                    content: null,
                    child: Column(
                      children: [
                        if (phone.isNotEmpty)
                          _ContactRow(
                            icon:  Icons.phone_outlined,
                            label: phone,
                            onTap: () => _launch('tel:$phone'),
                          ),
                        if (phone.isNotEmpty && email.isNotEmpty)
                          SizedBox(height: 10.h),
                        if (email.isNotEmpty)
                          _ContactRow(
                            icon:  Icons.email_outlined,
                            label: email,
                            onTap: () => _launch('mailto:$email'),
                          ),
                        if (address.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          _ContactRow(
                            icon:  Icons.location_on_outlined,
                            label: address,
                            onTap: () {},
                          ),
                        ],
                      ],
                    ),
                  ),

                // ── Social ─────────────────────────────────
                if (fb != null || ig != null || tw != null) ...[
                  SizedBox(height: 16.h),
                  _SocialRow(facebook: fb, instagram: ig, twitter: tw),
                ],

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ─────────────────────────────────────────────────────────────
// Section card
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  content;
  final Widget?  child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.content,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final second  = cs.secondary;

    return Container(
      width:   double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: cs.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color:      primary.withOpacity(0.06),
            blurRadius: 24,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:  36.r, height: 36.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, second],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: Colors.white, size: 18.r),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize:   15.sp,
                  fontWeight: FontWeight.w700,
                  color:      cs.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            width:  32.w, height: 2.h,
            decoration: BoxDecoration(
              gradient:     LinearGradient(colors: [primary, second]),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          SizedBox(height: 14.h),
          if (content != null)
            Text(
              content!,
              style: TextStyle(
                fontSize:   14.sp,
                color:      cs.onSurface.withOpacity(0.6),
                height:     1.65,
                fontWeight: FontWeight.w400,
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pill card — mission / vision
// ─────────────────────────────────────────────────────────────
class _PillCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   content;
  final Color?   accent;

  const _PillCard({
    required this.icon,
    required this.title,
    required this.content,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final color = accent ?? cs.primary;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: cs.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color:      color.withOpacity(0.07),
            blurRadius: 20,
            offset:     const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  34.r, height: 34.r,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
              border:       Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 17.r),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              fontSize:   13.sp,
              fontWeight: FontWeight.w700,
              color:      cs.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.sp,
              color:    cs.onSurface.withOpacity(0.6),
              height:   1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Contact row
// ─────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width:  36.r, height: 36.r,
            decoration: BoxDecoration(
              color:        primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: primary, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize:   13.sp,
                color:      cs.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 13.r, color: cs.onSurface.withOpacity(0.4)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Social row
// ─────────────────────────────────────────────────────────────
class _SocialRow extends StatelessWidget {
  final String? facebook;
  final String? instagram;
  final String? twitter;

  const _SocialRow({this.facebook, this.instagram, this.twitter});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final second  = cs.secondary;

    return Container(
      padding:    EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: cs.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color:      primary.withOpacity(0.06),
            blurRadius: 24,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:  36.r, height: 36.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, second],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.share_rounded,
                    color: Colors.white, size: 18.r),
              ),
              SizedBox(width: 12.w),
              Text(
                'follow_us'.tr(),
                style: TextStyle(
                  fontSize:   15.sp,
                  fontWeight: FontWeight.w700,
                  color:      cs.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              if (facebook != null)
                _SocialButton(
                  label: 'Facebook',
                  icon:  Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                  onTap: () => _launch(facebook!),
                ),
              if (facebook != null && (instagram != null || twitter != null))
                SizedBox(width: 10.w),
              if (instagram != null)
                _SocialButton(
                  label: 'Instagram',
                  icon:  Icons.photo_camera_outlined,
                  color: const Color(0xFFE1306C),
                  onTap: () => _launch(instagram!),
                ),
              if (instagram != null && twitter != null)
                SizedBox(width: 10.w),
              if (twitter != null)
                _SocialButton(
                  label: 'Twitter',
                  icon:  Icons.alternate_email_rounded,
                  color: const Color(0xFF1DA1F2),
                  onTap: () => _launch(twitter!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Social button
// ─────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12.r),
        border:       Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18.r),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize:   12.sp,
              fontWeight: FontWeight.w600,
              color:      color,
            ),
          ),
        ],
      ),
    ),
  );
}
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecommerce_app/services/profile/profile_cubit.dart';
import 'package:ecommerce_app/services/profile/profile_state.dart';

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late ProfileCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _streetCtrl  = TextEditingController();
  final _addressCtrl = TextEditingController();

  File?   _pickedAvatar;
  String? _existingAvatarUrl;
  bool    _saving = false;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit.get(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cubit.loadUserProfile();
      _prefill();
    });
  }

  void _prefill()  {

    final user = _cubit.currentUser; // expose your cached user object
    if (user == null) return;
    _nameCtrl.text    = user.name    ?? '';
    _emailCtrl.text   = user.email   ?? '';
    _phoneCtrl.text   = user.phone   ?? '';
    _countryCtrl.text = user.country ?? '';
    _cityCtrl.text    = user.city    ?? '';
    _streetCtrl.text  = user.street  ?? '';
    _addressCtrl.text = user.address ?? '';
    _existingAvatarUrl = user.avatar;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl,
      _countryCtrl, _cityCtrl, _streetCtrl, _addressCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source:     ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedAvatar = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    await _cubit.updateProfile(
      name:    _nameCtrl.text.trim(),
      email:   _emailCtrl.text.trim(),
      phone:   _phoneCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      city:    _cityCtrl.text.trim(),
      street:  _streetCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      avatar:  _pickedAvatar,
    );

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final cs   = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (_, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('profile_updated'.tr()),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            );
            Navigator.maybePop(context);
          }
          if (state is ProfileUpdateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'something_went_wrong'.tr()),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            );
          }
        },
        child: Column(
          children: [
            // ── Custom app bar ───────────────────────────────
            _AppBar(isAr: isAr, onSave: _saving ? null : _save, saving: _saving),

            // ── Scrollable form ──────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
                  children: [
                    // Avatar picker
                    _AvatarPicker(
                      pickedFile:      _pickedAvatar,
                      existingUrl:     _existingAvatarUrl,
                      onTap:           _pickAvatar,
                    ),

                    SizedBox(height: 20.h),

                    // ── Personal info card ───────────────────
                    _SectionCard(
                      icon:  Icons.person_outline_rounded,
                      title: 'personal_info'.tr(),
                      children: [
                        _Field(
                          ctrl:  _nameCtrl,
                          label: 'full_name'.tr(),
                          icon:  Icons.badge_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'field_required'.tr()
                              : null,
                        ),
                        SizedBox(height: 14.h),
                        _Field(
                          ctrl:        _emailCtrl,
                          label:       'email'.tr(),
                          icon:        Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(v.trim());
                            return ok ? null : 'invalid_email'.tr();
                          },
                        ),
                        SizedBox(height: 14.h),
                        _Field(
                          ctrl:        _phoneCtrl,
                          label:       'phone'.tr(),
                          icon:        Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final ok = RegExp(
                                r'^\+?[0-9\s\-\(\)]{7,20}$')
                                .hasMatch(v.trim());
                            return ok ? null : 'invalid_phone'.tr();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // ── Address card ─────────────────────────
                    _SectionCard(
                      icon:  Icons.location_on_outlined,
                      title: 'address_info'.tr(),
                      children: [
                        _Field(
                          ctrl:  _countryCtrl,
                          label: 'country'.tr(),
                          icon:  Icons.public_outlined,
                        ),
                        SizedBox(height: 14.h),
                        _Field(
                          ctrl:  _cityCtrl,
                          label: 'city'.tr(),
                          icon:  Icons.location_city_outlined,
                        ),
                        SizedBox(height: 14.h),
                        _Field(
                          ctrl:  _streetCtrl,
                          label: 'street'.tr(),
                          icon:  Icons.signpost_outlined,
                        ),
                        SizedBox(height: 14.h),
                        _Field(
                          ctrl:     _addressCtrl,
                          label:    'address'.tr(),
                          icon:     Icons.home_outlined,
                          maxLines: 3,
                          hint:     'address_hint'.tr(),
                        ),
                      ],
                    ),

                    SizedBox(height: 28.h),

                    // ── Save button ──────────────────────────
                    _SaveButton(saving: _saving, onTap: _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Custom App Bar
// ─────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final bool         isAr;
  final VoidCallback? onSave;
  final bool         saving;
  const _AppBar({
    required this.isAr,
    required this.onSave,
    required this.saving,
  });

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
                // Back
                _IconBtn(
                  icon:  isAr
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                SizedBox(width: 10.w),

                // Title
                Expanded(
                  child: Text(
                    'edit_profile'.tr(),
                    style: TextStyle(
                      fontSize:   18.sp,
                      fontWeight: FontWeight.w700,
                      color:      cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // Save text button
                GestureDetector(
                  onTap: onSave,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: saving
                          ? cs.primary.withOpacity(0.5)
                          : cs.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: saving
                        ? SizedBox(
                      width:  15.r, height: 15.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color:       cs.onPrimary,
                      ),
                    )
                        : Text(
                      'save'.tr(),
                      style: TextStyle(
                        fontSize:   13.sp,
                        fontWeight: FontWeight.w700,
                        color:      cs.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1,
              color: cs.outline.withOpacity(0.10)),
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
        width:  38.r, height: 38.r,
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
// Avatar picker
// ─────────────────────────────────────────────────────────────
class _AvatarPicker extends StatelessWidget {
  final File?        pickedFile;
  final String?      existingUrl;
  final VoidCallback onTap;
  const _AvatarPicker({
    required this.pickedFile,
    required this.existingUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    ImageProvider? bg;
    if (pickedFile != null) {
      bg = FileImage(pickedFile!);
    } else if (existingUrl != null && existingUrl!.isNotEmpty) {
      bg = NetworkImage(existingUrl!);
    }

    return Center(
      child: Stack(
        children: [
          // Avatar circle
          Container(
            width:  90.r, height: 90.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withOpacity(0.08),
              border: Border.all(
                  color: cs.primary.withOpacity(0.20), width: 2),
              image: bg != null
                  ? DecorationImage(image: bg, fit: BoxFit.cover)
                  : null,
            ),
            child: bg == null
                ? Icon(Icons.person_rounded,
                size: 40.r, color: cs.primary.withOpacity(0.4))
                : null,
          ),

          // Camera badge
          Positioned(
            right:  0, bottom: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width:  28.r, height: 28.r,
                decoration: BoxDecoration(
                  color:  cs.primary,
                  shape:  BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    size: 13.r, color: cs.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section card  — matches branch card visual language
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final List<Widget> children;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

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
              // ── Left accent stripe ───────────────────────
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

              // ── Card content ─────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Row(
                        children: [
                          Container(
                            width:  32.r, height: 32.r,
                            decoration: BoxDecoration(
                              color:        primary.withOpacity(0.09),
                              borderRadius: BorderRadius.circular(9.r),
                            ),
                            child: Icon(icon, size: 16.r, color: primary),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize:   14.sp,
                              fontWeight: FontWeight.w700,
                              color:      cs.onSurface,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      // Thin divider
                      Container(
                          height: 1, color: cs.outline.withOpacity(0.10)),

                      SizedBox(height: 16.h),

                      // Fields
                      ...children,
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
// Form field
// ─────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController         ctrl;
  final String                        label;
  final IconData                      icon;
  final TextInputType                 keyboardType;
  final int                           maxLines;
  final String?                       hint;
  final String? Function(String?)?    validator;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines     = 1,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return TextFormField(
      controller:   ctrl,
      keyboardType: keyboardType,
      maxLines:     maxLines,
      validator:    validator,
      style: TextStyle(
        fontSize: 13.sp,
        color:    cs.onSurface,
      ),
      decoration: InputDecoration(
        labelText:   label,
        hintText:    hint,
        hintStyle:   TextStyle(
          fontSize: 12.sp,
          color:    cs.onSurface.withOpacity(0.35),
        ),
        labelStyle:  TextStyle(
          fontSize: 12.sp,
          color:    cs.onSurface.withOpacity(0.55),
        ),
        floatingLabelStyle: TextStyle(
          fontSize:   12.sp,
          color:      primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Icon(icon, size: 17.r, color: primary.withOpacity(0.75)),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 44.w),
        filled:      true,
        fillColor:   cs.surfaceContainerHighest.withOpacity(0.45),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w, vertical: maxLines > 1 ? 14.h : 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.outline.withOpacity(0.20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.outline.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:   BorderSide(color: cs.error, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Save button
// ─────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool         saving;
  final VoidCallback onTap;
  const _SaveButton({required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: saving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height:  50.h,
        decoration: BoxDecoration(
          color:        saving
              ? cs.primary.withOpacity(0.55)
              : cs.primary,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: saving
              ? []
              : [
            BoxShadow(
              color:      cs.primary.withOpacity(0.30),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: saving
              ? SizedBox(
            width: 22.r, height: 22.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color:       cs.onPrimary,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded,
                  size: 18.r, color: cs.onPrimary),
              SizedBox(width: 8.w),
              Text(
                'save_changes'.tr(),
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
    );
  }
}
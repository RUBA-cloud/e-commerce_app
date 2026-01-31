// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/views/auth/profile/cubit/profile_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecommerce_app/components/basic_input.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/views/auth/profile/cubit/profile_cubit.dart';


// ⚠️ هذا عندك غلط (فيه مسافة). عدليه للمسار الصحيح
import '../../../repostery /profile_repoiistery.dart';

class CustomProfileView extends StatelessWidget {
  final ProfileRepository repo;
  final UserModel userModel;

  const CustomProfileView({
    super.key,
    required this.userModel,
    required this.repo,
  });

  Future<File?> pickImageFile(ImageSource src) async {
    final picker = ImagePicker();
    final f = await picker.pickImage(source: src, maxWidth: 1200, imageQuality: 86);
    return f != null ? File(f.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final grad = [
      cs.primary,
      cs.primaryContainer.withOpacity(isDark ? 0.65 : 0.85),
    ];

    return BlocProvider(
      // ✅ استخدمي repo هنا إذا Cubit يحتاجه عندك
      create: (_) => ProfileCubit()..loadExisting(user: UserModel.currentUser!),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          return Scaffold(
            backgroundColor: cs.surface,
            body: SafeArea(
              child: Stack(
                children: [
                  angledHeader(grad),
              
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.home),
                        icon: Icon(Icons.arrow_back, color: cs.onPrimary),
                      ),
                    ),
                  ),
              
                  Positioned(
                    top: 90,
                    left: isRTL ? null : -40,
                    right: isRTL ? -40 : null,
                    child: bubble(120, cs.onPrimary.withOpacity(0.08)),
                  ),
                  Positioned(
                    top: 150,
                    left: isRTL ? null : 120,
                    right: isRTL ? 120 : null,
                    child: bubble(56, cs.onPrimary.withOpacity(0.12)),
                  ),
              
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
              
                              avatarStack(
                                context: context,
                                state: state,
                                onPick: () => _openPickSheet(context, cubit),
                                onRemove: cubit.removeImage,
                              ),
              
                              const SizedBox(height: 16),
              
                              glassCard(
                                context,
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                                  child: _buildForm(context, cubit, state),
                                ),
                              ),
              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openPickSheet(BuildContext context, ProfileCubit cubit) async {
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: cs.primary),
              title: Text('choose_from_gallery'.tr),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImageFile(ImageSource.gallery);
                if (file != null) cubit.setImageFile(file);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: cs.primary),
                title: Text('take_photo'.tr),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFile(ImageSource.camera);
                  if (file != null) cubit.setImageFile(file);
                },
              ),
            if (cubit.state.imageBytes != null || (cubit.state.imageUrl ?? '').isNotEmpty)
              ListTile(
                leading: Icon(Icons.delete_outline, color: cs.error),
                title: Text('remove'.tr),
                onTap: () {
                  Navigator.pop(context);
                  cubit.removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  // ✅ BottomSheet فيها SelectState
  void _openCountryCitySheet(BuildContext context, ProfileCubit cubit) {
    final cs = Theme.of(context).colorScheme;

    String selectedCountry = cubit.countryCtrl.text;
    String selectedCity = cubit.cityCtrl.text;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'choose_location'.tr, // إذا ما عندك ترجمة غيّري النص
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),

                // ✅ picker package 0.1.6
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
                  ),
                  child: SelectState(
                    
                    onCountryChanged: (value) {
                      selectedCountry = value;
                   
                      selectedCity = '';
                    },
                    onStateChanged: (value) {
                      selectedCity = '';
                    },
                    onCityChanged: (value) {
                      selectedCity = value;
                    },
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (selectedCountry.trim().isEmpty || selectedCity.trim().isEmpty) {
                        // اظهر خطأ خفيف
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('please_select_country_city'.tr)),
                        );
                        return;
                      }

                      cubit.setCountryStateCity(
                        country: selectedCountry.trim(),
                        city: selectedCity.trim(),
                      );

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text('confirm'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, ProfileCubit cubit, ProfileState state) {
    final twoCols = MediaQuery.of(context).size.width >= 720;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            chipBadge(
              context: context,
              icon: Icons.person_outline,
              label: 'edit_profile'.tr,
            ),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final file = await pickImageFile(ImageSource.gallery);
                    if (file != null) cubit.setImageFile(file);
                  },
                  icon: const Icon(Icons.photo),
                  label: Text('choose_photo'.tr),
                ),
                if (!kIsWeb)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final file = await pickImageFile(ImageSource.camera);
                      if (file != null) cubit.setImageFile(file);
                    },
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text('camera'.tr),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        sectionHeader(context, 'personal_info'.tr),
        const SizedBox(height: 12),

        if (twoCols)
          Row(
            children: [
              Expanded(
                child: profileLabeledInput(
                  context: context,
                  controller: cubit.nameCtrl,
                  label: 'full_name'.tr,
                  onChanged: cubit.updateName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: profileLabeledInput(
                  context: context,
                  controller: cubit.emailCtrl,
                  label: 'email'.tr,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: cubit.updateEmail,
                ),
              ),
            ],
          )
        else ...[
          profileLabeledInput(
            context: context,
            controller: cubit.nameCtrl,
            label: 'full_name'.tr,
            onChanged: cubit.updateName,
          ),
          const SizedBox(height: 12),
          profileLabeledInput(
            context: context,
            controller: cubit.emailCtrl,
            label: 'email'.tr,
            keyboardType: TextInputType.emailAddress,
            onChanged: cubit.updateEmail,
          ),
        ],

        const SizedBox(height: 24),

        sectionHeader(context, 'contact'.tr),
        const SizedBox(height: 12),

        if (twoCols)
          Row(
            children: [
              Expanded(
                child: profileLabeledInput(
                  context: context,
                  controller: cubit.phoneCtrl,
                  label: 'phone'.tr,
                  keyboardType: TextInputType.phone,
                  onChanged: cubit.updatePhone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: profileLabeledInput(
                  context: context,
                  controller: cubit.addressCtrl,
                  label: 'address'.tr,
                  onChanged: cubit.updateAddress,
                ),
              ),
            ],
          )
        else ...[
          profileLabeledInput(
            context: context,
            controller: cubit.phoneCtrl,
            label: 'phone'.tr,
            keyboardType: TextInputType.phone,
            onChanged: cubit.updatePhone,
          ),
          const SizedBox(height: 12),
          profileLabeledInput(
            context: context,
            controller: cubit.addressCtrl,
            label: 'address'.tr,
            onChanged: cubit.updateAddress,
          ),
        ],

        const SizedBox(height: 12),

        profileLabeledInput(
          context: context,
          controller: cubit.streetCtrl,
          label: 'street'.tr,
          onChanged: cubit.updateStreet,
        ),

        const SizedBox(height: 14),

        // ✅ Country & City (tap to choose)
        InkWell(
          onTap: () => _openCountryCitySheet(context, cubit),
          child: AbsorbPointer(
            child: profileLabeledInput(
              context: context,
              controller: cubit.countryCtrl,
              label: 'country'.tr,
              onChanged: cubit.updateCountry,
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _openCountryCitySheet(context, cubit),
          child: AbsorbPointer(
            child: profileLabeledInput(
              context: context,
              controller: cubit.cityCtrl,
              label: 'city'.tr,
              onChanged: cubit.updateCity,
            ),
          ),
        ),

        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: errorBanner(context, state.error),
          ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.status == ProfileStatus.loading
                ? null
                : () async {
                    await cubit.saveProfile();

                    if (!context.mounted) return;

                    final ok = cubit.state.status == ProfileStatus.idle &&
                        cubit.state.error.isEmpty;

                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('profile_saved'.tr)),
                      );
                    }
                  },
            icon: state.status == ProfileStatus.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              state.status == ProfileStatus.loading ? 'saving'.tr : 'save'.tr,
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        )
      ],
    );
  }

  // ---------------- UI HELPERS (كما عندك) ----------------

  static Widget angledHeader(List<Color> colors) {
    return ClipPath(
      clipper: _AngleClipper(),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
      ),
    );
  }

  static Widget bubble(double size, Color c) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: c, blurRadius: 24, spreadRadius: 4)],
      ),
    );
  }

  static Widget glassCard(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color cardColor =
        isDark ? cs.surfaceVariant.withOpacity(0.92) : cs.surface.withOpacity(0.98);

    final Color borderColor =
        isDark ? cs.outlineVariant.withOpacity(0.7) : cs.outline.withOpacity(0.3);

    final Color shadowColor =
        isDark ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.12);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 28, offset: const Offset(0, 18)),
        ],
      ),
      child: child,
    );
  }

  static Widget chipBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(28)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static Widget sectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 26,
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  static Widget avatarStack({
    required BuildContext context,
    required ProfileState state,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final cs = Theme.of(context).colorScheme;
    const double size = 120;

    Widget avatar;
    if (state.imageBytes != null) {
      avatar = CircleAvatar(
        backgroundImage: FileImage(state.imageBytes!),
        radius: size / 2,
      );
    } else if ((state.imageUrl ?? '').isNotEmpty) {
      avatar = CircleAvatar(
        backgroundImage: NetworkImage(state.imageUrl!),
        radius: size / 2,
      );
    } else {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: cs.primary.withOpacity(.18),
        child: Icon(Icons.person, size: 56, color: cs.onPrimary),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(colors: [cs.primary, cs.secondary, cs.primary, cs.secondary]),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surface),
            child: SizedBox(width: size, height: size, child: avatar),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            roundMiniButton(
              context: context,
              icon: Icons.edit,
              tooltip: 'Edit',
              onTap: onPick,
              color: cs.primary,
            ),
            if (state.imageBytes != null || (state.imageUrl ?? '').isNotEmpty)
              roundMiniButton(
                context: context,
                icon: Icons.delete_outline,
                tooltip: 'Remove',
                onTap: onRemove,
                color: cs.error,
              ),
          ],
        ),
      ],
    );
  }

  static Widget roundMiniButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: cs.onPrimary.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 18, color: cs.onPrimary),
          ),
        ),
      ),
    );
  }

  static Widget errorBanner(BuildContext context, String text) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget profileLabeledInput({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType? keyboardType,
  void Function(String)? onChanged,
}) {
  final hintText = hint ?? label;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.caption(context)),
      const SizedBox(height: 6),
      BasicInput(
        controller: controller,
        label: label,
        hintText: hintText,
        keyboardType: keyboardType,
        isBorder: true,
        radius: 18,
        onChanged: onChanged,
      ),
    ],
  );
}

class _AngleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 60)
      ..lineTo(size.width * .55, size.height)
      ..lineTo(size.width, size.height - 70)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
import 'package:ecommerce_app/views/auth/profile/cubit/profile_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/utils.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecommerce_app/components/basic_input.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/views/auth/profile/cubit/profile_cubit.dart';

class CustomProfileView extends StatelessWidget {
  final ProfileRepository repo;
  final UserModel userModel;

  const CustomProfileView({
    super.key,
    required this.userModel,
    required this.repo,
  });

  // ---- Helpers ----
  Future<Uint8List?> _pickBytes(ImageSource src) async {
    final picker = ImagePicker();
    final XFile? f = await picker.pickImage(
      source: src,
      maxWidth: 1200,
      imageQuality: 86,
    );
    if (f == null) return null;
    return f.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final grad = [cs.primary, cs.primaryContainer.withOpacity(.85)];

    return BlocProvider(
      create: (_) => ProfileCubit()..loadExisting(user: userModel),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (p, c) => p != c,
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          if (cubit.nameCtrl.text != state.name) {
            cubit.nameCtrl.text = state.name;
          }
          if (cubit.emailCtrl.text != state.email) {
            cubit.emailCtrl.text = state.email;
          }
          if (cubit.phoneCtrl.text != state.phone) {
            cubit.phoneCtrl.text = state.phone;
          }
          if (cubit.addressCtrl.text != state.address) {
            cubit.addressCtrl.text = state.address;
          }
          if (cubit.streetCtrl.text != state.street) {
            cubit.streetCtrl.text = state.street;
          }

          return Scaffold(
            backgroundColor: cs.surface,
            body: Stack(
              children: [
                CustomProfileView.angledHeader(grad),
                Positioned(
                  top: 90,
                  left: isRTL ? null : -40,
                  right: isRTL ? -40 : null,
                  child: CustomProfileView.bubble(
                    120,
                    Colors.white.withOpacity(.06),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: isRTL ? null : 120,
                  right: isRTL ? 120 : null,
                  child: CustomProfileView.bubble(
                    56,
                    Colors.white.withOpacity(.08),
                  ),
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
                            CustomProfileView.avatarStack(
                              state: state,
                              onPick: () => _openPickSheet(context, cubit),
                              onRemove: () => cubit.removeImage(),
                            ),
                            const SizedBox(height: 16),
                            CustomProfileView.glassCard(
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  18,
                                  18,
                                  20,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final twoCols = c.maxWidth >= 720;
                                    final actionBar = Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      children: [
                                        CustomProfileView.chipBadge(
                                          icon: Icons.person_outline,
                                          label: 'edit_profile'.tr,
                                        ),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            FilledButton.icon(
                                              onPressed: () async {
                                                final bytes = await _pickBytes(
                                                  ImageSource.gallery,
                                                );
                                                if (bytes != null) {
                                                  cubit.setImageBytes(bytes);
                                                }
                                              },
                                              icon: const Icon(Icons.photo),
                                              label: Text(
                                                'choose_photo'.trParams({
                                                  'default': 'Choose Photo',
                                                }),
                                              ),
                                            ),
                                            if (!kIsWeb)
                                              OutlinedButton.icon(
                                                onPressed: () async {
                                                  final bytes =
                                                      await _pickBytes(
                                                    ImageSource.camera,
                                                  );
                                                  if (bytes != null) {
                                                    cubit.setImageBytes(bytes);
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.photo_camera_outlined,
                                                ),
                                                label: Text(
                                                  'camera'.trParams({
                                                    'default': 'Camera',
                                                  }),
                                                ),
                                              ),
                                            if (state.imageBytes != null ||
                                                (state.imageUrl ?? '')
                                                    .isNotEmpty)
                                              TextButton.icon(
                                                onPressed: () =>
                                                    cubit.removeImage(),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                label: Text(
                                                  'remove'.trParams({}),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    );

                                    final personal = Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 12),
                                        CustomProfileView.sectionHeader(
                                          'personal_info'.trParams({
                                            'default': 'Personal Info',
                                          }),
                                        ),
                                        const SizedBox(height: 12),
                                        if (twoCols)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: BasicInput(
                                                  controller: cubit.nameCtrl,
                                                  label: "full_name".tr,
                                                  radius: 18,
                                                  onChanged: cubit.updateName,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: BasicInput(
                                                  controller: cubit.emailCtrl,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  radius: 18,
                                                  label: "email".tr,
                                                  onChanged: cubit.updateEmail,
                                                ),
                                              ),
                                            ],
                                          )
                                        else ...[
                                          BasicInput(
                                            controller: cubit.nameCtrl,
                                            label: "full_name".tr,
                                            radius: 18,
                                            onChanged: cubit.updateName,
                                          ),
                                          const SizedBox(height: 12),
                                          BasicInput(
                                            controller: cubit.emailCtrl,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            radius: 18,
                                            label: "email".tr,
                                            onChanged: cubit.updateEmail,
                                          ),
                                        ],
                                      ],
                                    );

                                    final contact = Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 18),
                                        CustomProfileView.sectionHeader(
                                          'contact'.trParams({
                                            'default': 'Contact',
                                          }),
                                        ),
                                        const SizedBox(height: 12),
                                        if (twoCols)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: BasicInput(
                                                  controller: cubit.phoneCtrl,
                                                  label: 'phone'.tr,
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  isBorder: true,
                                                  radius: 18,
                                                  onChanged: cubit.updatePhone,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: BasicInput(
                                                  controller: cubit.addressCtrl,
                                                  label: 'address'.tr,
                                                  keyboardType: TextInputType
                                                      .streetAddress,
                                                  isBorder: true,
                                                  radius: 18,
                                                  onChanged:
                                                      cubit.updateAddress,
                                                ),
                                              ),
                                            ],
                                          )
                                        else ...[
                                          BasicInput(
                                            controller: cubit.phoneCtrl,
                                            label: 'phone'.tr,
                                            keyboardType: TextInputType.phone,
                                            isBorder: true,
                                            radius: 18,
                                            onChanged: cubit.updatePhone,
                                          ),
                                          const SizedBox(height: 12),
                                          BasicInput(
                                            controller: cubit.addressCtrl,
                                            label: 'address'.tr,
                                            keyboardType:
                                                TextInputType.streetAddress,
                                            isBorder: true,
                                            radius: 18,
                                            onChanged: cubit.updateAddress,
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        BasicInput(
                                          controller: cubit.streetCtrl,
                                          label: 'street'.tr,
                                          keyboardType:
                                              TextInputType.streetAddress,
                                          isBorder: true,
                                          radius: 18,
                                          onChanged: cubit.updateStreet,
                                        ),
                                      ],
                                    );

                                    final errorBox = state.error.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child:
                                                CustomProfileView.errorBanner(
                                              state.error,
                                            ),
                                          )
                                        : const SizedBox.shrink();

                                    final saveBtn = Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: state.status ==
                                                  ProfileStatus.loading
                                              ? null
                                              : () async {
                                                  await context
                                                      .read<ProfileCubit>()
                                                      .saveProfile((s) async {
                                                    String? avatarUrl =
                                                        s.imageUrl;
                                                    if (s.imageBytes != null) {
                                                      avatarUrl = await repo
                                                          .uploadAvatar(
                                                        s.imageBytes!,
                                                      );
                                                    }
                                                    await repo.saveProfileData(
                                                      id: "1",
                                                      name: s.name.trim(),
                                                      email: s.email.trim(),
                                                      phone: s.phone.trim(),
                                                      address: s.address.trim(),
                                                      street: s.street.trim(),
                                                      avatarUrl: avatarUrl,
                                                    );
                                                  });

                                                  if (!context.mounted) return;
                                                  final ok = context
                                                              .read<
                                                                  ProfileCubit>()
                                                              .state
                                                              .status ==
                                                          ProfileStatus.idle &&
                                                      context
                                                          .read<ProfileCubit>()
                                                          .state
                                                          .error
                                                          .isEmpty;
                                                  if (ok) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'profile_saved'.tr,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                          icon: state.status ==
                                                  ProfileStatus.loading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(Icons.save_outlined),
                                          label: Text(
                                            state.status ==
                                                    ProfileStatus.loading
                                                ? 'saving'.tr
                                                : 'save'.tr,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        actionBar,
                                        personal,
                                        contact,
                                        errorBox,
                                        saveBtn,
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Opacity(
                              opacity: .72,
                              child: Text(
                                ''.tr,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  'choose_from_gallery'.trParams({
                    'default': 'Choose from gallery',
                  }),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final bytes = await _pickBytes(ImageSource.gallery);
                  if (bytes != null) cubit.setImageBytes(bytes);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text('take_photo'.trParams({'default': ''})),
                  onTap: () async {
                    Navigator.pop(context);
                    final bytes = await _pickBytes(ImageSource.camera);
                    if (bytes != null) cubit.setImageBytes(bytes);
                  },
                ),
              if (cubit.state.imageBytes != null ||
                  (cubit.state.imageUrl ?? '').isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text('remove'.trParams({'default': 'Remove'})),
                  onTap: () {
                    Navigator.pop(context);
                    cubit.removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Static Widget Methods ----
  static Widget angledHeader(List<Color> gradientColors) {
    return ClipPath(
      clipper: _AngleClipper(),
      child: Container(
        height: 260.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
      ),
    );
  }

  static Widget bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 24, spreadRadius: 4)],
      ),
    );
  }

  static Widget glassCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget chipBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.blue.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(.9)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static Widget sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
        ),
      ],
    );
  }

  static Widget avatarStack({
    required ProfileState state,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    const double size = 120;
    Widget avatar;
    if (state.imageBytes != null) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundImage: MemoryImage(state.imageBytes!),
      );
    } else if ((state.imageUrl ?? '').isNotEmpty) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(state.imageUrl!),
      );
    } else {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.blue.withOpacity(.08),
        child: const Icon(Icons.person, size: 56, color: Colors.white),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Colors.blue,
                Colors.blueAccent,
                Colors.blue,
                Colors.blueAccent,
              ],
              stops: const [0.0, .45, .55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.9),
            ),
            child: SizedBox(width: size, height: size, child: avatar),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            CustomProfileView.roundMiniButton(
              icon: Icons.edit,
              tooltip: 'Edit',
              onTap: onPick,
              color: Colors.blue,
            ),
            if (state.imageBytes != null || (state.imageUrl ?? '').isNotEmpty)
              CustomProfileView.roundMiniButton(
                icon: Icons.delete_outline,
                tooltip: 'Remove',
                onTap: onRemove,
                color: Colors.red,
              ),
          ],
        ),
      ],
    );
  }

  static Widget roundMiniButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  static Widget errorBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AngleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path()
      ..lineTo(0, size.height - 60)
      ..lineTo(size.width * .55, size.height)
      ..lineTo(size.width, size.height - 70)
      ..lineTo(size.width, 0)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ignore_for_file: deprecated_member_use

import 'package:ecommerce_app/views/settings/cubit/settings_cubit.dart';
import 'package:ecommerce_app/views/settings/cubit/settings_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => SettingsCubit()..loadSettings(),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final cubit = context.read<SettingsCubit>();
            final isDark = state.themeMode == ThemeMode.dark;
            final notificationsEnabled = state.notificationsEnabled ?? true;

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ===== Header card =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.12),
                          colorScheme.primaryContainer.withOpacity(0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          
                            color: colorScheme.primary.withOpacity(0.15),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'settings'.tr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'settings_subtitle'.trParams(
                                  {'app': 'ecommerce_app'},
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== Appearance section =====
                  _SectionTitle(
                    icon: Icons.color_lens_outlined,
                    title: 'appearance'.tr,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorScheme.surface,
                      boxShadow: [
                        if (theme.brightness == Brightness.light)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value: isDark,
                          onChanged: (_) => cubit.toggleTheme(),
                          title: Text('dark_mode'.tr),
                          subtitle: Text(
                            isDark
                                ? 'dark_mode_on_desc'.tr
                                : 'dark_mode_off_desc'.tr,
                          ),
                          secondary: Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.dark_mode_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== Notifications & language section =====
                  _SectionTitle(
                    icon: Icons.settings_applications_outlined,
                    title: 'general'.tr,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorScheme.surface,
                      boxShadow: [
                        if (theme.brightness == Brightness.light)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.15),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== Notifications toggle =====
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: notificationsEnabled,
                          onChanged: (val) =>
                              cubit.toggleNotifications(val),
                          title: Text('notifications'.tr),
                          subtitle: Text('notifications_desc'.tr),
                          secondary: Icon(
                            notificationsEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_outlined,
                          ),
                        ),

                        const Divider(height: 24),

                        // ===== Language selector =====
                        Row(
                          children: [
                            Icon(
                              Icons.language_rounded,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'language'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'language_desc'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          style: ButtonStyle(
                            visualDensity:
                                VisualDensity.compact,
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                          ),
                          segments: <ButtonSegment<String>>[
                            ButtonSegment<String>(
                              value: 'en',
                              label: Text('english'.tr),
                              icon: const Icon(Icons.text_fields),
                            ),
                            ButtonSegment<String>(
                              value: 'ar',
                              label: Text('arabic'.tr),
                              icon: const Icon(Icons.translate),
                            ),
                          ],
                          selected: {state.locale.languageCode},
                          onSelectionChanged: (s) =>
                              cubit.setLanguage(s.first, context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Simple reusable section title with icon
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primary.withOpacity(0.12),
          ),
          child: Icon(
            icon,
            size: 18,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

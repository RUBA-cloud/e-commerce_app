import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreTab extends StatelessWidget {
  final VoidCallback? onLogout;
  const MoreTab({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MoreTab.headerCard(context),
        const SizedBox(height: 16),
        MoreTab.actionCard(
          icon: Icons.settings_outlined,
          title: 'settings'.tr,
          subtitle: 'app_settings_description'.trParams({'app': 'app_name'.tr}),
          onTap: () => Get.toNamed(AppRoutes.settings),
          context: context,
        ),
        const SizedBox(height: 12),
        MoreTab.actionCard(
          icon: Icons.info_outline,
          title: 'about_us'.tr,
          subtitle: 'about_us_descripation'.tr,
          onTap: () => Get.toNamed(AppRoutes.aboutUs),
          context: context,
        ),
        const SizedBox(height: 12),
        MoreTab.actionCard(
          icon: Icons.info_outline,
          title: 'branches'.tr,
          subtitle: 'about_us_descripation'.tr,
          onTap: () => Get.toNamed(AppRoutes.branch),
          context: context,
        ),
        MoreTab.actionCard(
          icon: Icons.logout,
          title: 'logout'.tr,
          subtitle: 'logout_subtitle'.tr,
          onTap: () => _confirmLogout(context, onLogout),
          color: theme.colorScheme.errorContainer,
          iconColor: theme.colorScheme.error,
          titleColor: theme.colorScheme.error,
          context: context,
        ),
        const SizedBox(height: 24),
        MoreTab.footerVersion(context),
      ],
    );
  }

  static Future<void> _confirmLogout(
    BuildContext context,
    VoidCallback? onLogout,
  ) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('logout'.tr),
        content: Text('are_you_sure_logout'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (onLogout != null) await Future.sync(onLogout);
        Get.snackbar(
          'logout'.tr,
          'logged_out_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        // TODO: navigate to your login/splash route if needed
        // Get.offAllNamed(AppRoutes.login);
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(.08),
          colorText: Colors.red.shade800,
        );
      }
    }
  }

  static Widget headerCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 28, child: const Icon(Icons.person, size: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'profile_descripation'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.profile),
              icon: const Icon(Icons.chevron_right),
              tooltip: 'open'.tr,
            ),
          ],
        ),
      ),
    );
  }

  static Widget actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
    Color? titleColor,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final bg = color ?? theme.colorScheme.surface;
    final tColor = titleColor ?? theme.colorScheme.onSurface;

    return Card(
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (iconColor ?? theme.colorScheme.primary).withOpacity(
                    0.12,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  static Widget footerVersion(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        '${'version'.tr ?? 'Version'} 1.0.0',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

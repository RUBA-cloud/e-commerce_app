import 'package:ecommerce_app/views/settings/cubit/settings_cubit.dart';
import 'package:ecommerce_app/views/settings/cubit/settings_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr), centerTitle: true),
      body: BlocProvider(
        create: (context) => SettingsCubit(),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final cubit = context.read<SettingsCubit>();
            return ListView(padding: const EdgeInsets.all(16), children: [
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile.adaptive(
                  value: state.themeMode == ThemeMode.dark,
                  onChanged: (_) => cubit.toggleTheme(),
                  title: Text('dark_mode'.tr),
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: SwitchListTile.adaptive(
                          value: state.notificationsEnabled ?? true,
                          onChanged: (val) => cubit.toggleNotifications(val),
                          title: Text('notifications'.tr),
                          subtitle: Text('notifications_desc'.tr),
                          secondary: const Icon(
                            Icons.notifications_active_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.language),
                          const SizedBox(width: 12),
                          Text(
                            'language'.tr,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: <ButtonSegment<String>>[
                          ButtonSegment<String>(
                            value: 'en',
                            label: Text('english'.tr),
                          ),
                          ButtonSegment<String>(
                            value: 'ar',
                            label: Text('arabic'.tr),
                          ),
                        ],
                        selected: {state.locale.languageCode},
                        onSelectionChanged: (s) =>
                            cubit.setLanguage(s.first, context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]);
          },
        ),
      ),
    );
  }
}

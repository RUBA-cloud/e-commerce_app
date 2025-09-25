import 'package:ecommerce_app/models/about_us.dart';
import 'package:ecommerce_app/views/aboutUs/cubit/about_us_cubit.dart';
import 'package:ecommerce_app/views/aboutUs/cubit/about_us_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('about_us'.tr), centerTitle: true),
      body: BlocProvider(
        create: (context) => AboutCubit()..load(),
        child: BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            switch (state.status) {
              case AboutStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case AboutStatus.error:
                return AboutUsPage.errorView(
                  message: state.error ?? 'error'.tr,
                  onRetry: () => context.read<AboutCubit>().load(),
                );
              case AboutStatus.loaded:
                final info = state.info!;
                return content(info: info, context: context);
            }
          },
        ),
      ),
    );
  }

  Widget content({
    required AboutUsInfoModel info,
    required BuildContext context,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: (Get.locale?.languageCode ?? 'en') == 'ar'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: (Get.locale?.languageCode ?? 'en') == 'ar'
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    info.companyName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.tagline,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          infoCard(
            title: 'mission'.tr,
            body: (Get.locale?.languageCode ?? 'en') == 'ar'
                ? info.missionAr
                : info.missionEn,
          ),
          const SizedBox(height: 12),
          infoCard(
            title: 'vision'.tr,
            body: (Get.locale?.languageCode ?? 'en') == 'ar'
                ? info.visionAr
                : info.visionEn,
          ),
          const SizedBox(height: 12),
          infoCard(
            title: 'values'.tr,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: info.values
                  .map(
                    (v) => Chip(
                      label: Text(v),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          infoCard(
            title: 'who_we_are'.tr,
            body: (Get.locale?.languageCode ?? 'en') == 'ar'
                ? info.descriptionAr
                : info.descriptionEn,
          ),
          const SizedBox(height: 12),
          infoCard(
            title: 'contact'.tr,
            child: Column(
              crossAxisAlignment: (Get.locale?.languageCode ?? 'en') == 'ar'
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                kv(context, 'email'.tr, info.email),
                const SizedBox(height: 6),
                kv(context, 'phone'.tr, info.phone),
                const SizedBox(height: 6),
                kv(context, 'address'.tr, info.address),
                const SizedBox(height: 6),
                kv(context, 'website'.tr, info.website),
              ],
            ),
          ),
          const SizedBox(height: 12),
          infoCard(
            title: 'social'.tr,
            child: Column(
              crossAxisAlignment: (Get.locale?.languageCode ?? 'en') == 'ar'
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                socialRow(
                  Icons.camera_alt_outlined,
                  'instagram'.tr,
                  info.social['instagram'] ?? '',
                ),
                socialRow(
                  Icons.camera_alt_outlined,
                  'facebook'.tr,
                  info.social['facebook'] ?? '',
                ),
                const SizedBox(height: 8),
                socialRow(
                  Icons.alternate_email,
                  'twitter'.tr,
                  info.social['twitter'] ?? '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget kv(BuildContext context, String k, String v) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(v)),
      ],
    );
  }

  Widget socialRow(IconData icon, String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Text('$label: $url')),
      ],
    );
  }

  Widget infoCard({required String title, String? body, Widget? child}) {
    assert(body != null || child != null, 'provide_body'.tr);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (body != null) Text(body),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  static Widget errorView({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('failed_to_load'.tr),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

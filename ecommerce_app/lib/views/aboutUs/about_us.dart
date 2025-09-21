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
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text('about_us'.tr), centerTitle: true),
      body: BlocProvider(
        // Ensure initial data is fetched
        create: (context) => AboutCubit()..load(),
        // If your cubit needs a repo: AboutCubit(MockAboutRepository())..load(),
        child: BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            switch (state.status) {
              case AboutStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case AboutStatus.error:
                return AboutUsPage.errorView(
                  message: state.error ?? 'Error',
                  onRetry: () => context.read<AboutCubit>().load(),
                  isAr: isAr,
                );
              case AboutStatus.loaded:
                final info = state.info!;
                return content(info: info, isAr: isAr, context: context);
            }
          },
        ),
      ),
    );
  }

  Widget content({
    required AboutUsInfoModel info,
    required bool isAr,
    required BuildContext context,
  }) {
    String t(String en, String ar) => isAr ? ar : en;
    const spacing = 12.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: isAr
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
                crossAxisAlignment: isAr
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
            title: t('Mission', 'الرسالة'),
            body: t(info.missionEn, info.missionAr),
          ),
          const SizedBox(height: 12),

          infoCard(
            title: t('Vision', 'الرؤية'),
            body: t(info.visionEn, info.visionAr),
          ),
          const SizedBox(height: 12),

          infoCard(
            title: t('Values', 'القيم'),
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
            title: t('Who we are', 'من نحن'),
            body: t(info.descriptionEn, info.descriptionAr),
          ),
          const SizedBox(height: 12),

          infoCard(
            title: t('Contact', 'التواصل'),
            child: Column(
              crossAxisAlignment: isAr
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                kv(context, t('Email', 'البريد الإلكتروني'), info.email),
                const SizedBox(height: 6),
                kv(context, t('Phone', 'الهاتف'), info.phone),
                const SizedBox(height: 6),
                kv(context, t('Address', 'العنوان'), info.address),
                const SizedBox(height: 6),
                kv(context, t('Website', 'الموقع'), info.website),
              ],
            ),
          ),
          const SizedBox(height: 12),

          infoCard(
            title: t('Social', 'روابط التواصل'),
            child: Column(
              crossAxisAlignment: isAr
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                AboutUsPage.socialRow(
                  Icons.camera_alt_outlined,
                  'Instagram',
                  info.social['instagram'] ?? '',
                ),
                const SizedBox(height: 8),
                AboutUsPage.socialRow(
                  Icons.alternate_email,
                  'X / Twitter',
                  info.social['twitter'] ?? '',
                ),
              ],
            ),
          ),

          const SizedBox(height: spacing),
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

  static Widget socialRow(IconData icon, String label, String url) {
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
    assert(body != null || child != null, 'Provide body or child');
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
    required bool isAr,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isAr ? 'فشل التحميل' : 'Failed to load'),
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
              label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

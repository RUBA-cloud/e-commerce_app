import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/models/branches.dart';
import 'package:ecommerce_app/views/branches/cubit/branches_cubit.dart';
import 'package:ecommerce_app/views/branches/cubit/branches_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BranchesPage extends StatelessWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text('company_branches'.tr), centerTitle: true),
      body: BlocProvider(
        create: (context) => BranchesCubit()..load(),
        child: BlocBuilder<BranchesCubit, BranchesState>(
          builder: (context, state) {
            switch (state.status) {
              case BranchesStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case BranchesStatus.error:
                return BranchesPage.errorView(
                  message: state.error ?? 'error'.tr,
                  onRetry: () => context.read<BranchesCubit>().load(),
                );
              case BranchesStatus.loaded:
                final list = state.branches;
                if (list.isEmpty) {
                  return Center(child: Text('no_branches_found'.tr));
                }
                return LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 820;
                    return GridView.builder(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (_, i) =>
                          BranchesPage.branchCard(branch: list[i], isAr: isAr),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }

  static Widget branchCard({required BranchModel branch, required bool isAr}) {
    List<String> days = [
      'monday'.tr,
      'tuesday'.tr,
      'wednesday'.tr,
      'thursday'.tr,
      'friday'.tr,
      'saturday'.tr,
      'sunday'.tr,
    ];

    final open = branch.isOpenNow(DateTime.now());
    final theme = Get.context != null ? Theme.of(Get.context!) : ThemeData();
    final openColor = open ? greenColor : theme.colorScheme.error;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Text(
                    branch.displayName(isAr: isAr),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: openColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: openColor),
                    ),
                    child: Text(
                      open ? 'open_now'.tr : 'closed'.tr,
                      style: TextStyle(
                        color: openColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Address
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    branch.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hours
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 6),
                Text('${branch.hoursFrom} - ${branch.hoursTo}'),
                const Spacer(),
                Text('working_days'.tr, style: theme.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 8),

            // Days as chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: branch.workingDays.map((d) {
                final idx = (d - 1).clamp(0, 6);

                return Chip(
                  label: Text(days[idx]),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => BranchesPage.openMaps(branch),
                  icon: const Icon(Icons.map_outlined),
                  label: Text('open_map'.tr),
                ),
                const SizedBox(width: 8),
                if (branch.lat != null && branch.lng != null)
                  Text(
                    '${branch.lat!.toStringAsFixed(4)}, ${branch.lng!.toStringAsFixed(4)}',
                    style: theme.textTheme.labelSmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> openMaps(BranchModel b) async {
    String url;
    if (b.lat != null && b.lng != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=${b.lat},${b.lng}';
    } else {
      final q = Uri.encodeComponent(b.address);
      url = 'https://www.google.com/maps/search/?api=1&query=$q';
    }
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
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
              style: TextStyle(color: Theme.of(Get.context!).colorScheme.error),
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

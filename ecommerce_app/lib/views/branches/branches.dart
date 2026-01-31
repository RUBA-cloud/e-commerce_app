import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/models/branches.dart';
import 'package:ecommerce_app/views/branches/cubit/branches_cubit.dart';
import 'package:ecommerce_app/views/branches/cubit/branches_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BranchesPage extends StatelessWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text('company_branches'.tr), centerTitle: true),
      body: BlocProvider(
        create: (_) => BranchesCubit()..load(),
        child: BlocBuilder<BranchesCubit, BranchesState>(
          builder: (context, state) {
            switch (state.status) {
              case BranchesStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case BranchesStatus.error:
                return _errorView(
                  context,
                  state.error ?? 'error'.tr,
                  () => context.read<BranchesCubit>().load(),
                );
              case BranchesStatus.loaded:
                final list = state.branches;
                if (list.isEmpty) {
                  return Center(child: Text('no_branches_found'.tr));
                }
                return LayoutBuilder(
                  builder: (ctx, c) {
                    final isWide = c.maxWidth >= 860;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisExtent: 230,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (_, i) => _branchCard(
                        context,
                        list[i],
                        isAr,
                        () => context.read<BranchesCubit>().openMaps(list[i]),
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }

  Widget _branchCard(
    BuildContext context,
    BranchModel branch,
    bool isAr,
    VoidCallback onOpenMap,
  ) {
    final theme = Theme.of(context);
    final open = branch.isOpenNow(DateTime.now());
    final statusColor = open ? greenColor : theme.colorScheme.error;

    final from = branch.hoursFrom.trim();
    final to = branch.hoursTo.trim();
    final showHours = from.isNotEmpty && to.isNotEmpty;

    final workingDays = branch.workingDays; // List<int>
debugPrint('Branch "${branch.nameEn}" working days: $workingDays');
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onOpenMap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      branch.displayName(isAr: isAr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusPill(open ? 'open_now'.tr : 'closed'.tr, statusColor),
                ],
              ),
              const SizedBox(height: 10),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      branch.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Hours + label
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    showHours ? '$from - $to' : '—',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text('working_days'.tr, style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 10),

              // ✅ Working days chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: workingDays.isEmpty
                    ? <Widget>[
                        _dayChip(context, isAr ? 'لا توجد أيام' : 'No days'),
                      ]
                    : workingDays.map((d) {
                        final label = _weekdayLabel(d, isAr);
                        return _dayChip(context, label);
                      }).toList(),
              ),

              const Spacer(),

              // Map + coords
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onOpenMap,
                    icon: const Icon(Icons.map_outlined),
                    label: Text('open_map'.tr),
                  ),
                  const SizedBox(width: 8),
                  if (branch.lat != null && branch.lng != null)
                    Flexible(
                      child: Text(
                        '${branch.lat!.toStringAsFixed(4)}, ${branch.lng!.toStringAsFixed(4)}',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Map ISO weekday (1=Mon..7=Sun) to label
  String _weekdayLabel(int isoDay, bool isAr) {
    // 1=Mon..7=Sun
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const ar = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

    if (isoDay < 1 || isoDay > 7) return isAr ? 'غير معروف' : 'Unknown';
    return isAr ? ar[isoDay - 1] : en[isoDay - 1];
  }

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _dayChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(text, style: theme.textTheme.labelMedium),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _errorView(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('failed_to_load'.tr, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
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

import 'package:ecommerce_app/components/circle_action_buttons.dart';
import 'package:ecommerce_app/models/filter_model.dart';
import 'package:ecommerce_app/views/filterPage/filter_page.dart';
import 'package:ecommerce_app/views/home/cubit /home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Shared search row widget that you can reuse in Home, Favorites, etc.
///
/// - Auto-detects Arabic from Get.locale if [isArabic] not passed.
/// - You can override callbacks for search, filter and chat.
/// - You can also pass your own [TextEditingController].
class BasicSearchBar extends StatelessWidget {
  final bool? isArabic;
  final TextEditingController? controller;

  /// Called when user submits from keyboard (done/search button).
  final ValueChanged<String>? onSubmitted;

  /// Called on every change (optional).
  final ValueChanged<String>? onChanged;

  /// Custom handler for filter icon. If null, open FiltersPage by default.
  final VoidCallback? onFilterTap;

  /// Custom handler for chat icon. If null, button is hidden.
  final VoidCallback? onChatTap;

  /// Optional hint override (for both languages).
  final String? arabicHint;
  final String? englishHint;

  const BasicSearchBar({
    super.key,
    this.isArabic,
    this.controller,
    this.onSubmitted,
    this.onChanged,
    this.onFilterTap,
    this.onChatTap,
    this.arabicHint,
    this.englishHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bool useArabic =
        isArabic ?? (Get.locale?.languageCode.toLowerCase() == 'ar');

    final dir = useArabic ? TextDirection.rtl : TextDirection.ltr;

    final String hintText =
        useArabic ? (arabicHint ?? 'search'.tr) : (englishHint ?? 'search'.tr);

    // Background for search pill depending on theme
    final Color searchBackground = isDark
        // ignore: deprecated_member_use
        ? colorScheme.surfaceContainerHighest.withOpacity(0.35)
        : colorScheme.surface;

    // Soft border color depending on theme
    final Color borderColor = isDark
        // ignore: deprecated_member_use
        ? colorScheme.outlineVariant.withOpacity(0.5)
        // ignore: deprecated_member_use
        : colorScheme.outline.withOpacity(0.4);

    // Shadow a bit stronger in light mode, softer in dark mode
    final Color shadowColor = isDark
        // ignore: deprecated_member_use
        ? Colors.black.withOpacity(0.6)
        // ignore: deprecated_member_use
        : Colors.black.withOpacity(0.12);

    return Directionality(
      textDirection: dir,
      child: Row(
        children: [
          // SEARCH FIELD
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: searchBackground,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                    color: shadowColor,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: TextField( textAlignVertical: TextAlignVertical.center,
                  controller: controller,
                  onSubmitted: onSubmitted,
                  onChanged: onChanged,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  cursorColor: colorScheme.primary,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      // ignore: deprecated_member_use
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 0,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // FILTER BUTTON
          CircleActionIcon(
            icon: Icons.filter_alt_outlined,
            onTap: onFilterTap ??
                () async {
                  final homeCubit = context.read<HomeCubit>();
                  final FilterModel? initial = homeCubit.getFilterModel();

                  final result = await Get.to(
                    () => FiltersPage(model: initial),
                  );

                  if (result is FilterModel) {
                    homeCubit.applyFilter(result);
                  }
                },
          ),

          const SizedBox(width: 8),

          // CHAT BUTTON (optional)
          if (onChatTap != null)
            CircleActionIcon(
              icon: Icons.chat_bubble_outline,
              onTap: onChatTap,
            ),
        ],
      ),
    );
  }
}

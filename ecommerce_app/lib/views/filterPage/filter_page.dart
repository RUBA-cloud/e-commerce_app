import 'package:ecommerce_app/components/choice_ship.dart';
import 'package:ecommerce_app/components/color_section.dart';
import 'package:ecommerce_app/constants/colors.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/filter_model.dart';
import 'package:ecommerce_app/models/size_model.dart';
import 'package:ecommerce_app/models/type_model.dart';
import 'package:ecommerce_app/views/filterPage/cubit/filter_cubit.dart';
import 'package:ecommerce_app/views/filterPage/cubit/filter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class FiltersPage extends StatelessWidget {
  final FilterModel? model;
  const FiltersPage({super.key, this.model,});

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'en') == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: BlocProvider(
        create: (_) => FiltersCubit()..load(model),
        child: BlocConsumer<FiltersCubit, FiltersState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == FiltersStatus.error && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            return FiltersBody(isAr: isAr);
          },
        ),
      ),
    );
  }
}

/// Main body widget separated from FiltersPage
class FiltersBody extends StatelessWidget {
  final bool isAr;

  const FiltersBody({super.key, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiltersCubit, FiltersState>(
      builder: (context, state) {
        final cubit = context.read<FiltersCubit>();

        final hasAnyFilter = state.model.categoryId != 0 ||
            state.model.selectedTypeId != null ||
            state.model.selectedSizeId != null ||
            state.model.selectedColor != null ||
            state.model.minPrice != null ||
            state.model.maxPrice != null;

        const double globalMin = 0;
        const double globalMax = 1000;

        final double currentMin = state.model.minPrice ?? globalMin;
        final double currentMax = state.model.maxPrice ?? globalMax;

        return Scaffold(
          appBar: AppBar(
            title: Text('filters_title'.tr),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: hasAnyFilter ? cubit.reset : null,
                child: Text(
                  'reset_filters'.tr,
                  style: TextStyle(
                    color: hasAnyFilter
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (state.status == FiltersStatus.loading &&
                  state.model.categories.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.status == FiltersStatus.error &&
                  state.model.categories.isEmpty) {
                return Center(
                  child: Text(
                    '${'error'.tr}: ${state.error ?? ''}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: [
                        // CATEGORY
                        const _SectionTitleWrapper(keyText: 'filter_category'),
                        const SizedBox(height: 8),
                        ChoiceShipWidget<CategoryModel>(
                          items: state.model.categories,
                          idGetter: (cat) => cat.id,
                          labelGetter: (cat) =>
                              isAr ? cat.nameAr : cat.nameEn,
                          selectedId: state.model.categoryId,
                          onSelected: (id) {
                            cubit.selectCategory(id);
                                                    },
                        ),

                        const SizedBox(height: 16),

                        // TYPE
                        const _SectionTitleWrapper(keyText: 'type'),
                        const SizedBox(height: 8),
                        ChoiceShipWidget<TypeModel>(
                          items: state.model.types,
                          idGetter: (t) => t.id,
                          labelGetter: (t) =>
                              isAr ? t.nameAr : t.nameEn,
                          selectedId: state.model.selectedTypeId ?? 0,
                          onSelected: (id) {
                            cubit.selectType(id);
                                                    },
                        ),

                        const SizedBox(height: 16),

                        // SIZE
                        const _SectionTitleWrapper(keyText: 'size'),
                        const SizedBox(height: 8),
                        ChoiceShipWidget<SizeModel>(
                          items: state.model.sizes,
                          idGetter: (s) => s.id!,
                          labelGetter: (s) =>
                              isAr ? s.nameAr : s.nameEn,
                          selectedId: state.model.selectedSizeId ?? 0,
                          onSelected: (id) {
                            cubit.selectSize(id);
                                                    },
                        ),

                        const SizedBox(height: 16),

                        // COLORS
                        const _SectionTitleWrapper(keyText: 'colors'),
                        const SizedBox(height: 8),
                          ColorSection(
                            colors: state.model.colors,
                            selectedColor: state.model.selectedColor,
                            onSelect: (color) {
                              cubit.selectColor(color);
                            },
                          ),

                        const SizedBox(height: 16),

                        // PRICE RANGE
                        const _SectionTitleWrapper(
                            keyText: 'filter_price_range'),
                        const SizedBox(height: 4),
                        _PriceRangeCard(
                          min: globalMin,
                          max: globalMax,
                          currentMin: currentMin,
                          currentMax: currentMax,
                        ),
                      ],
                    ),
                  ),

                  // APPLY BUTTON
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                            // ignore: deprecated_member_use
                            color: blackColor.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.status == FiltersStatus.loading
                              ? null
                              : () async {
                                 
                                  Get.back(result: state.model);
                                },
                          icon: const Icon(Icons.filter_alt),
                          label: Text('apply_filters'.tr),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SectionTitleWrapper extends StatelessWidget {
  final String keyText;

  const _SectionTitleWrapper({required this.keyText});

  @override
  Widget build(BuildContext context) {
    return Text(
      keyText.tr,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _PriceRangeCard extends StatelessWidget {
  final double min;
  final double max;
  final double currentMin;
  final double currentMax;

  const _PriceRangeCard({
    required this.min,
    required this.max,
    required this.currentMin,
    required this.currentMax,
  });

  @override
  Widget build(BuildContext context) {
    final values = RangeValues(currentMin, currentMax);
    final cubit = context.read<FiltersCubit>();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PricePill(
                  label: 'min'.tr,
                  value: currentMin,
                ),
                _PricePill(
                  label: 'max'.tr,
                  value: currentMax,
                ),
              ],
            ),
            const SizedBox(height: 8),
            RangeSlider(
              min: min,
              max: max,
              values: values,
              labels: RangeLabels(
                values.start.toStringAsFixed(0),
                values.end.toStringAsFixed(0),
              ),
              onChanged: (newValues) {
                cubit.setPrice(newValues.start, newValues.end);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final double value;

  const _PricePill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        // ignore: deprecated_member_use
        color: surfaceColor.withOpacity(0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value.toStringAsFixed(0),
            style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

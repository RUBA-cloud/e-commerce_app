// lib/presentation/home/fliter_dialog.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/data/model/response/filter_option_entity.dart';
import 'package:ecommerce_app/services/home/home_cubit.dart';
import 'package:ecommerce_app/services/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════════════════
// FilterDialog
// ═══════════════════════════════════════════════════════

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions _current;
  late HomeCubit cubit;

  // ── Static fallback colors (labels are translation keys) ──
  static const List<_ColorOption> _staticColors = [
    _ColorOption(labelKey: 'red',    hex: '#F44336', color: Color(0xFFF44336)),
    _ColorOption(labelKey: 'blue',   hex: '#2196F3', color: Color(0xFF2196F3)),
    _ColorOption(labelKey: 'green',  hex: '#4CAF50', color: Color(0xFF4CAF50)),
    _ColorOption(labelKey: 'yellow', hex: '#FFEB3B', color: Color(0xFFFFEB3B)),
    _ColorOption(labelKey: 'black',  hex: '#212121', color: Color(0xFF212121)),
    _ColorOption(labelKey: 'white',  hex: '#FAFAFA', color: Color(0xFFFAFAFA)),
    _ColorOption(labelKey: 'pink',   hex: '#E91E63', color: Color(0xFFE91E63)),
    _ColorOption(labelKey: 'purple', hex: '#9C27B0', color: Color(0xFF9C27B0)),
  ];

  // ── Anchor colors used to give API hex values a readable,
  //    localized name (nearest-color match) ─────────────────
  static const Map<String, Color> _namedAnchors = {
    'red':    Color(0xFFF44336),
    'orange': Color(0xFFFF9800),
    'yellow': Color(0xFFFFEB3B),
    'green':  Color(0xFF4CAF50),
    'blue':   Color(0xFF2196F3),
    'purple': Color(0xFF9C27B0),
    'pink':   Color(0xFFE91E63),
    'brown':  Color(0xFF795548),
    'maroon': Color(0xFF800000),
    'grey':   Color(0xFF9E9E9E),
    'black':  Color(0xFF212121),
    'white':  Color(0xFFFAFAFA),
  };

  static const List<String> _sortOptions = [
    'price_low_high',
    'price_high_low',
    'newest',
    'rating',
  ];

  static const Map<String, (String, String)> _sortMap = {
    'price_low_high': ('price', 'asc'),
    'price_high_low': ('price', 'desc'),
    'newest':         ('created_at', 'desc'),
    'rating':         ('rating', 'desc'),
  };

  @override
  void initState() {
    super.initState();
    cubit = HomeCubit.get(context);
    _current = cubit.activeFilter;
    cubit.loadFilterOptions();
  }

  void _reset() {
    setState(() => _current = const FilterOptions());
    cubit.clearFilter();
  }

  // ── Resolve API options ───────────────────────────────
  List<FilterOptionSizesEntity> get _apiSizes =>
      cubit.filterOptionsEntity?.sizes ?? [];

  List<String> get _apiColors =>
      cubit.filterOptionsEntity?.colors ?? [];

  List<FilterOptionCategoriesEntity> get _apiCategories =>
      cubit.filterOptionsEntity?.categories ?? [];

  List<FilterOptionBrandsEntity> get _apiBrands =>
      cubit.filterOptionsEntity?.brands ?? [];

  List<FilterOptionTypesEntity> get _apiTypes =>
      cubit.filterOptionsEntity?.types ?? [];

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      buildWhen: (_, s) =>
      s is HomeLoaded || s is HomeFilterLoading || s is HomeFailed,
      builder: (context, state) {
        return Dialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          insetPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Sticky header ───────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 12.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'filter_products'.tr(),
                        style: TextStyle(
                          fontSize:   19.sp,
                          fontWeight: FontWeight.w800,
                          color:      c.bodyText,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: Text(
                        'reset'.tr(),
                        style: TextStyle(
                          color:      c.main,
                          fontSize:   13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded,
                          color: c.bodyText, size: 22.r),
                    ),
                  ],
                ),
              ),
              Divider(color: c.hint.withOpacity(0.15), height: 1),

              // ── Scrollable body ─────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Price Range ────────────────────
                      _SectionLabel(label:"price_range".tr(), c: c),
                      SizedBox(height: 4.h),
                      _PriceRangeRow(current: _current, c: c),
                      RangeSlider(
                        activeColor:   c.main,
                        inactiveColor: c.hint.withOpacity(0.2),
                        values:
                        RangeValues(_current.minPrice, _current.maxPrice),
                        min:       0,
                        max:       10000,
                        divisions: 200,
                        labels: RangeLabels(
                          '\$${_current.minPrice.toInt()}',
                          '\$${_current.maxPrice.toInt()}',
                        ),
                        onChanged: (v) => setState(
                              () => _current = _current.copyWith(
                            minPrice: v.start,
                            maxPrice: v.end,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _PriceInput(
                              label: 'min'.tr(),
                              value: _current.minPrice,
                              c:     c,
                              onChanged: (v) => setState(
                                    () => _current = _current.copyWith(
                                  minPrice: v.clamp(0, _current.maxPrice),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _PriceInput(
                              label: 'max'.tr(),
                              value: _current.maxPrice,
                              c:     c,
                              onChanged: (v) => setState(
                                    () => _current = _current.copyWith(
                                  maxPrice:
                                  v.clamp(_current.minPrice, 10000),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // ── Category (API-sourced) ─────────
                      if (_apiCategories.isNotEmpty) ...[
                        _SectionLabel(label: 'category'.tr(), c: c),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing:    8.w,
                          runSpacing: 8.h,
                          children: [
                            _Chip(
                              label:    'all'.tr(),
                              selected: _current.selectedCategoryId == null,
                              c:        c,
                              onTap: () => setState(
                                    () => _current =
                                    _current.copyWith(clearCategory: true),
                              ),
                            ),
                            ..._apiCategories.map(
                                  (cat) => _Chip(
                                label:    cat.nameEn,
                                selected:
                                _current.selectedCategoryId == cat.id,
                                c:        c,
                                onTap: () => setState(
                                      () => _current = _current.copyWith(
                                    selectedCategoryId: cat.id,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ── Brands (API-sourced) ───────────
                      if (_apiBrands.isNotEmpty) ...[
                        _SectionLabel(label: 'brand'.tr(), c: c),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing:    8.w,
                          runSpacing: 8.h,
                          children: [
                            _Chip(
                              label:    'all'.tr(),
                              selected: _current.selectedBrandId == null,
                              c:        c,
                              onTap: () => setState(
                                    () => _current =
                                    _current.copyWith(clearBrand: true),
                              ),
                            ),
                            ..._apiBrands.map(
                                  (brand) => _Chip(
                                label:    brand.nameEn,
                                selected:
                                _current.selectedBrandId == brand.id,
                                c:        c,
                                onTap: () => setState(
                                      () => _current = _current.copyWith(
                                    selectedBrandId: brand.id,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ── Types (API-sourced) ────────────
                      if (_apiTypes.isNotEmpty) ...[
                        _SectionLabel(label: 'type'.tr(), c: c),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing:    8.w,
                          runSpacing: 8.h,
                          children: [
                            _Chip(
                              label:    'all'.tr(),
                              selected: _current.selectedTypeId == null,
                              c:        c,
                              onTap: () => setState(
                                    () => _current =
                                    _current.copyWith(clearType: true),
                              ),
                            ),
                            ..._apiTypes.map(
                                  (type) => _Chip(
                                label:    type.nameEn,
                                selected: _current.selectedTypeId == type.id,
                                c:        c,
                                onTap: () => setState(
                                      () => _current = _current.copyWith(
                                    selectedTypeId: type.id,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ── Sizes (API-sourced) ────────────
                      if (_apiSizes.isNotEmpty) ...[
                        _SectionLabel(label: 'size'.tr(), c: c),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing:    8.w,
                          runSpacing: 8.h,
                          children: _apiSizes.map((size) {
                            final label    = size.nameEn;
                            final selected =
                                _current.selectedSizeId == size.id;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _current = selected
                                    ? _current.copyWith(clearSize: true)
                                    : _current.copyWith(
                                    selectedSizeId: size.id);
                              }),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 200),
                                width:  48.r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? c.main
                                      : Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: selected
                                        ? c.main
                                        : c.hint.withOpacity(0.35),
                                    width: selected ? 2 : 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize:   12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? c.buttonText
                                          : c.bodyText,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ── Colors (API-sourced, from FilterOptionEntity) ──
                      if (_apiColors.isNotEmpty || _staticColors.isNotEmpty) ...[
                        _SectionLabel(label: 'color'.tr(), c: c),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing:    10.w,
                          runSpacing: 10.h,
                          children: _buildColorSwatches(c),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ── Sort By ────────────────────────
                      _SectionLabel(label: 'sort_by'.tr(), c: c),
                      SizedBox(height: 10.h),
                      Column(
                        children: [
                          _SortTile(
                            label:    'default'.tr(),
                            selected: _current.sortBy == null,
                            c:        c,
                            onTap: () => setState(
                                  () => _current =
                                  _current.copyWith(clearSort: true),
                            ),
                          ),
                          ..._sortOptions.map((key) {
                            final (sortBy, sortOrder) = _sortMap[key]!;
                            final selected = _current.sortBy == sortBy &&
                                _current.sortOrder == sortOrder;
                            return _SortTile(
                              label:    key.tr(),
                              selected: selected,
                              c:        c,
                              onTap: () => setState(
                                    () => _current = _current.copyWith(
                                  sortBy:    sortBy,
                                  sortOrder: sortOrder,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),

              // ── Sticky footer ───────────────────────────
              Divider(color: c.hint.withOpacity(0.15), height: 1),

              if (state is HomeFilterLoading)
                LinearProgressIndicator(
                  color:           c.main,
                  backgroundColor: c.main.withOpacity(0.12),
                  minHeight:       2,
                ),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.hint.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'cancel'.tr(),
                          style:
                          TextStyle(color: c.bodyText, fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.main,
                          foregroundColor: c.buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onPressed: () {
                          cubit.applyFilter(_current);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'apply'.tr(),
                          style: TextStyle(
                            fontSize:   14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Color swatches ──────────────────────────────────────
  // API colors come from FilterOptionEntity.colors as hex strings
  // ("#ff0000"). We keep the hex as the VALUE (what gets sent to the
  // backend in FilterRequest.color) but display a localized readable
  // NAME (red / أحمر) as the label.
  List<Widget> _buildColorSwatches(_Palette c) {
    if (_apiColors.isNotEmpty) {
      return _apiColors.map((hexStr) {
        final color    = _parseHex(hexStr);
        final selected = _current.selectedColors.contains(hexStr);
        return _ColorSwatch(
          label:    _colorLabel(color),
          color:    color,
          selected: selected,
          c:        c,
          onTap: () => setState(() {
            final updated = List<String>.from(_current.selectedColors);
            selected ? updated.remove(hexStr) : updated.add(hexStr);
            _current = _current.copyWith(selectedColors: updated);
          }),
        );
      }).toList();
    }

    // Static fallback (only shows if the API returned no colors)
    return _staticColors.map((opt) {
      final selected = _current.selectedColors.contains(opt.hex);
      return _ColorSwatch(
        label:    opt.labelKey.tr(),
        color:    opt.color,
        selected: selected,
        c:        c,
        onTap: () => setState(() {
          final updated = List<String>.from(_current.selectedColors);
          selected ? updated.remove(opt.hex) : updated.add(opt.hex);
          _current = _current.copyWith(selectedColors: updated);
        }),
      );
    }).toList();
  }

  /// Find the nearest named color and return its localized name.
  /// "#ff0000" → 'red'.tr() → "Red" / "أحمر"
  String _colorLabel(Color color) {
    String bestKey   = 'grey';
    double bestScore = double.infinity;
    for (final entry in _namedAnchors.entries) {
      final a  = entry.value;
      final dr = (color.red   - a.red).toDouble();
      final dg = (color.green - a.green).toDouble();
      final db = (color.blue  - a.blue).toDouble();
      // weighted RGB distance (human eyes weigh green most)
      final score = 0.30 * dr * dr + 0.59 * dg * dg + 0.11 * db * db;
      if (score < bestScore) {
        bestScore = score;
        bestKey   = entry.key;
      }
    }
    return bestKey.tr();
  }

  Color _parseHex(String hex) {
    try {
      final clean  = hex.replaceAll('#', '');
      final padded = clean.length == 6 ? 'FF$clean' : clean;
      return Color(int.parse(padded, radix: 16));
    } catch (_) {
      return const Color(0xFF9E9E9E);
    }
  }
}

// ═══════════════════════════════════════════════════════
// _Palette — colors for this dialog, derived from Theme
// ═══════════════════════════════════════════════════════

class _Palette {
  const _Palette({
    required this.main,
    required this.hint,
    required this.bodyText,
    required this.buttonText,
    required this.surface,
  });

  final Color main;
  final Color hint;
  final Color bodyText;
  final Color buttonText;
  final Color surface;

  factory _Palette.of(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    return _Palette(
      main:       scheme.primary,
      hint:       theme.hintColor,
      bodyText:   scheme.onSurface,
      buttonText: scheme.onPrimary,
      surface:    scheme.surface,
    );
  }
}

// ═══════════════════════════════════════════════════════
// _ColorSwatch
// ═══════════════════════════════════════════════════════

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.c,
    required this.onTap,
  });

  final String       label;
  final Color        color;
  final bool         selected;
  final _Palette     c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:  36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color:  color,
              shape:  BoxShape.circle,
              border: Border.all(
                color: selected ? c.main : c.hint.withOpacity(0.25),
                width: selected ? 3 : 1.5,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color:        c.main.withOpacity(0.35),
                  blurRadius:   8,
                  spreadRadius: 1,
                ),
              ]
                  : [],
            ),
            child: selected
                ? Icon(
              Icons.check_rounded,
              size:  16.r,
              color: color.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            )
                : null,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize:   9.sp,
              color:      selected ? c.main : c.hint,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _PriceRangeRow
// ═══════════════════════════════════════════════════════

class _PriceRangeRow extends StatelessWidget {
  const _PriceRangeRow({required this.current, required this.c});

  final FilterOptions current;
  final _Palette      c;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color:        c.main.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '\$${current.minPrice.toInt()} – \$${current.maxPrice.toInt()}',
            style: TextStyle(
              fontSize:   12.sp,
              color:      c.main,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// _PriceInput
// ═══════════════════════════════════════════════════════

class _PriceInput extends StatefulWidget {
  const _PriceInput({
    required this.label,
    required this.value,
    required this.c,
    required this.onChanged,
  });

  final String               label;
  final double               value;
  final _Palette             c;
  final ValueChanged<double> onChanged;

  @override
  State<_PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<_PriceInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toInt().toString());
  }

  @override
  void didUpdateWidget(_PriceInput old) {
    super.didUpdateWidget(old);
    final newText = widget.value.toInt().toString();
    if (_ctrl.text != newText) {
      _ctrl.text      = newText;
      _ctrl.selection = TextSelection.collapsed(offset: newText.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize:   11.sp,
            color:      widget.c.hint,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller:   _ctrl,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize:   13.sp,
            color:      widget.c.bodyText,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText:  '\$ ',
            prefixStyle: TextStyle(color: widget.c.main, fontSize: 13.sp),
            isDense:     true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical:   10.h,
            ),
            filled:    true,
            fillColor: widget.c.main.withOpacity(0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:   BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:   BorderSide(color: widget.c.main, width: 1.5),
            ),
          ),
          onChanged: (v) {
            final parsed = double.tryParse(v);
            if (parsed != null) widget.onChanged(parsed);
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// _SectionLabel
// ═══════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.c});

  final String   label;
  final _Palette c;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width:  4.w,
          height: 16.h,
          decoration: BoxDecoration(
            color:        c.main,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize:   14.sp,
            fontWeight: FontWeight.w800,
            color:      c.bodyText,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// _Chip
// ═══════════════════════════════════════════════════════

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.c,
    required this.onTap,
  });

  final String       label;
  final bool         selected;
  final _Palette     c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color:        selected ? c.main : c.main.withOpacity(0.07),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: selected ? c.main : c.hint.withOpacity(0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   12.sp,
            fontWeight: FontWeight.w600,
            color:      selected ? c.buttonText : c.bodyText,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _SortTile
// ═══════════════════════════════════════════════════════

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.label,
    required this.selected,
    required this.c,
    required this.onTap,
  });

  final String       label;
  final bool         selected;
  final _Palette     c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  20.r,
              height: 20.r,
              decoration: BoxDecoration(
                shape:  BoxShape.circle,
                color:  selected ? c.main : Colors.transparent,
                border: Border.all(
                  color: selected ? c.main : c.hint.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 12.r, color: c.buttonText)
                  : null,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize:   13.sp,
                color:      selected ? c.main : c.bodyText,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// _ColorOption  — static fallback data class
// ═══════════════════════════════════════════════════════

class _ColorOption {
  const _ColorOption({
    required this.labelKey,
    required this.hex,
    required this.color,
  });

  final String labelKey; // translation key, e.g. 'red'
  final String hex;
  final Color  color;
}
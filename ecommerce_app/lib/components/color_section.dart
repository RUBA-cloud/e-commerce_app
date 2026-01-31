import 'package:ecommerce_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // for .tr

/// ColorSection widget
class ColorSection extends StatelessWidget {
  final List<String>? colors;
  final String? selectedColor;
  final ValueChanged<String> onSelect;

  const ColorSection({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return productColorsSection(
      context: context,
      colors: colors!,
      selectedColor: selectedColor,
      onSelect: onSelect,
    );
  }
}

/// Parse hex/string color (e.g. "#FF0000" or "#F44336")
Color _parseProductColor(String value) {
  final v = value.trim().toLowerCase();
  if (v.startsWith('#')) {
    final hex = v.replaceFirst('#', '');
    if (hex.length == 6 || hex.length == 8) {
      final intVal =
          int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16) ??
              0xFF9E9E9E;
      return Color(intVal);
    }
  }
  // fallback
  return Colors.black;
}

/// Main section widget
Widget productColorsSection({
  required BuildContext context,
  required List<String> colors,
  required String? selectedColor,
  required ValueChanged<String> onSelect,
}) {
  return sectionCard(
    context: context,
    title: 'product_colors_title'.tr,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((c) {
        final color = _parseProductColor(c);
        final isSelected = selectedColor == c;
        final isLight =
            ThemeData.estimateBrightnessForColor(color) == Brightness.light;

        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isLight ? Colors.grey.shade300 : Colors.white70),
                width: isSelected ? 2 : 1.2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    ),
  );
}
Widget sectionCard({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          offset: const Offset(0, 4),
          // ignore: deprecated_member_use
          color: blackColor.withOpacity(0.03),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}
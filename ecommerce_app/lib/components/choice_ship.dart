import 'package:flutter/material.dart';

/// Generic choice chip list for shipping / categories / anything
class ChoiceShipWidget<T> extends StatelessWidget {
  /// Items to render as chips
  final List<T> items;

  /// How to get ID from item
  final int Function(T item) idGetter;

  /// How to get label from item
  final String Function(T item) labelGetter;

  /// Currently selected ID
  final int? selectedId;

  /// Called when user selects an item
  final ValueChanged<int> onSelected;

  const ChoiceShipWidget({
    super.key,
    required this.items,
    required this.idGetter,
    required this.labelGetter,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final int id = idGetter(item);
        final bool isSelected = id == selectedId;
        final String label = labelGetter(item);

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onSelected(id),
          // ignore: deprecated_member_use
          selectedColor:
              // ignore: deprecated_member_use
              Theme.of(context).colorScheme.primary.withOpacity(0.15),
          labelStyle: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';

import 'chip_selector.dart';

/// Thin, semantically-named wrapper over [ChipSelector] for filter rows
/// (search screen's Date/Tag filters, task-list filters, etc).
class FilterChipGroup<T> extends StatelessWidget {
  const FilterChipGroup({
    super.key,
    required this.options,
    required this.labelBuilder,
    required this.value,
    required this.onChanged,
  });

  final List<T> options;
  final String Function(T option) labelBuilder;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ChipSelector<T>(
      options: options,
      labelBuilder: labelBuilder,
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }
}

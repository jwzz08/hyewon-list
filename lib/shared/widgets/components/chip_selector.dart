import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// The one "pick one of N" visual pattern hyewon_list's design reuses
/// everywhere: solid-accent-filled-white-text when selected, pale-tint when
/// not. Used for tabs, repeat-frequency pickers, weekday pickers,
/// end-condition pickers, segmented settings toggles, and (via
/// [FilterChipGroup]) search filters.
class ChipSelector<T> extends StatelessWidget {
  const ChipSelector({
    super.key,
    required this.options,
    required this.labelBuilder,
    required this.value,
    required this.onChanged,
    this.dense = false,
  });

  final List<T> options;
  final String Function(T option) labelBuilder;
  final T value;
  final ValueChanged<T> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options.map((option) {
        final bool selected = option == value;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 12, vertical: dense ? 5 : 7),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : AppColors.bgNeutral,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              labelBuilder(option),
              style: AppTextStyles.meta(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

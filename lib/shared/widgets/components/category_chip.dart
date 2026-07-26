import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// The single "pick one of N" pill pattern reused for category/tag
/// selection throughout the app (see [ChipSelector] for the generic
/// single-select version used in forms/filters).
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.color,
    this.selected = true,
    this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.14) : Colors.transparent,
          border: selected ? null : Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(label, style: AppTextStyles.meta(color: color)),
      ),
    );
  }
}

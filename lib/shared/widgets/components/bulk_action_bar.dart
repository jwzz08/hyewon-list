import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Shown while a screen is in multi-select mode with at least one task
/// selected. Originally a private widget inside SearchScreen; pulled out
/// here so WeeklyPlannerScreen's per-day-column multi-select can reuse the
/// exact same look/behavior instead of duplicating it.
class BulkActionBar extends StatelessWidget {
  const BulkActionBar({super.key, required this.count, required this.onComplete, required this.onDelete});

  final int count;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentTintLightest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accentBorder),
      ),
      child: Row(
        children: [
          Text('$count selected', style: AppTextStyles.meta(color: AppColors.accentTextStrong)),
          const Spacer(),
          TextButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Complete'),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: onDelete,
            style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

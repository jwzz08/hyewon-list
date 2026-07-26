import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/priority.dart';

/// Small colored dot encoding [TaskPriority] — deliberately separate from
/// [CategoryChip]'s color system (priority = urgency, category = life-area).
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority, this.size = 6});

  final TaskPriority priority;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.forPriorityLevel(priority.value),
        shape: BoxShape.circle,
      ),
    );
  }
}

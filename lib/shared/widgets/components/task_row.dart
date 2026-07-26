import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/task.dart';
import 'category_chip.dart';
import 'priority_badge.dart';
import 'task_checkbox.dart';

/// Reusable task row used by the widget, weekly planner, task list, and
/// search screens. Never renders a calendar event — see [EventCard] for
/// that (tasks and events deliberately use different components; they are
/// never merged into one generic "item" widget).
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
    this.categoryLabel,
    this.categoryColor,
    this.showDueDateLabel = false,
    this.dense = false,
    this.titleMaxLines = 1,
  });

  final Task task;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTap;
  final String? categoryLabel;
  final Color? categoryColor;
  final bool showDueDateLabel;
  final bool dense;

  /// Lines allowed before the title truncates with an ellipsis — most
  /// callers keep the default single line, but WeeklyTaskSection passes 2 so
  /// long titles wrap instead of being cut off immediately (see its doc
  /// comment).
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final bool done = task.isCompleted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 5 : 8, horizontal: dense ? 6 : 10),
        child: Row(
          children: [
            TaskCheckbox(isChecked: done, onChanged: onToggle),
            const SizedBox(width: 8),
            PriorityBadge(priority: task.priority),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                task.title,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(
                  fontSize: dense ? 11.5 : 13,
                  color: done ? AppColors.textFaint : AppColors.textBody,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (categoryLabel != null) ...[
              const SizedBox(width: 6),
              CategoryChip(label: categoryLabel!, color: categoryColor ?? AppColors.categoryWork),
            ],
            if (showDueDateLabel && task.dueDate != null) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 56,
                child: Text(
                  AppDateUtils.isToday(task.dueDate!)
                      ? 'Today'
                      : AppDateUtils.formatShortDate(task.dueDate!),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.meta(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

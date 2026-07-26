import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/task.dart';
import '../../../../shared/widgets/components/task_row.dart';

/// The "To-do" half of a [WeeklyDayColumn]. Deliberately its own component,
/// separate from [WeeklyScheduleSection] — the product requirement is that
/// tasks and personal calendar events are never visually or logically
/// merged, even though they share a day column.
///
/// Each row is wrapped in `Draggable<Task>` (see [WeeklyDayColumn], which
/// hosts the matching `DragTarget<Object>` for the whole column) so a task
/// can be dragged onto a different day — kept working even in selection
/// mode, since dragging a row and tapping its checkbox are different
/// gestures that don't conflict.
class WeeklyTaskSection extends StatelessWidget {
  const WeeklyTaskSection({
    super.key,
    required this.tasks,
    required this.onToggle,
    this.onTap,
    this.selectionMode = false,
    this.selectedTaskIds = const <String>{},
    this.onToggleSelected,
    this.titleMaxLines = 1,
  });

  final List<Task> tasks;
  final void Function(Task task, bool isCompleted) onToggle;
  final void Function(Task task)? onTap;

  /// See TaskRow.titleMaxLines — WeeklyDayColumn passes 2 so long titles
  /// wrap onto a second line instead of getting cut off at the column's
  /// ~168px width.
  final int titleMaxLines;

  /// Multi-select state, lifted all the way up to WeeklyPlannerScreen (see
  /// its class doc) so selections can span every day column, not just this
  /// one — mirrors SearchScreen's `_selectionMode`/`_selectedTaskIds`.
  final bool selectionMode;
  final Set<String> selectedTaskIds;
  final void Function(String taskId)? onToggleSelected;

  @override
  Widget build(BuildContext context) {
    // Completed tasks are kept in the list (TaskRow shows them
    // struck-through) rather than hidden — sorted after the unfinished ones
    // so an accidental checkbox tap is still visible and easy to undo by
    // tapping it again.
    final List<Task> sorted = [...tasks]
      ..sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 6),
            Text('TO-DO', style: AppTextStyles.sectionLabel()),
          ],
        ),
        const SizedBox(height: 6),
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('No tasks', style: AppTextStyles.meta(fontSize: 10)),
          )
        else
          ...sorted.map(
            (Task t) => Row(
              children: [
                // Shrunk down (SearchScreen's equivalent checkbox uses
                // Flutter's default ~48px tap target, which is fine in that
                // screen's wide results list but would eat a big chunk of
                // this column's ~168px width).
                if (selectionMode)
                  Checkbox(
                    value: selectedTaskIds.contains(t.id),
                    onChanged: (_) => onToggleSelected?.call(t.id),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                Expanded(
                  child: Draggable<Task>(
                    data: t,
                    feedback: Opacity(
                      opacity: 0.35,
                      child: SizedBox(
                        width: 150,
                        child: Material(
                          color: Colors.transparent,
                          child: TaskRow(task: t, dense: true, onToggle: (_) {}),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: TaskRow(task: t, dense: true, onToggle: (_) {}),
                    ),
                    child: TaskRow(
                      task: t,
                      dense: true,
                      titleMaxLines: titleMaxLines,
                      onToggle: (v) => onToggle(t, v),
                      onTap: selectionMode
                          ? () => onToggleSelected?.call(t.id)
                          : (onTap == null ? null : () => onTap!(t)),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

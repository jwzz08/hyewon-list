import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../../../shared/widgets/components/add_item_dialog.dart';
import '../../../calendar/application/event_drag_drop.dart';
import '../../../tasks/application/task_providers.dart';
import '../../application/planner_providers.dart';
import 'weekly_schedule_section.dart';
import 'weekly_task_section.dart';

/// One weekday's column in the planner grid: header, To-do section,
/// divider, Schedule section, "+ add" footer.
class WeeklyDayColumn extends ConsumerWidget {
  const WeeklyDayColumn({
    super.key,
    required this.day,
    required this.tasks,
    required this.eventOccurrences,
    required this.isFocused,
    this.selectionMode = false,
    this.selectedTaskIds = const <String>{},
    this.onToggleTaskSelected,
  });

  final DateTime day;
  final List<Task> tasks;
  final List<CalendarEventOccurrence> eventOccurrences;
  final bool isFocused;

  /// Forwarded straight through to [WeeklyTaskSection] — see
  /// WeeklyPlannerScreen's class doc for why this state lives at the
  /// top of the screen rather than per-column.
  final bool selectionMode;
  final Set<String> selectedTaskIds;
  final void Function(String taskId)? onToggleTaskSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isToday = AppDateUtils.isToday(day);
    final Color bg = isToday
        ? AppColors.todayTint
        : isFocused
            ? AppColors.selectedDayTint
            : AppColors.cardWhite;
    final Color borderColor = (isToday || isFocused) ? AppColors.accentBorder : AppColors.borderWarm;
    // A visibly thicker border (not just a subtle tint swap) is what makes
    // "this card is selected" actually read as selected — previously the
    // border was always 1px regardless of state, so the only feedback for a
    // non-today focused day was the faint selectedDayTint background, easy
    // to miss next to the Overview list's much more visible accentTint row.
    final double borderWidth = (isToday || isFocused) ? 1.6 : 1.0;

    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) =>
          details.data is Task || details.data is CalendarEventOccurrence,
      onAcceptWithDetails: (details) {
        final Object data = details.data;
        if (data is Task) {
          ref.read(taskActionsProvider).moveToDate(data.id, day);
        } else if (data is CalendarEventOccurrence) {
          handleEventDroppedOnDay(context, ref, data, day);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final bool isDragOver = candidateData.isNotEmpty;
        return Container(
          constraints: const BoxConstraints(minHeight: 320),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDragOver ? AppColors.dragOverTint : bg,
            border: Border.all(
              color: isDragOver ? AppColors.accent : borderColor,
              width: isDragOver ? 1.6 : borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tapping the date header focuses this day — previously the
              // only way to do this was clicking the day's row in
              // WeeklySummaryPanel's Overview list on the far left. Stretched
              // to the card's full width (not just hugging the text) so the
              // whole header strip is clickable, not only the ~40px the
              // weekday/date text itself occupies — a tap target that small
              // in a ~168-240px-wide column read as "clicking the card
              // doesn't do anything" if you didn't land precisely on it.
              InkWell(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                onTap: () => ref.read(focusedDayProvider.notifier).state = day,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppDateUtils.weekdayShortLabels[day.weekday - 1],
                        style: AppTextStyles.meta(fontSize: 10, color: AppColors.textFaint),
                      ),
                      Text(
                        '${day.day}',
                        style: AppTextStyles.body(
                          fontSize: 15,
                          weight: FontWeight.w700,
                          color: isToday ? AppColors.accentDark : AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              WeeklyTaskSection(
                tasks: tasks,
                onToggle: (task, isCompleted) =>
                    ref.read(taskActionsProvider).setCompleted(task.id, isCompleted),
                onTap: (task) => showEditTaskDialog(context, task),
                selectionMode: selectionMode,
                selectedTaskIds: selectedTaskIds,
                onToggleSelected: onToggleTaskSelected,
                titleMaxLines: 2,
              ),
              const SizedBox(height: 10),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 10),
              WeeklyScheduleSection(
                occurrences: eventOccurrences,
                onTap: (occurrence) => showEditEventDialog(context, occurrence),
                titleMaxLines: 2,
              ),
              const Spacer(),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    onTap: () => showAddItemDialog(context,
                        initialDate: day, initialType: AddItemType.event),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.add_circle_outline, size: 16, color: AppColors.textFaint),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

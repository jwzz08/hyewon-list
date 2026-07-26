import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../../../shared/widgets/components/add_item_dialog.dart';
import '../../../../shared/widgets/components/empty_state.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/quick_add_input.dart';
import '../../../../shared/widgets/components/task_row.dart';
import '../../../../shared/widgets/components/widget_glass_card.dart';
import '../../../calendar/application/calendar_providers.dart';
import '../../../settings/application/settings_providers.dart';
import '../../../tasks/application/task_providers.dart';
import '../../application/widget_mode_providers.dart';
import 'week_bar_chart.dart';

/// Width >= 480px ("medium" and "large" tiers combined — the only
/// difference is [showWeekBar]). This is "Widget Mode" per the product
/// spec: today's date/weekday/clock, progress, today's to-dos, next event,
/// and a full-width quick-add input.
class WidgetExpandedView extends ConsumerWidget {
  const WidgetExpandedView({super.key, required this.showWeekBar});

  final bool showWeekBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = ref.watch(currentTimeProvider).value ?? DateTime.now();
    final AsyncValue<List<Task>> todayTasksAsync = ref.watch(todayTasksProvider);
    final AsyncValue<List<Task>> overdueAsync = ref.watch(overdueTasksProvider);
    final AsyncValue<TodayProgress> progressAsync = ref.watch(todayProgressProvider);
    final AsyncValue<CalendarEventOccurrence?> nextEventAsync = ref.watch(nextUpcomingEventProvider);
    final TaskActions taskActions = ref.watch(taskActionsProvider);
    final double cardOpacity = ref.watch(widgetPreferenceProvider).value?.cardOpacity ?? 100;

    final List<Task> todayTasks = todayTasksAsync.value ?? const <Task>[];
    final List<Task> overdue = overdueAsync.value ?? const <Task>[];
    // Overdue unfinished tasks surface above today's list per spec 4.1.
    // Completed-today tasks are appended (not dropped) so a misclick on the
    // checkbox can still be undone by tapping the row again — they were
    // previously filtered out entirely, which made that impossible.
    final List<Task> incompleteToday = todayTasks.where((t) => !t.isCompleted).toList();
    final List<Task> completedToday = todayTasks.where((t) => t.isCompleted).toList();
    // No `.take(N)` cap here (there used to be one) — completed tasks are
    // appended at the *end* of this list, so a fixed cap meant that as soon
    // as overdue+incomplete already filled most of the slots, completing a
    // task pushed it (and any earlier-completed tasks) straight out of the
    // visible window — from the user's perspective, checking something off
    // made it (and previously-completed items) vanish entirely, leaving at
    // most whichever one happened to still fit. The list now shows
    // everything and simply scrolls, matching WidgetCompactView's (uncapped)
    // behavior.
    final List<Task> displayList = [...overdue, ...incompleteToday, ...completedToday];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TODAY', style: AppTextStyles.eyebrow()),
                    const SizedBox(height: 2),
                    Text(_weekdayLabel(now), style: AppTextStyles.widgetDate),
                  ],
                ),
              ),
              Text(AppDateUtils.formatTimeOfDay(now.hour, now.minute), style: AppTextStyles.clockTime),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ProgressRing(progress: progressAsync.value?.ratio ?? 0, size: 26, strokeWidth: 3.5),
              const SizedBox(width: 8),
              Text(
                '${progressAsync.value?.completed ?? 0}/${progressAsync.value?.total ?? 0} done today',
                style: AppTextStyles.meta(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: displayList.isEmpty
                ? const EmptyState(message: 'Nothing due today', icon: Icons.celebration_outlined)
                : ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, i) => WidgetGlassCard(
                      opacity: cardOpacity,
                      margin: const EdgeInsets.only(bottom: 4),
                      child: TaskRow(
                        task: displayList[i],
                        onToggle: (v) => taskActions.setCompleted(displayList[i].id, v),
                        onTap: () => showEditTaskDialog(context, displayList[i]),
                      ),
                    ),
                  ),
          ),
          if (nextEventAsync.value != null) ...[
            const SizedBox(height: 4),
            WidgetGlassCard(
              opacity: cardOpacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, size: 13, color: AppColors.textFaint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Next: ${nextEventAsync.value!.sourceEvent.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (showWeekBar) ...[
            const SizedBox(height: 10),
            const WeekBarChart(),
          ],
          const SizedBox(height: 10),
          QuickAddInput(
            glass: true,
            onSubmit: (title) => taskActions.createQuickTask(title, dueDate: DateTime.now()),
            // Fast path above stays task-only (single line, no time to pick
            // a type) — this trailing button opens the full To-do/Schedule
            // picker with all detail options for anyone who needs more than
            // a bare title.
            // Same enlarged-hit-target fix as QuickAddBar's tune icon (see
            // its doc comment) — a bare 6px-left-padding GestureDetector
            // around a 16px icon was too small a target to reliably click.
            trailing: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              onTap: () => showAddItemDialog(context, initialDate: DateTime.now()),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.tune, size: 16, color: AppColors.textFaint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(DateTime dt) {
    const List<String> names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[dt.weekday - 1];
  }
}

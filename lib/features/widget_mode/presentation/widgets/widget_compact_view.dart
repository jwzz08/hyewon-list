import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../../../shared/widgets/components/empty_state.dart';
import '../../../../shared/widgets/components/task_row.dart';
import '../../../../shared/widgets/components/add_item_dialog.dart';
import '../../../../shared/widgets/components/widget_glass_card.dart';
import '../../../calendar/application/calendar_providers.dart';
import '../../../settings/application/settings_providers.dart';
import '../../../tasks/application/task_providers.dart';

/// Width 300-480px: today's tasks (unfinished first, completed kept visible
/// so a misclick can be undone), next event, and a quick-add button (no
/// inline input — opens the full To-do/Schedule picker dialog). No progress
/// ring here — it lived in the same top-right corner as WidgetScreen's
/// floating expand button and the two kept visually colliding (see
/// widget_screen.dart's _ExpandButton), so it was dropped from this tier
/// entirely rather than juggling clearance margins; WidgetExpandedView still
/// shows a progress ring lower down, away from that corner.
class WidgetCompactView extends ConsumerWidget {
  const WidgetCompactView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Task>> todayTasksAsync = ref.watch(todayTasksProvider);
    final AsyncValue<CalendarEventOccurrence?> nextEventAsync = ref.watch(nextUpcomingEventProvider);
    final TaskActions taskActions = ref.watch(taskActionsProvider);
    final double cardOpacity = ref.watch(widgetPreferenceProvider).value?.cardOpacity ?? 100;

    // Completed tasks stay in the list (dimmed/struck-through via TaskRow)
    // instead of vanishing the instant they're checked — a misclick is easy
    // to make in this small tier, and the checkbox already toggles both
    // ways, so keeping the row visible is what makes "undo" possible.
    final List<Task> todayTasks = [...todayTasksAsync.value ?? const <Task>[]]
      ..sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TODAY', style: AppTextStyles.eyebrow()),
          const SizedBox(height: 8),
          Expanded(
            child: todayTasks.isEmpty
                ? const EmptyState(message: 'Nothing due today', icon: Icons.celebration_outlined)
                : ListView.builder(
                    itemCount: todayTasks.length,
                    itemBuilder: (context, i) => WidgetGlassCard(
                      opacity: cardOpacity,
                      margin: const EdgeInsets.only(bottom: 3),
                      child: TaskRow(
                        task: todayTasks[i],
                        dense: true,
                        onToggle: (v) => taskActions.setCompleted(todayTasks[i].id, v),
                        onTap: () => showEditTaskDialog(context, todayTasks[i]),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          WidgetGlassCard(
            opacity: cardOpacity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      nextEventAsync.value == null
                          ? 'No upcoming events'
                          : nextEventAsync.value!.sourceEvent.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.meta(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showAddItemDialog(context, initialDate: DateTime.now()),
                    child: Icon(Icons.add_circle, size: 22, color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

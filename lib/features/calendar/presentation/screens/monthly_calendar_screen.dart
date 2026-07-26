import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../../../domain/models/widget_mode.dart';
import '../../../../shared/widgets/components/add_item_dialog.dart';
import '../../../../shared/widgets/components/empty_state.dart';
import '../../../../shared/widgets/components/event_card.dart';
import '../../../../shared/widgets/components/task_row.dart';
import '../../../tasks/application/task_providers.dart';
import '../../application/month_providers.dart';
import '../widgets/monthly_calendar_grid.dart';

/// Large, almost-full-screen monthly view — meant to feel like a desktop
/// planner calendar rather than a small mobile one (spec section 6). Shows
/// an optional detail side panel for the selected date once the window is
/// wide enough (>= AppBreakpoints.fullCalendarMin).
class MonthlyCalendarScreen extends ConsumerWidget {
  const MonthlyCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime monthAnchor = ref.watch(selectedMonthAnchorProvider);

    return Container(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref.read(selectedMonthAnchorProvider.notifier).state =
                    DateTime(monthAnchor.year, monthAnchor.month - 1, 1),
              ),
              Text(AppDateUtils.formatMonthYear(monthAnchor), style: AppTextStyles.display(fontSize: 24)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref.read(selectedMonthAnchorProvider.notifier).state =
                    DateTime(monthAnchor.year, monthAnchor.month + 1, 1),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    ref.read(currentAppScreenProvider.notifier).state = AppScreen.planner,
                icon: const Icon(Icons.arrow_upward, size: 14),
                label: const Text('Back to week'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool showSidePanel = constraints.maxWidth >= 900;
                final Widget grid = const MonthlyCalendarGrid();
                if (!showSidePanel) return grid;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: grid),
                    const SizedBox(width: 20),
                    const SizedBox(width: 260, child: _SelectedDateDetailPanel()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDateDetailPanel extends ConsumerWidget {
  const _SelectedDateDetailPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime? selectedDate = ref.watch(selectedDateProvider);
    if (selectedDate == null) {
      return const EmptyState(message: 'Select a date to see its details', icon: Icons.event_note_outlined);
    }

    final List<Task> tasks = (ref.watch(monthTasksProvider).value ?? const <Task>[])
        .where((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, selectedDate))
        .toList();
    final List<CalendarEventOccurrence> events =
        (ref.watch(monthEventsProvider).value ?? const <CalendarEventOccurrence>[])
            .where((o) => AppDateUtils.occursOnDay(o.occurrenceStart, o.occurrenceEnd, selectedDate))
            .toList();
    final TaskActions taskActions = ref.watch(taskActionsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgNeutral,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppDateUtils.monthLabels[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}',
              style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Text('TASKS', style: AppTextStyles.sectionLabel()),
            const SizedBox(height: 6),
            if (tasks.isEmpty)
              Text('No tasks due', style: AppTextStyles.meta())
            else
              ...tasks.map(
                (t) => TaskRow(
                  task: t,
                  onToggle: (v) => taskActions.setCompleted(t.id, v),
                  onTap: () => showEditTaskDialog(context, t),
                ),
              ),
            const SizedBox(height: 16),
            Text('EVENTS', style: AppTextStyles.sectionLabel()),
            const SizedBox(height: 6),
            if (events.isEmpty)
              Text('No events', style: AppTextStyles.meta())
            else
              ...events.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: EventCard(event: o.sourceEvent, onTap: () => showEditEventDialog(context, o)),
                  )),
          ],
        ),
      ),
    );
  }
}

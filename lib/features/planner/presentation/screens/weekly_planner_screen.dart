import 'package:flutter/gestures.dart';
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
import '../../../../shared/utils/undo_actions.dart';
import '../../../../shared/widgets/components/bulk_action_bar.dart';
import '../../../tasks/application/task_providers.dart';
import '../../application/planner_providers.dart';
import '../widgets/quick_add_bar.dart';
import '../widgets/weekly_day_column.dart';
import '../widgets/weekly_summary_panel.dart';

/// "Study planner"-style weekly workspace: a compact left summary panel and
/// a wide right-hand grid of day columns, each clearly separating to-dos
/// from personal calendar events (spec update §1).
///
/// Multi-select/bulk actions (see [_selectionMode]/[_selectedTaskIds])
/// mirror SearchScreen's pattern, but the state lives here at the screen
/// level rather than inside any single [WeeklyDayColumn] — a selection is
/// meant to span the whole week (e.g. clean up stray tasks from Monday
/// *and* Wednesday in one bulk delete), not just one day, so it's threaded
/// down through `_WeekGrid` to every column instead of each column tracking
/// its own.
class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen> {
  bool _selectionMode = false;
  final Set<String> _selectedTaskIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedTaskIds.clear();
    });
  }

  void _toggleTaskSelected(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime weekAnchor = ref.watch(selectedWeekAnchorProvider);
    final DateTime weekStart = ref.watch(weekStartProvider);
    final AsyncValue<List<Task>> tasksAsync = ref.watch(weeklyTasksProvider);
    final AsyncValue<List<CalendarEventOccurrence>> eventsAsync = ref.watch(weeklyEventsProvider);
    final DateTime? focusedDay = ref.watch(focusedDayProvider);
    final List<Task> allTasks = tasksAsync.value ?? const <Task>[];
    final List<Task> selectedTasks = allTasks.where((t) => _selectedTaskIds.contains(t.id)).toList();

    return Container(
      color: AppColors.bgWarm,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Weekly Planner', style: AppTextStyles.display()),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref.read(selectedWeekAnchorProvider.notifier).state =
                    weekAnchor.subtract(const Duration(days: 7)),
              ),
              Text(AppDateUtils.formatWeekRange(weekStart), style: AppTextStyles.body(fontSize: 14)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref.read(selectedWeekAnchorProvider.notifier).state =
                    weekAnchor.add(const Duration(days: 7)),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(selectedWeekAnchorProvider.notifier).state = DateTime.now(),
                child: const Text('Today'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _toggleSelectionMode,
                icon: Icon(_selectionMode ? Icons.close : Icons.checklist, size: 16),
                label: Text(_selectionMode ? 'Cancel' : 'Select'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () =>
                    ref.read(currentAppScreenProvider.notifier).state = AppScreen.month,
                icon: const Icon(Icons.calendar_month_outlined, size: 16),
                label: const Text('Expand to month'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Plan the week at a glance — tasks and personal events stay separate below.',
            style: AppTextStyles.meta(),
          ),
          if (_selectionMode && selectedTasks.isNotEmpty) ...[
            const SizedBox(height: 10),
            BulkActionBar(
              count: selectedTasks.length,
              onComplete: () async {
                final TaskActions actions = ref.read(taskActionsProvider);
                for (final Task t in selectedTasks) {
                  await actions.setCompleted(t.id, true);
                }
                setState(_selectedTaskIds.clear);
              },
              onDelete: () async {
                await deleteTasksWithUndo(context, ref, selectedTasks);
                setState(_selectedTaskIds.clear);
              },
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 280, child: const WeeklySummaryPanel()),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const QuickAddBar(),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _WeekGrid(
                          weekStart: weekStart,
                          tasks: allTasks,
                          eventOccurrences: eventsAsync.value ?? const <CalendarEventOccurrence>[],
                          focusedDay: focusedDay,
                          selectionMode: _selectionMode,
                          selectedTaskIds: _selectedTaskIds,
                          onToggleTaskSelected: _toggleTaskSelected,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekGrid extends StatefulWidget {
  const _WeekGrid({
    required this.weekStart,
    required this.tasks,
    required this.eventOccurrences,
    required this.focusedDay,
    this.selectionMode = false,
    this.selectedTaskIds = const <String>{},
    this.onToggleTaskSelected,
  });

  final DateTime weekStart;
  final List<Task> tasks;
  final List<CalendarEventOccurrence> eventOccurrences;
  final DateTime? focusedDay;

  /// Forwarded straight through to every [WeeklyDayColumn] — see
  /// WeeklyPlannerScreen's class doc.
  final bool selectionMode;
  final Set<String> selectedTaskIds;
  final void Function(String taskId)? onToggleTaskSelected;

  @override
  State<_WeekGrid> createState() => _WeekGridState();
}

class _WeekGridState extends State<_WeekGrid> {
  // Horizontal scrolling itself already worked (SingleChildScrollView), but
  // with no visible scrollbar and no way to drive it from a plain vertical
  // mouse wheel, a narrow window made the later weekdays look simply
  // missing rather than "scroll right for more". A controller lets us add
  // both a Scrollbar thumb and wheel-to-horizontal forwarding below.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleWheel(PointerScrollEvent event) {
    if (!_scrollController.hasClients) return;
    final double target = (_scrollController.offset + event.scrollDelta.dy)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(target);
  }

  // Below this many columns' worth of width, fall back to a fixed column
  // width + horizontal scroll (the original behavior) instead of squeezing
  // 7 columns down to something unreadably narrow.
  static const double _minColumnWidth = 168;
  static const double _columnGap = 10;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) _handleWheel(event);
      },
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Fullscreen/wide windows otherwise left a chunk of empty space
            // to the right of the 7th column since each column was always a
            // fixed 168px regardless of how much room was actually
            // available. Grow columns to fill the width completely — no
            // upper cap (an earlier 240px ceiling still left visible empty
            // space on wide/fullscreen windows, which was the exact
            // complaint) — only fall back to the fixed min width + scrolling
            // when the window is too narrow to fit all 7 comfortably.
            final double neededForSeven = _minColumnWidth * 7 + _columnGap * 6;
            final double columnWidth = constraints.maxWidth > neededForSeven
                ? (constraints.maxWidth - _columnGap * 6) / 7
                : _minColumnWidth;

            return SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(7, (i) {
                  final DateTime day = widget.weekStart.add(Duration(days: i));
                  final List<Task> dayTasks = widget.tasks
                      .where((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, day))
                      .toList();
                  final List<CalendarEventOccurrence> dayEvents = widget.eventOccurrences
                      .where(
                          (o) => AppDateUtils.occursOnDay(o.occurrenceStart, o.occurrenceEnd, day))
                      .toList();
                  return Padding(
                    padding: EdgeInsets.only(right: i < 6 ? _columnGap : 0),
                    child: SizedBox(
                      width: columnWidth,
                      child: WeeklyDayColumn(
                        day: day,
                        tasks: dayTasks,
                        eventOccurrences: dayEvents,
                        isFocused: widget.focusedDay != null &&
                            AppDateUtils.isSameDay(widget.focusedDay!, day),
                        selectionMode: widget.selectionMode,
                        selectedTaskIds: widget.selectedTaskIds,
                        onToggleTaskSelected: widget.onToggleTaskSelected,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

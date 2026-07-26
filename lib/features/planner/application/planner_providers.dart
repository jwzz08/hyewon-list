import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/task.dart';
import '../../calendar/application/calendar_providers.dart';
import '../../settings/application/settings_providers.dart';
import '../../tasks/application/task_providers.dart';

/// The date anchoring the currently-visible planner week (any day within
/// that week works — [weekStartProvider] normalizes it).
final StateProvider<DateTime> selectedWeekAnchorProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final Provider<DateTime> weekStartProvider = Provider<DateTime>((ref) {
  final DateTime anchor = ref.watch(selectedWeekAnchorProvider);
  final int startDay = ref.watch(startDayOfWeekProvider);
  return AppDateUtils.startOfWeek(anchor, startDayOfWeek: startDay);
});

final Provider<DateTime> weekEndProvider =
    Provider<DateTime>((ref) => ref.watch(weekStartProvider).add(const Duration(days: 6)));

/// The day highlighted by clicking a row in [WeeklySummaryPanel]'s Overview
/// list — pre-fills the quick-add composer's target day. Null = no focus.
final StateProvider<DateTime?> focusedDayProvider = StateProvider<DateTime?>((ref) => null);

/// Tasks due within the visible week — kept separate from
/// [weeklyEventsProvider] per the product requirement that tasks and
/// calendar events use different UI components and different data queries.
final Provider<AsyncValue<List<Task>>> weeklyTasksProvider = Provider<AsyncValue<List<Task>>>(
  (ref) => ref.watch(tasksInRangeProvider((ref.watch(weekStartProvider), ref.watch(weekEndProvider)))),
);

/// Personal calendar events (expanded recurring occurrences included) within
/// the visible week.
final Provider<AsyncValue<List<CalendarEventOccurrence>>> weeklyEventsProvider =
    Provider<AsyncValue<List<CalendarEventOccurrence>>>(
  (ref) => ref.watch(
    calendarOccurrencesInRangeProvider((ref.watch(weekStartProvider), ref.watch(weekEndProvider))),
  ),
);

class WeeklySummary {
  const WeeklySummary({
    required this.weekStart,
    required this.completedCount,
    required this.remainingCount,
    required this.overdueCount,
    required this.overdueTasks,
    required this.upcomingDeadlines,
    required this.eventCount,
    required this.weekEvents,
    required this.tasksByDay,
  });

  final DateTime weekStart;
  final int completedCount;
  final int remainingCount;
  final int overdueCount;

  /// The actual overdue tasks behind [overdueCount] — see
  /// WeeklySummaryPanel's "NEEDS ATTENTION" pill, which expands to show
  /// these on tap instead of just the bare count.
  final List<Task> overdueTasks;
  final List<Task> upcomingDeadlines;
  final int eventCount;

  /// The actual event occurrences behind [eventCount] — see
  /// WeeklySummaryPanel's "events this week" card, which lists these instead
  /// of just showing a count.
  final List<CalendarEventOccurrence> weekEvents;

  /// 7 entries (weekStart .. weekStart+6), each the tasks due that day.
  final List<List<Task>> tasksByDay;

  int get totalCount => completedCount + remainingCount;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}

final Provider<AsyncValue<WeeklySummary>> weeklySummaryProvider =
    Provider<AsyncValue<WeeklySummary>>((ref) {
  final AsyncValue<List<Task>> tasksAsync = ref.watch(weeklyTasksProvider);
  final AsyncValue<List<CalendarEventOccurrence>> eventsAsync = ref.watch(weeklyEventsProvider);
  final DateTime weekStart = ref.watch(weekStartProvider);

  if (tasksAsync.isLoading || eventsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final Object? error = tasksAsync.error ?? eventsAsync.error;
  if (error != null) {
    return AsyncValue<WeeklySummary>.error(error, StackTrace.current);
  }

  final List<Task> tasks = tasksAsync.value ?? const [];
  final List<CalendarEventOccurrence> events = eventsAsync.value ?? const [];

  final int completed = tasks.where((t) => t.isCompleted).length;
  final int remaining = tasks.length - completed;
  final List<Task> overdueTasks = tasks
      .where((t) => !t.isCompleted && t.dueDate != null && AppDateUtils.isOverdue(t.dueDate!))
      .toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  final List<Task> upcoming = tasks
      .where((t) => !t.isCompleted && t.dueDate != null && !AppDateUtils.isOverdue(t.dueDate!))
      .toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

  final List<List<Task>> byDay = List.generate(7, (i) {
    final DateTime day = weekStart.add(Duration(days: i));
    return tasks
        .where((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, day))
        .toList();
  });

  final List<CalendarEventOccurrence> sortedEvents = [...events]
    ..sort((a, b) => a.occurrenceStart.compareTo(b.occurrenceStart));

  return AsyncValue.data(WeeklySummary(
    weekStart: weekStart,
    completedCount: completed,
    remainingCount: remaining,
    overdueCount: overdueTasks.length,
    overdueTasks: overdueTasks,
    upcomingDeadlines: upcoming.take(5).toList(),
    eventCount: events.length,
    weekEvents: sortedEvents,
    tasksByDay: byDay,
  ));
});

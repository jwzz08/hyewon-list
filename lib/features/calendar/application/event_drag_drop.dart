import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/task.dart';
import '../../../shared/widgets/components/recurring_edit_scope_dialog.dart';
import '../../tasks/application/task_providers.dart';
import '../domain/recurring_event_service.dart';
import 'calendar_providers.dart';

/// Shared drop-handling logic for dragging an event occurrence onto a new
/// day — used by both the weekly planner's day columns and the month
/// grid's day cells, so the "recurring events get a scope picker" behavior
/// stays identical in both views (see ARCHITECTURE.md §5 point 3).
///
/// Non-recurring events (and already-detached single-occurrence rows, which
/// have `isRecurring == false`) move immediately via `moveToDateTime`. A
/// recurring *series* row triggers [showEditScopeDialog] first — the drop
/// only applies once a scope is chosen; dismissing the picker cancels the
/// move entirely (the event stays where it was).
Future<void> handleEventDroppedOnDay(
  BuildContext context,
  WidgetRef ref,
  CalendarEventOccurrence occurrence,
  DateTime newDay,
) async {
  final CalendarEvent source = occurrence.sourceEvent;
  final CalendarEventActions actions = ref.read(calendarEventActionsProvider);
  final Duration duration = occurrence.occurrenceEnd.difference(occurrence.occurrenceStart);
  final DateTime newStart = DateTime(
    newDay.year,
    newDay.month,
    newDay.day,
    occurrence.occurrenceStart.hour,
    occurrence.occurrenceStart.minute,
  );
  final DateTime newEnd = newStart.add(duration);

  if (!source.isRecurring) {
    await actions.moveToDateTime(source.id, newStart);
    return;
  }

  final EditScope? scope = await showEditScopeDialog(context, actionLabel: 'Move');
  if (scope == null) return;

  const RecurringEventService service = RecurringEventService();
  final DateTime originalDate = AppDateUtils.dateOnly(occurrence.occurrenceStart);
  final DateTime now = DateTime.now();

  switch (scope) {
    case EditScope.thisOccurrence:
      final CalendarEvent detached = CalendarEvent(
        id: IdGenerator.newId(),
        title: source.title,
        description: source.description,
        startDateTime: newStart,
        endDateTime: newEnd,
        isAllDay: source.isAllDay,
        categoryId: source.categoryId,
        color: source.color,
        location: source.location,
        parentEventId: source.id,
        originalOccurrenceDate: originalDate,
        createdAt: now,
        updatedAt: now,
      );
      await actions.create(detached);
      await actions.update(service.applyExceptionDate(source, originalDate));
      break;

    case EditScope.thisAndFollowing:
      final DateTime cutoff = originalDate.subtract(const Duration(days: 1));
      await actions.update(source.copyWith(recurrenceEndDate: cutoff, updatedAt: now));
      final CalendarEvent newSeries = CalendarEvent(
        id: IdGenerator.newId(),
        title: source.title,
        description: source.description,
        startDateTime: newStart,
        endDateTime: newEnd,
        isAllDay: source.isAllDay,
        categoryId: source.categoryId,
        color: source.color,
        location: source.location,
        isRecurring: true,
        recurrenceRule: source.recurrenceRule,
        recurrenceCount: source.recurrenceCount,
        createdAt: now,
        updatedAt: now,
      );
      await actions.create(newSeries);
      break;

    case EditScope.entireSeries:
      final Duration shift = newStart.difference(occurrence.occurrenceStart);
      await actions.update(source.copyWith(
        startDateTime: source.startDateTime.add(shift),
        endDateTime: source.endDateTime.add(shift),
        recurrenceEndDate: source.recurrenceEndDate?.add(shift),
        updatedAt: now,
      ));
      break;
  }
}

/// Converts [task] — dragged from the planner's undated-tasks "MEMO" list
/// (see WeeklySummaryPanel's `_MemoCard`) — into a brand-new [CalendarEvent]
/// on [day], then deletes the original task. This is the drag-and-drop
/// counterpart of AddItemDialog's to-do → schedule type switch, just with no
/// form to read extra details from: the event inherits the task's title,
/// description, category and reminder lead-time, and becomes an all-day
/// event unless the task had a specific due time set, in which case it
/// becomes a 1-hour event starting then.
Future<void> convertTaskToEventOnDay(WidgetRef ref, Task task, DateTime day) async {
  final DateTime dayOnly = AppDateUtils.dateOnly(day);
  final bool hasTime = task.dueTimeMinutes != null;
  final DateTime start = hasTime ? dayOnly.add(Duration(minutes: task.dueTimeMinutes!)) : dayOnly;
  final DateTime end =
      hasTime ? start.add(const Duration(hours: 1)) : dayOnly.add(const Duration(days: 1));
  final DateTime now = DateTime.now();

  final CalendarEvent event = CalendarEvent(
    id: IdGenerator.newId(),
    title: task.title,
    description: task.description,
    startDateTime: start,
    endDateTime: end,
    isAllDay: !hasTime,
    categoryId: task.categoryId,
    color: AppColors.eventColorPalette.first.value,
    reminderMinutesBefore: task.reminderMinutesBefore,
    createdAt: now,
    updatedAt: now,
  );
  await ref.read(calendarEventActionsProvider).create(event);
  await ref.read(taskActionsProvider).delete(task.id);
}

/// The reverse of [convertTaskToEventOnDay]: converts [occurrence] — dropped
/// on a day column's To-do section (see WeeklyDayColumn) — into a new [Task]
/// due on [day], then removes the original event. Mirrors AddItemDialog's
/// schedule → to-do type switch: a recurring series is asked the usual
/// this-occurrence/this-and-following/entire-series scope first (a single
/// to-do can't represent an ongoing series — "this and following" and
/// "entire series" both fall back to removing the whole series, only "this
/// occurrence" leaves the rest of the series alone), a plain event is just
/// deleted outright. Dismissing the scope picker cancels the drop entirely
/// (the event stays where it was, nothing is created).
Future<void> convertEventToTaskOnDay(
  BuildContext context,
  WidgetRef ref,
  CalendarEventOccurrence occurrence,
  DateTime day,
) async {
  final CalendarEvent parent = occurrence.sourceEvent;
  final CalendarEventActions eventActions = ref.read(calendarEventActionsProvider);

  if (parent.isRecurring) {
    final EditScope? scope = await showEditScopeDialog(context, actionLabel: 'Convert to to-do');
    if (scope == null) return;
    const RecurringEventService service = RecurringEventService();
    final DateTime occurrenceDate = AppDateUtils.dateOnly(occurrence.occurrenceStart);
    final DateTime now = DateTime.now();
    switch (scope) {
      case EditScope.thisOccurrence:
        await eventActions.update(service.applyExceptionDate(parent, occurrenceDate));
        break;
      case EditScope.thisAndFollowing:
        final DateTime cutoff = occurrenceDate.subtract(const Duration(days: 1));
        await eventActions.update(parent.copyWith(recurrenceEndDate: cutoff, updatedAt: now));
        break;
      case EditScope.entireSeries:
        await eventActions.delete(parent.id);
        break;
    }
  } else {
    await eventActions.delete(parent.id);
  }

  final DateTime now = DateTime.now();
  final Task task = Task(
    id: IdGenerator.newId(),
    title: parent.title,
    description: parent.description,
    dueDate: AppDateUtils.dateOnly(day),
    dueTimeMinutes: parent.isAllDay
        ? null
        : occurrence.occurrenceStart.hour * 60 + occurrence.occurrenceStart.minute,
    categoryId: parent.categoryId,
    reminderMinutesBefore: parent.reminderMinutesBefore,
    createdAt: now,
    updatedAt: now,
  );
  await ref.read(taskActionsProvider).create(task);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../shared/widgets/components/recurring_edit_scope_dialog.dart';
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

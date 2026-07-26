import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/repositories/calendar_event_repository.dart';
import '../../reminders/domain/reminder_scheduler.dart';
import '../domain/recurring_event_service.dart';

final Provider<RecurringEventService> recurringEventServiceProvider =
    Provider<RecurringEventService>((ref) => const RecurringEventService());

final StreamProvider<List<CalendarEvent>> allCalendarEventsProvider = StreamProvider(
  (ref) => ref.watch(calendarEventRepositoryProvider).watchAll(),
);

/// Stored rows overlapping (or recurring within) `(rangeStart, rangeEnd)` —
/// NOT yet expanded into individual occurrences. Use
/// [calendarOccurrencesInRangeProvider] for rendering.
final StreamProviderFamily<List<CalendarEvent>, (DateTime, DateTime)>
    calendarEventsInRangeProvider = StreamProvider.family<List<CalendarEvent>, (DateTime, DateTime)>(
  (ref, range) => ref.watch(calendarEventRepositoryProvider).watchInRange(range.$1, range.$2),
);

/// Fully expanded occurrences (recurring events generated into concrete
/// instances) for the given range — this is what calendar/planner UIs
/// should render.
final ProviderFamily<AsyncValue<List<CalendarEventOccurrence>>, (DateTime, DateTime)>
    calendarOccurrencesInRangeProvider =
    Provider.family<AsyncValue<List<CalendarEventOccurrence>>, (DateTime, DateTime)>((ref, range) {
  final AsyncValue<List<CalendarEvent>> eventsAsync =
      ref.watch(calendarEventsInRangeProvider(range));
  final RecurringEventService service = ref.watch(recurringEventServiceProvider);
  return eventsAsync.whenData((events) {
    final List<CalendarEventOccurrence> occurrences = [];
    for (final CalendarEvent event in events) {
      occurrences.addAll(service.generateOccurrences(event, range.$1, range.$2));
    }
    occurrences.sort((a, b) => a.occurrenceStart.compareTo(b.occurrenceStart));
    return occurrences;
  });
});

/// The soonest not-yet-finished event occurrence, looking 30 days ahead —
/// used by every widget tier's "next event" line and the weekly summary.
final Provider<AsyncValue<CalendarEventOccurrence?>> nextUpcomingEventProvider =
    Provider<AsyncValue<CalendarEventOccurrence?>>((ref) {
  final DateTime now = DateTime.now();
  final AsyncValue<List<CalendarEventOccurrence>> occurrencesAsync = ref.watch(
    calendarOccurrencesInRangeProvider((now, now.add(const Duration(days: 30)))),
  );
  return occurrencesAsync.whenData((occurrences) {
    final List<CalendarEventOccurrence> upcoming =
        occurrences.where((o) => o.occurrenceEnd.isAfter(now)).toList()
          ..sort((a, b) => a.occurrenceStart.compareTo(b.occurrenceStart));
    return upcoming.isEmpty ? null : upcoming.first;
  });
});

class CalendarEventActions {
  CalendarEventActions(this._repository, this._reminderScheduler);

  final CalendarEventRepository _repository;
  final ReminderScheduler _reminderScheduler;

  Future<void> create(CalendarEvent event) async {
    await _repository.create(event);
    await _reminderScheduler.syncForEvent(event);
  }

  /// Convenience for quick-add UI — builds a well-formed [CalendarEvent]
  /// from minimal input.
  Future<void> createQuickEvent({
    required String title,
    required DateTime startDateTime,
    Duration duration = const Duration(hours: 1),
    bool isAllDay = false,
    String? categoryId,
    int? color,
  }) {
    final DateTime now = DateTime.now();
    return create(CalendarEvent(
      id: IdGenerator.newId(),
      title: title,
      startDateTime: startDateTime,
      endDateTime: startDateTime.add(duration),
      isAllDay: isAllDay,
      categoryId: categoryId,
      color: color,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> update(CalendarEvent event) async {
    await _repository.update(event);
    await _reminderScheduler.syncForEvent(event);
  }

  /// See ARCHITECTURE.md "Recurring event edit/delete scopes" — for MVP this
  /// always deletes exactly the row passed in (the parent series row for a
  /// non-recurring/parent event, or a detached-occurrence row).
  Future<void> delete(String id) async {
    await _repository.delete(id);
    await _reminderScheduler.cancelForEvent(id);
  }

  Future<void> moveToDateTime(String id, DateTime newStart) async {
    await _repository.moveToDateTime(id, newStart);
    final CalendarEvent? event = await _repository.getById(id);
    if (event != null) await _reminderScheduler.syncForEvent(event);
  }

  Future<List<CalendarEvent>> search(String query) => _repository.searchByText(query);
}

final Provider<CalendarEventActions> calendarEventActionsProvider = Provider(
  (ref) => CalendarEventActions(
    ref.watch(calendarEventRepositoryProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

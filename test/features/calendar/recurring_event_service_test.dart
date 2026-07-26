import 'package:flutter_test/flutter_test.dart';
import 'package:hyewon_list/domain/models/calendar_event.dart';
import 'package:hyewon_list/domain/models/recurrence_frequency.dart';
import 'package:hyewon_list/features/calendar/domain/recurring_event_service.dart';

/// Unit tests for [RecurringEventService] — the highest bug-risk piece of
/// pure logic in the app (see the multi-day-event display bug fixed
/// earlier, and the RRULE-subset design documented in that file). No
/// database/Flutter widget tree involved, so these run fast and don't need
/// build_runner-generated code.
void main() {
  const RecurringEventService service = RecurringEventService();
  final DateTime now = DateTime(2026, 1, 1);

  CalendarEvent buildEvent({
    required DateTime start,
    required DateTime end,
    bool isRecurring = false,
    String? recurrenceRule,
    DateTime? recurrenceEndDate,
    int? recurrenceCount,
    List<DateTime> recurrenceExceptionDates = const [],
  }) {
    return CalendarEvent(
      id: 'evt-1',
      title: 'Test event',
      startDateTime: start,
      endDateTime: end,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      recurrenceEndDate: recurrenceEndDate,
      recurrenceCount: recurrenceCount,
      recurrenceExceptionDates: recurrenceExceptionDates,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('non-recurring events', () {
    test('single occurrence returned when it overlaps the range', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 10, 9, 0),
        end: DateTime(2026, 7, 10, 10, 0),
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 31));
      expect(occurrences, hasLength(1));
      expect(occurrences.single.isGeneratedRecurrence, isFalse);
      expect(occurrences.single.occurrenceStart, event.startDateTime);
    });

    test('nothing returned when it does not overlap the range', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 1, 10),
        end: DateTime(2026, 1, 10, 1, 0),
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 31));
      expect(occurrences, isEmpty);
    });

    test('multi-day event overlapping a range boundary is still returned '
        '(regression: this used to be dropped by isSameDay-only checks)', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 15),
        end: DateTime(2026, 7, 19, 23, 59),
      );
      // Range starting mid-way through the event, like a month grid's
      // second week row.
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 17), DateTime(2026, 7, 23));
      expect(occurrences, hasLength(1));
    });
  });

  group('daily recurrence', () {
    test('occurs every day by default', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0),
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 7));
      expect(occurrences, hasLength(7));
    });

    test('respects INTERVAL', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0),
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=2',
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 7));
      // Jul 1, 3, 5, 7
      expect(occurrences, hasLength(4));
    });

    test('respects COUNT', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0),
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        recurrenceCount: 3,
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 31));
      expect(occurrences, hasLength(3));
    });

    test('respects UNTIL', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0),
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        recurrenceEndDate: DateTime(2026, 7, 3),
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 31));
      expect(occurrences, hasLength(3)); // Jul 1, 2, 3
    });

    test('exception dates are excluded', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0),
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        recurrenceExceptionDates: [DateTime(2026, 7, 2)],
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 3));
      expect(occurrences, hasLength(2));
      expect(occurrences.any((o) => o.occurrenceStart.day == 2), isFalse);
    });
  });

  group('weekly recurrence', () {
    test('BYDAY selects specific weekdays', () {
      // Jul 1 2026 is a Wednesday.
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0),
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR',
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 14));
      // Two weeks of Mon/Wed/Fri, starting from Wed Jul 1: Jul 1,3,6,8,10,13
      expect(occurrences, hasLength(6));
      for (final CalendarEventOccurrence o in occurrences) {
        expect([1, 3, 5], contains(o.occurrenceStart.weekday));
      }
    });

    test('respects INTERVAL (every other week)', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0), // Wednesday
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=WE',
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 7, 1), DateTime(2026, 7, 31));
      // Jul 1, 15, 29 — every other Wednesday.
      expect(occurrences, hasLength(3));
    });
  });

  group('monthly and yearly recurrence', () {
    test('monthly recurs on the same day-of-month', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 1, 15, 8, 0),
        end: DateTime(2026, 1, 15, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=MONTHLY;INTERVAL=1',
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2026, 1, 1), DateTime(2026, 6, 30));
      expect(occurrences, hasLength(6));
      for (final CalendarEventOccurrence o in occurrences) {
        expect(o.occurrenceStart.day, 15);
      }
    });

    test('yearly recurs on the same month and day', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2024, 3, 5, 8, 0),
        end: DateTime(2024, 3, 5, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=YEARLY;INTERVAL=1',
      );
      final List<CalendarEventOccurrence> occurrences =
          service.generateOccurrences(event, DateTime(2024, 1, 1), DateTime(2027, 12, 31));
      expect(occurrences, hasLength(4));
      for (final CalendarEventOccurrence o in occurrences) {
        expect(o.occurrenceStart.month, 3);
        expect(o.occurrenceStart.day, 5);
      }
    });
  });

  group('applyExceptionDate / createDetachedOccurrence', () {
    test('applyExceptionDate adds the date without touching others', () {
      final CalendarEvent parent = buildEvent(
        start: DateTime(2026, 7, 1, 8, 0),
        end: DateTime(2026, 7, 1, 9, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
      );
      final CalendarEvent updated = service.applyExceptionDate(parent, DateTime(2026, 7, 3));
      expect(updated.recurrenceExceptionDates, hasLength(1));
      expect(updated.recurrenceExceptionDates.single.day, 3);
      // Original untouched (immutable copyWith).
      expect(parent.recurrenceExceptionDates, isEmpty);
    });

    test('createDetachedOccurrence copies the parent\'s time-of-day onto the new date', () {
      final CalendarEvent parent = buildEvent(
        start: DateTime(2026, 7, 1, 14, 30),
        end: DateTime(2026, 7, 1, 15, 30),
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1',
      );
      final CalendarEvent detached =
          service.createDetachedOccurrence(parent, DateTime(2026, 7, 8), newId: 'occ-1');
      expect(detached.parentEventId, parent.id);
      expect(detached.startDateTime.hour, 14);
      expect(detached.startDateTime.minute, 30);
      expect(detached.startDateTime.day, 8);
      expect(detached.duration, parent.duration);
    });
  });

  group('describeRecurrence / buildRecurrenceRule round-trip', () {
    test('parseRecurrenceRuleParts recovers what buildRecurrenceRule wrote', () {
      final String rule = buildRecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        byDay: {RecurrenceWeekday.mo, RecurrenceWeekday.fr},
        until: DateTime(2026, 12, 31),
      );
      final parsed = parseRecurrenceRuleParts(rule);
      expect(parsed.frequency, RecurrenceFrequency.weekly);
      expect(parsed.interval, 2);
      expect(parsed.byDay, {RecurrenceWeekday.mo, RecurrenceWeekday.fr});
      expect(parsed.until, DateTime(2026, 12, 31));
    });

    test('describeRecurrence produces a non-empty human-readable summary', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 7, 1, 1, 0),
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO',
      );
      expect(service.describeRecurrence(event), contains('Repeats every'));
    });

    test('non-recurring event describes as "Does not repeat"', () {
      final CalendarEvent event = buildEvent(
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 7, 1, 1, 0),
      );
      expect(service.describeRecurrence(event), 'Does not repeat');
    });
  });
}

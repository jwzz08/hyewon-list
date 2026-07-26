import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyewon_list/data/local/dao/calendar_event_dao.dart';
import 'package:hyewon_list/data/local/database/database.dart';
import 'package:hyewon_list/data/repositories/drift_calendar_event_repository.dart';
import 'package:hyewon_list/domain/models/calendar_event.dart';

/// Round-trip tests for [DriftCalendarEventRepository] against an in-memory
/// database. Also exercises the recurrence + reminder columns end-to-end
/// through the real generated `database.g.dart` mapping.
void main() {
  late AppDatabase db;
  late DriftCalendarEventRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCalendarEventRepository(CalendarEventDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  CalendarEvent buildEvent({
    String id = 'e1',
    String title = 'Team standup',
    DateTime? start,
    DateTime? end,
    bool isRecurring = false,
    String? recurrenceRule,
    List<DateTime> recurrenceExceptionDates = const [],
    int? reminderMinutesBefore,
  }) {
    final DateTime now = DateTime(2026, 7, 1);
    final DateTime s = start ?? DateTime(2026, 7, 10, 9, 0);
    final DateTime e = end ?? DateTime(2026, 7, 10, 9, 30);
    return CalendarEvent(
      id: id,
      title: title,
      startDateTime: s,
      endDateTime: e,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      recurrenceExceptionDates: recurrenceExceptionDates,
      reminderMinutesBefore: reminderMinutesBefore,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('create then getById round-trips every field, including recurrence', () async {
    final CalendarEvent event = buildEvent(
      isRecurring: true,
      recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR',
      recurrenceExceptionDates: [DateTime(2026, 7, 15)],
      reminderMinutesBefore: 15,
    );
    await repository.create(event);

    final CalendarEvent? loaded = await repository.getById('e1');
    expect(loaded, isNotNull);
    expect(loaded!.title, event.title);
    expect(loaded.startDateTime, event.startDateTime);
    expect(loaded.endDateTime, event.endDateTime);
    expect(loaded.isRecurring, isTrue);
    expect(loaded.recurrenceRule, event.recurrenceRule);
    expect(loaded.recurrenceExceptionDates, hasLength(1));
    expect(loaded.recurrenceExceptionDates.single, DateTime(2026, 7, 15));
    expect(loaded.reminderMinutesBefore, 15);
  });

  test('update overwrites fields via upsert semantics', () async {
    await repository.create(buildEvent(title: 'Original'));
    final CalendarEvent? original = await repository.getById('e1');
    await repository.update(original!.copyWith(title: 'Renamed'));

    final CalendarEvent? updated = await repository.getById('e1');
    expect(updated!.title, 'Renamed');
  });

  test('delete removes the row', () async {
    await repository.create(buildEvent());
    await repository.delete('e1');
    expect(await repository.getById('e1'), isNull);
  });

  test('moveToDateTime shifts start and end by the same duration', () async {
    await repository.create(buildEvent(
      start: DateTime(2026, 7, 10, 9, 0),
      end: DateTime(2026, 7, 10, 10, 30),
    ));
    await repository.moveToDateTime('e1', DateTime(2026, 7, 12, 9, 0));

    final CalendarEvent? moved = await repository.getById('e1');
    expect(moved!.startDateTime, DateTime(2026, 7, 12, 9, 0));
    expect(moved.endDateTime, DateTime(2026, 7, 12, 10, 30)); // duration preserved
  });

  test('watchInRange includes recurring rows even if their stored start is outside the range',
      () async {
    await repository.create(buildEvent(
      id: 'recurring',
      start: DateTime(2026, 1, 1, 9, 0),
      end: DateTime(2026, 1, 1, 10, 0),
      isRecurring: true,
      recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1',
    ));
    await repository.create(buildEvent(
      id: 'far-away-non-recurring',
      start: DateTime(2020, 1, 1, 9, 0),
      end: DateTime(2020, 1, 1, 10, 0),
    ));

    final List<CalendarEvent> events =
        await repository.watchInRange(DateTime(2026, 7, 1), DateTime(2026, 7, 31)).first;
    expect(events.map((e) => e.id), ['recurring']);
  });

  test('searchByText matches title', () async {
    await repository.create(buildEvent(id: 'e1', title: 'Dentist appointment'));
    await repository.create(buildEvent(id: 'e2', title: 'Lunch with team'));

    final List<CalendarEvent> results = await repository.searchByText('dentist');
    expect(results.map((e) => e.id), ['e1']);
  });
}

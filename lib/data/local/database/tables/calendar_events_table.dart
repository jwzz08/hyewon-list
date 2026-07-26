import 'package:drift/drift.dart';

/// Recurrence-ready schema — see domain/models/calendar_event.dart and
/// ARCHITECTURE.md "Recurrence design" for the full rationale behind each
/// nullable column below.
@DataClassName('CalendarEventRow')
class CalendarEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDateTime => dateTime()();
  DateTimeColumn get endDateTime => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  TextColumn get categoryId => text().nullable()();
  IntColumn get color => integer().nullable()();
  TextColumn get location => text().nullable()();

  // --- Recurrence ---
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// RRULE-style string, e.g. `FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR`.
  TextColumn get recurrenceRule => text().nullable()();
  DateTimeColumn get recurrenceEndDate => dateTime().nullable()();
  IntColumn get recurrenceCount => integer().nullable()();

  /// Set when this row is a detached single-occurrence override.
  TextColumn get parentEventId => text().nullable()();
  DateTimeColumn get originalOccurrenceDate => dateTime().nullable()();

  /// JSON array of ISO date strings excluded from the recurring series.
  /// MVP stores this as JSON text; see ARCHITECTURE.md for the future
  /// `RecurrenceExceptions` table if this grows unwieldy.
  TextColumn get recurrenceExceptionDatesJson =>
      text().withDefault(const Constant('[]'))();

  /// Minutes before `startDateTime` to fire a local notification. Null = no
  /// reminder. Added in schema v2 — see database.dart migration. For a
  /// recurring series this only schedules against the parent row's own
  /// `startDateTime` (i.e. the first occurrence) — see ReminderScheduler
  /// doc comment for why per-occurrence recurring reminders are out of scope.
  IntColumn get reminderMinutesBefore => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

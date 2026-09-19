import 'package:drift/drift.dart';

import '../database/database.dart';

class CalendarEventDao {
  CalendarEventDao(this._db);

  final AppDatabase _db;

  Stream<List<CalendarEventRow>> watchAll() {
    return (_db.select(_db.calendarEvents)
          ..orderBy([(e) => OrderingTerm(expression: e.startDateTime)]))
        .watch();
  }

  /// Rows that *overlap* `[start, end]` at all, OR that are recurring (a
  /// recurring row's *original* start may be outside the visible range even
  /// though it produces occurrences inside it — the caller's
  /// RecurringEventService needs the full row to expand it).
  ///
  /// **Correction**: this used to only match rows whose `startDateTime`
  /// itself fell in range (`start <= startDateTime < exclusiveEnd`). That
  /// missed any *multi-day, non-recurring* event whose start was before the
  /// queried range but which still spans into it — e.g. an Oct 30 – Nov 11
  /// event never matched a November-only query at all (its start isn't in
  /// November, and it isn't recurring either), so it silently vanished from
  /// November's month view even though its bar should keep spanning into it.
  /// A real interval-overlap test (`startDateTime < exclusiveEnd AND
  /// endDateTime > start`) fixes this — it still matches every case the old
  /// condition did (a same-day event's start now also satisfies this), plus
  /// the multi-day-spanning-into-range case the old one missed.
  ///
  /// Callers (weekEndProvider, month_providers.dart's `grid.last`, ...) pass
  /// [end] as the last *inclusive calendar day* they want, e.g. the Sunday of
  /// a visible week — not a precise cutoff instant. Bumping it to the start
  /// of the following day before comparing is deliberate: a literal
  /// `startDateTime <= end` only matched events starting at exactly midnight
  /// on that last day. Any event with a real time of day (say 2pm) landing on
  /// the week/month's final visible day fell outside the range and silently
  /// never streamed back — this is what made month-view-added events
  /// "disappear" from the weekly view, and dragged events vanish after being
  /// dropped on that day. Tasks don't have this bug because `dueDate` is
  /// stored date-only (always exactly midnight), so it always lands precisely
  /// on the old boundary.
  Stream<List<CalendarEventRow>> watchInRange(DateTime start, DateTime end) {
    final DateTime exclusiveEnd =
        DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
    return (_db.select(_db.calendarEvents)
          ..where((e) =>
              (e.startDateTime.isSmallerThanValue(exclusiveEnd) &
                      e.endDateTime.isBiggerThanValue(start)) |
                  e.isRecurring.equals(true))
          ..orderBy([(e) => OrderingTerm(expression: e.startDateTime)]))
        .watch();
  }

  Future<CalendarEventRow?> getById(String id) =>
      (_db.select(_db.calendarEvents)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<void> insertOrUpdate(CalendarEventsCompanion entry) =>
      _db.into(_db.calendarEvents).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (_db.delete(_db.calendarEvents)..where((e) => e.id.equals(id))).go();

  Future<List<CalendarEventRow>> searchByText(String query) {
    final String like = '%$query%';
    return (_db.select(_db.calendarEvents)
          ..where((e) => e.title.like(like) | e.description.like(like)))
        .get();
  }

  Future<List<CalendarEventRow>> getAllOnce() => _db.select(_db.calendarEvents).get();
}

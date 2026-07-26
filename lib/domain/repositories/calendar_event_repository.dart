import '../models/calendar_event.dart';

/// Persistence-agnostic contract for calendar events.
///
/// Deliberately returns *stored rows only* (not expanded recurrence
/// instances) — expanding a [CalendarEvent] with a [CalendarEvent.recurrenceRule]
/// into individual [CalendarEventOccurrence]s for a date range is
/// `RecurringEventService`'s job (features/calendar/domain), kept separate so
/// the repository stays a thin persistence layer.
abstract class CalendarEventRepository {
  Stream<List<CalendarEvent>> watchAll();

  /// Stored events whose [CalendarEvent.startDateTime] falls in range, OR
  /// that are recurring (recurring events must always be included here so
  /// the caller's RecurringEventService can expand them across the range).
  Stream<List<CalendarEvent>> watchInRange(DateTime start, DateTime end);

  Future<CalendarEvent?> getById(String id);

  Future<void> create(CalendarEvent event);

  Future<void> update(CalendarEvent event);

  /// Deletes the given row only. Callers implementing "delete entire series"
  /// vs "delete this occurrence" decide which row(s) to pass in — see
  /// ARCHITECTURE.md "Recurring event edit/delete scopes".
  Future<void> delete(String id);

  /// Drag-and-drop: moves the event, preserving its duration/time-of-day.
  Future<void> moveToDateTime(String id, DateTime newStart);

  Future<List<CalendarEvent>> searchByText(String query);
}

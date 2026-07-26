/// Simplified recurrence frequency, expandable to full RRULE later.
///
/// [CalendarEvent.recurrenceRule] stores an RRULE-*style* string
/// (e.g. `FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;UNTIL=20261231`) so the
/// architecture does not need to change when full RRULE support is added —
/// only [RecurringEventService]'s parser needs to grow. This enum is the
/// MVP-level classification used for the (not-yet-built) UI dropdown.
enum RecurrenceFrequency {
  none('NONE'),
  daily('DAILY'),
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  yearly('YEARLY'),
  custom('CUSTOM');

  const RecurrenceFrequency(this.value);
  final String value;

  static RecurrenceFrequency fromValue(String value) =>
      RecurrenceFrequency.values.firstWhere(
        (f) => f.value == value,
        orElse: () => RecurrenceFrequency.none,
      );
}

/// Weekday codes used inside `BYDAY=` — matches RRULE's two-letter codes.
enum RecurrenceWeekday {
  mo('MO'),
  tu('TU'),
  we('WE'),
  th('TH'),
  fr('FR'),
  sa('SA'),
  su('SU');

  const RecurrenceWeekday(this.code);
  final String code;

  /// DateTime.weekday is 1=Monday..7=Sunday, matching this list's order.
  static RecurrenceWeekday fromDateTimeWeekday(int weekday) =>
      RecurrenceWeekday.values[(weekday - 1) % 7];
}

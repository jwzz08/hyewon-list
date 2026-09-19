/// Date helpers shared across features. Kept dependency-free (no `intl`
/// requirement) except where explicitly noted, so this file is easy to unit
/// test in isolation.
class AppDateUtils {
  AppDateUtils._();

  /// Strips the time-of-day component, returning a pure calendar date.
  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  /// True if a span `[occurrenceStart, occurrenceEnd)` touches calendar day
  /// [day] at all — used to decide which day cells a (possibly multi-day)
  /// event/occurrence should render in. A plain same-day check
  /// (`isSameDay(occurrenceStart, day)`) only matches the *first* day of a
  /// multi-day event, which is why a Jul 15-19 event used to vanish once the
  /// grid scrolled past the 15th (including across a week-row boundary in
  /// the month view) — this overlap test instead matches every day the
  /// event spans.
  static bool occursOnDay(DateTime occurrenceStart, DateTime occurrenceEnd, DateTime day) {
    final DateTime dayStart = dateOnly(day);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));
    return occurrenceStart.isBefore(dayEnd) && occurrenceEnd.isAfter(dayStart);
  }

  /// True if the span `[occurrenceStart, occurrenceEnd)` touches more than
  /// one calendar day — i.e. whether a month-view event/occurrence should
  /// render as a single per-day chip (false) or a continuous spanning bar
  /// across consecutive day cells (true).
  static bool isMultiDaySpan(DateTime occurrenceStart, DateTime occurrenceEnd) {
    final DateTime startDay = dateOnly(occurrenceStart);
    final DateTime lastTouchedDay = dateOnly(occurrenceEnd.subtract(const Duration(minutes: 1)));
    return lastTouchedDay.isAfter(startDay);
  }

  static bool isOverdue(DateTime dueDate, {bool isCompleted = false}) {
    if (isCompleted) return false;
    return dateOnly(dueDate).isBefore(dateOnly(DateTime.now()));
  }

  /// Returns the first day of the week containing [dt].
  /// [startDayOfWeek] follows [DateTime] weekday numbering (1 = Monday .. 7 = Sunday).
  static DateTime startOfWeek(DateTime dt, {int startDayOfWeek = 1}) {
    final DateTime d = dateOnly(dt);
    final int diff = (d.weekday - startDayOfWeek) % 7;
    return d.subtract(Duration(days: diff < 0 ? diff + 7 : diff));
  }

  static DateTime endOfWeek(DateTime dt, {int startDayOfWeek = 1}) =>
      startOfWeek(dt, startDayOfWeek: startDayOfWeek).add(const Duration(days: 6));

  static List<DateTime> daysOfWeek(DateTime dt, {int startDayOfWeek = 1}) {
    final DateTime start = startOfWeek(dt, startDayOfWeek: startDayOfWeek);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  static DateTime firstDayOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);

  static DateTime lastDayOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0);

  /// Builds a full 6-row (42 cell) month grid starting on [startDayOfWeek],
  /// padded with adjacent-month days, matching the hyewon_list month mockup.
  static List<DateTime> buildMonthGridCells(
    DateTime monthAnchor, {
    int startDayOfWeek = 1,
  }) {
    final DateTime first = firstDayOfMonth(monthAnchor);
    final DateTime gridStart = startOfWeek(first, startDayOfWeek: startDayOfWeek);
    return List.generate(42, (i) => gridStart.add(Duration(days: i)));
  }

  static const List<String> weekdayShortLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// [weekdayShortLabels] rotated so index 0 is [startDayOfWeek] — matches
  /// [buildMonthGridCells]'s/[daysOfWeek]'s own column order for the same
  /// [startDayOfWeek].
  ///
  /// **Bug this fixes**: MonthlyCalendarGrid's header row used to render the
  /// plain [weekdayShortLabels] list directly regardless of the user's
  /// "Start day of week" setting. With Monday-start (the default) that
  /// happens to line up, but switching the setting to Sunday-start shifts
  /// every grid column over by one day while the header labels stay put —
  /// e.g. the column actually containing Saturday's events/tasks ends up
  /// sitting under a "Sun" header, and the column labeled "Sat" is really
  /// Friday. Adding an event by tapping what reads as the Saturday cell
  /// then silently lands it on Friday instead — this is why events "failed
  /// to add" on Saturday specifically for anyone using the Sunday-start
  /// setting, while to-dos (added via the date picker, not a grid tap)
  /// were unaffected.
  static List<String> weekdayLabelsFrom(int startDayOfWeek) =>
      List.generate(7, (i) => weekdayShortLabels[(startDayOfWeek - 1 + i) % 7]);

  static const List<String> monthLabels = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String formatMonthYear(DateTime dt) =>
      '${monthLabels[dt.month - 1]} ${dt.year}';

  static String formatShortDate(DateTime dt) =>
      '${monthLabels[dt.month - 1].substring(0, 3)} ${dt.day}';

  static String formatWeekRange(DateTime weekStart) {
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));
    final String startMonth = monthLabels[weekStart.month - 1].substring(0, 3);
    if (weekStart.month == weekEnd.month) {
      return '$startMonth ${weekStart.day}–${weekEnd.day}';
    }
    final String endMonth = monthLabels[weekEnd.month - 1].substring(0, 3);
    return '$startMonth ${weekStart.day} – $endMonth ${weekEnd.day}';
  }

  static String formatTimeOfDay(int hour, int minute) {
    final int h12 = hour % 12 == 0 ? 12 : hour % 12;
    final String period = hour < 12 ? 'AM' : 'PM';
    final String mm = minute.toString().padLeft(2, '0');
    return '$h12:$mm $period';
  }
}

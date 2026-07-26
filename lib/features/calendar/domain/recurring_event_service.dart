import '../../../core/utils/date_utils.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/recurrence_frequency.dart';

/// Expands a [CalendarEvent] with a (possibly recurring) `recurrenceRule`
/// into concrete [CalendarEventOccurrence]s for display.
///
/// MVP scope: supports `FREQ=DAILY|WEEKLY|MONTHLY|YEARLY` with `INTERVAL`,
/// `BYDAY` (weekly only), `UNTIL` and `COUNT`. This is intentionally a
/// subset of full RRULE, chosen so the *stored format* never has to change
/// when the parser is made smarter later — only this service does.
///
/// Occurrence-level edit/delete (this-only / this-and-following / entire
/// series) IS implemented in AddItemDialog — [createDetachedOccurrence] and
/// [applyExceptionDate] are the building blocks it's built on (see
/// ARCHITECTURE.md "Recurring event edit/delete scopes").
class RecurringEventService {
  const RecurringEventService();

  /// Generates every occurrence of [event] that overlaps
  /// `[rangeStart, rangeEnd]` (inclusive, date-level granularity).
  List<CalendarEventOccurrence> generateOccurrences(
    CalendarEvent event,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    if (!event.isRecurring || event.recurrenceRule == null || event.recurrenceRule!.isEmpty) {
      final bool overlaps = !event.endDateTime.isBefore(rangeStart) &&
          !event.startDateTime.isAfter(rangeEnd);
      if (!overlaps) return const [];
      return [
        CalendarEventOccurrence(
          sourceEvent: event,
          occurrenceStart: event.startDateTime,
          occurrenceEnd: event.endDateTime,
          isGeneratedRecurrence: false,
        ),
      ];
    }

    final Duration duration = event.duration;
    final DateTime dtStart = AppDateUtils.dateOnly(event.startDateTime);
    final DateTime rangeStartDate = AppDateUtils.dateOnly(rangeStart);
    final DateTime lastDate = AppDateUtils.dateOnly(rangeEnd);
    DateTime day = dtStart.isAfter(rangeStartDate) ? dtStart : rangeStartDate;

    final List<CalendarEventOccurrence> result = [];
    int iterations = 0;
    // Bounded loop (max ~3 years of days) protects against malformed rules.
    while (!day.isAfter(lastDate) && iterations < 1200) {
      if (occursOnDate(event, day)) {
        final DateTime occStart = DateTime(
          day.year,
          day.month,
          day.day,
          event.startDateTime.hour,
          event.startDateTime.minute,
        );
        result.add(CalendarEventOccurrence(
          sourceEvent: event,
          occurrenceStart: occStart,
          occurrenceEnd: occStart.add(duration),
          isGeneratedRecurrence: true,
        ));
      }
      day = day.add(const Duration(days: 1));
      iterations++;
    }
    return result;
  }

  /// True if [event]'s recurrence rule produces an occurrence on [date]
  /// (date-level check, ignoring time-of-day).
  bool occursOnDate(CalendarEvent event, DateTime date) {
    final DateTime d = AppDateUtils.dateOnly(date);
    final DateTime dtStart = AppDateUtils.dateOnly(event.startDateTime);

    if (d.isBefore(dtStart)) return false;
    if (event.recurrenceExceptionDates.any((e) => AppDateUtils.isSameDay(e, d))) {
      return false;
    }

    if (!event.isRecurring || event.recurrenceRule == null || event.recurrenceRule!.isEmpty) {
      return AppDateUtils.isSameDay(d, dtStart);
    }

    final _ParsedRule rule = _ParsedRule.parse(event.recurrenceRule!);
    final DateTime? until = event.recurrenceEndDate ?? rule.until;
    if (until != null && d.isAfter(AppDateUtils.dateOnly(until))) return false;
    final int? maxCount = event.recurrenceCount ?? rule.count;

    switch (rule.frequency) {
      case RecurrenceFrequency.weekly:
        final Set<RecurrenceWeekday> days = rule.byDay.isEmpty
            ? {RecurrenceWeekday.fromDateTimeWeekday(dtStart.weekday)}
            : rule.byDay;
        if (!days.contains(RecurrenceWeekday.fromDateTimeWeekday(d.weekday))) return false;
        final int weekDiff =
            AppDateUtils.startOfWeek(d).difference(AppDateUtils.startOfWeek(dtStart)).inDays ~/ 7;
        if (weekDiff < 0 || weekDiff % rule.interval != 0) return false;
        if (maxCount != null) {
          // Exact COUNT enforcement: counts actual matched occurrence days
          // from dtStart through d (inclusive) rather than week-blocks, so
          // multi-weekday BYDAY rules (e.g. Mon/Wed/Fri) are limited
          // correctly, not just single-weekday ones.
          final int occurrenceIndex1Based = _countWeeklyMatchesUpTo(dtStart, d, days, rule.interval);
          if (occurrenceIndex1Based > maxCount) return false;
        }
        return true;

      case RecurrenceFrequency.monthly:
        if (d.day != dtStart.day) return false;
        final int monthDiff = (d.year - dtStart.year) * 12 + (d.month - dtStart.month);
        if (monthDiff < 0 || monthDiff % rule.interval != 0) return false;
        if (maxCount != null && (monthDiff ~/ rule.interval) >= maxCount) return false;
        return true;

      case RecurrenceFrequency.yearly:
        if (d.day != dtStart.day || d.month != dtStart.month) return false;
        final int yearDiff = d.year - dtStart.year;
        if (yearDiff < 0 || yearDiff % rule.interval != 0) return false;
        if (maxCount != null && (yearDiff ~/ rule.interval) >= maxCount) return false;
        return true;

      case RecurrenceFrequency.daily:
      case RecurrenceFrequency.none:
      case RecurrenceFrequency.custom:
        final int dayDiff = d.difference(dtStart).inDays;
        if (dayDiff % rule.interval != 0) return false;
        if (maxCount != null && (dayDiff ~/ rule.interval) >= maxCount) return false;
        return true;
    }
  }

  /// Builds a detached single-occurrence override row. The caller is
  /// responsible for persisting it (via CalendarEventRepository.create) and
  /// for calling [applyExceptionDate] on the parent so the generated series
  /// no longer also produces this date. The "this occurrence only" edit
  /// scope in AddItemDialog implements this same shape inline (it needs to
  /// fold in the user's in-progress form edits, which this generic helper
  /// has no way to take as input) rather than calling this function
  /// directly — kept here as the documented reference shape / for reuse by
  /// any future caller that doesn't need to merge in fresh form data.
  CalendarEvent createDetachedOccurrence(
    CalendarEvent parent,
    DateTime occurrenceDate, {
    required String newId,
  }) {
    final DateTime dateOnly = AppDateUtils.dateOnly(occurrenceDate);
    final DateTime newStart = DateTime(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      parent.startDateTime.hour,
      parent.startDateTime.minute,
    );
    final DateTime now = DateTime.now();
    return CalendarEvent(
      id: newId,
      title: parent.title,
      description: parent.description,
      startDateTime: newStart,
      endDateTime: newStart.add(parent.duration),
      isAllDay: parent.isAllDay,
      categoryId: parent.categoryId,
      color: parent.color,
      location: parent.location,
      parentEventId: parent.id,
      originalOccurrenceDate: dateOnly,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Returns a copy of [parent] with [occurrenceDate] added to its
  /// exception list (removing that single date from the generated series).
  CalendarEvent applyExceptionDate(CalendarEvent parent, DateTime occurrenceDate) {
    final DateTime dateOnly = AppDateUtils.dateOnly(occurrenceDate);
    return parent.copyWith(
      recurrenceExceptionDates: [...parent.recurrenceExceptionDates, dateOnly],
      updatedAt: DateTime.now(),
    );
  }

  /// Human-readable summary shown in AddItemDialog's event editor, e.g.
  /// "Repeats every Monday" / "Repeats every 2 weeks on Mon, Wed until Dec 31, 2026".
  String describeRecurrence(CalendarEvent event) {
    if (!event.isRecurring || event.recurrenceRule == null) return 'Does not repeat';
    final _ParsedRule rule = _ParsedRule.parse(event.recurrenceRule!);
    final String unit = switch (rule.frequency) {
      RecurrenceFrequency.daily => rule.interval == 1 ? 'day' : 'days',
      RecurrenceFrequency.weekly => rule.interval == 1 ? 'week' : 'weeks',
      RecurrenceFrequency.monthly => rule.interval == 1 ? 'month' : 'months',
      RecurrenceFrequency.yearly => rule.interval == 1 ? 'year' : 'years',
      _ => 'time',
    };
    final StringBuffer sb = StringBuffer('Repeats every ');
    sb.write(rule.interval == 1 ? unit : '${rule.interval} $unit');
    if (rule.byDay.isNotEmpty) {
      sb.write(' on ${rule.byDay.map((d) => d.code).join(', ')}');
    }
    final DateTime? until = event.recurrenceEndDate ?? rule.until;
    if (until != null) {
      sb.write(' until ${until.year}-${until.month.toString().padLeft(2, '0')}-${until.day.toString().padLeft(2, '0')}');
    } else if ((event.recurrenceCount ?? rule.count) != null) {
      sb.write(' (${event.recurrenceCount ?? rule.count} times)');
    }
    return sb.toString();
  }
}

/// Public wrapper around the private RRULE-subset parser, exposed so UI code
/// (the event editor's recurrence controls) can pre-fill Repeat/Every/On
/// days/Ends fields when editing an existing recurring event, without
/// duplicating [_ParsedRule]'s parsing logic. Returned as a record (matches
/// this codebase's convention of using Dart 3 records for small structural
/// bundles instead of one-off classes — see the `(DateTime, DateTime)`
/// provider families in calendar_providers.dart).
({
  RecurrenceFrequency frequency,
  int interval,
  Set<RecurrenceWeekday> byDay,
  DateTime? until,
  int? count,
}) parseRecurrenceRuleParts(String rrule) {
  final _ParsedRule rule = _ParsedRule.parse(rrule);
  return (
    frequency: rule.frequency,
    interval: rule.interval,
    byDay: rule.byDay,
    until: rule.until,
    count: rule.count,
  );
}

/// Counts how many days in `[dtStart, d]` (inclusive) satisfy a weekly
/// BYDAY+INTERVAL rule — i.e. [d]'s 1-based occurrence index within the
/// series. Used to enforce COUNT exactly even when BYDAY lists several
/// weekdays (a plain week-block count would over- or under-count those).
/// [d] is assumed to already be on-or-after [dtStart]; bounded the same way
/// [RecurringEventService.generateOccurrences] is (callers only ever pass a
/// [d] within a few years of [dtStart]).
int _countWeeklyMatchesUpTo(
  DateTime dtStart,
  DateTime d,
  Set<RecurrenceWeekday> days,
  int interval,
) {
  int count = 0;
  DateTime cursor = dtStart;
  while (!cursor.isAfter(d)) {
    final int weekDiff =
        AppDateUtils.startOfWeek(cursor).difference(AppDateUtils.startOfWeek(dtStart)).inDays ~/ 7;
    if (weekDiff % interval == 0 &&
        days.contains(RecurrenceWeekday.fromDateTimeWeekday(cursor.weekday))) {
      count++;
    }
    cursor = cursor.add(const Duration(days: 1));
  }
  return count;
}

class _ParsedRule {
  const _ParsedRule({
    required this.frequency,
    required this.interval,
    required this.byDay,
    this.until,
    this.count,
  });

  final RecurrenceFrequency frequency;
  final int interval;
  final Set<RecurrenceWeekday> byDay;
  final DateTime? until;
  final int? count;

  static _ParsedRule parse(String rrule) {
    final Map<String, String> parts = {};
    for (final String segment in rrule.split(';')) {
      final List<String> kv = segment.split('=');
      if (kv.length == 2) parts[kv[0].trim().toUpperCase()] = kv[1].trim();
    }

    final String freqStr = parts['FREQ'] ?? 'DAILY';
    final RecurrenceFrequency frequency = RecurrenceFrequency.values.firstWhere(
      (f) => f.value == freqStr,
      orElse: () => RecurrenceFrequency.daily,
    );

    final int interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;

    final String? byDayStr = parts['BYDAY'];
    final Set<RecurrenceWeekday> byDay = byDayStr == null || byDayStr.isEmpty
        ? <RecurrenceWeekday>{}
        : byDayStr
            .split(',')
            .map((code) => RecurrenceWeekday.values
                .where((w) => w.code == code.trim())
                .cast<RecurrenceWeekday?>()
                .firstWhere((w) => w != null, orElse: () => null))
            .whereType<RecurrenceWeekday>()
            .toSet();

    DateTime? until;
    final String? untilStr = parts['UNTIL'];
    if (untilStr != null && untilStr.length >= 8) {
      until = DateTime(
        int.parse(untilStr.substring(0, 4)),
        int.parse(untilStr.substring(4, 6)),
        int.parse(untilStr.substring(6, 8)),
      );
    }

    final int? count = parts['COUNT'] == null ? null : int.tryParse(parts['COUNT']!);

    return _ParsedRule(
      frequency: frequency,
      interval: interval < 1 ? 1 : interval,
      byDay: byDay,
      until: until,
      count: count,
    );
  }
}

/// Builds an RRULE-style string from simple parameters — used by
/// AddItemDialog's Repeat/Every/On days/Ends recurrence controls. Exposed as
/// a top-level function so the UI layer never needs to hand-format RRULE
/// syntax itself.
String buildRecurrenceRule({
  required RecurrenceFrequency frequency,
  int interval = 1,
  Set<RecurrenceWeekday> byDay = const {},
  DateTime? until,
  int? count,
}) {
  final List<String> parts = ['FREQ=${frequency.value}', 'INTERVAL=$interval'];
  if (byDay.isNotEmpty) {
    parts.add('BYDAY=${byDay.map((d) => d.code).join(',')}');
  }
  if (until != null) {
    final String y = until.year.toString().padLeft(4, '0');
    final String m = until.month.toString().padLeft(2, '0');
    final String d = until.day.toString().padLeft(2, '0');
    parts.add('UNTIL=$y$m$d');
  } else if (count != null) {
    parts.add('COUNT=$count');
  }
  return parts.join(';');
}

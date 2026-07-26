import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/task.dart';
import '../../settings/application/settings_providers.dart';
import '../../tasks/application/task_providers.dart';
import '../domain/holiday_model.dart';
import '../domain/holiday_service.dart';
import 'calendar_providers.dart';

/// The month currently shown by [MonthlyCalendarScreen] (any date within
/// that month works — the grid always shows the full month).
final StateProvider<DateTime> selectedMonthAnchorProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

/// The date the user clicked in the grid — drives the (optional) detail
/// side panel and the day-cell "selected" highlight.
final StateProvider<DateTime?> selectedDateProvider =
    StateProvider<DateTime?>((ref) => DateTime.now());

/// Full 42-cell (6-row) grid, padded with adjacent-month days, matching the
/// mockup's month view exactly.
final Provider<List<DateTime>> monthGridDatesProvider = Provider<List<DateTime>>((ref) {
  final DateTime anchor = ref.watch(selectedMonthAnchorProvider);
  final int startDay = ref.watch(startDayOfWeekProvider);
  return AppDateUtils.buildMonthGridCells(anchor, startDayOfWeek: startDay);
});

final Provider<AsyncValue<List<Task>>> monthTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final List<DateTime> grid = ref.watch(monthGridDatesProvider);
  return ref.watch(tasksInRangeProvider((grid.first, grid.last)));
});

final Provider<AsyncValue<List<CalendarEventOccurrence>>> monthEventsProvider =
    Provider<AsyncValue<List<CalendarEventOccurrence>>>((ref) {
  final List<DateTime> grid = ref.watch(monthGridDatesProvider);
  return ref.watch(calendarOccurrencesInRangeProvider((grid.first, grid.last)));
});

/// Holidays visible in the current grid (respects the "Show ... holidays" /
/// "Show lunar calendar" toggles in CalendarSettingsSection). See
/// holiday_service.dart for scope notes.
final Provider<List<Holiday>> monthHolidaysProvider = Provider<List<Holiday>>((ref) {
  final List<DateTime> grid = ref.watch(monthGridDatesProvider);
  final AppSettings? settings = ref.watch(appSettingsProvider).value;
  if (settings == null ||
      (!settings.showKoreanHolidays &&
          !settings.showCanadaHolidays &&
          !settings.showLunarCalendar &&
          !settings.showSolarTerms)) {
    return const [];
  }
  final DateTime gridStart = AppDateUtils.dateOnly(grid.first);
  final DateTime gridEnd = AppDateUtils.dateOnly(grid.last);
  final Set<int> years = {gridStart.year, gridEnd.year};
  final List<Holiday> all = [
    for (final int year in years)
      ...HolidayService.forYear(
        year,
        includeKorea: settings.showKoreanHolidays,
        includeCanada: settings.showCanadaHolidays,
        includeLunarHolidays: settings.showLunarCalendar,
        includeSolarTerms: settings.showSolarTerms,
      ),
  ];
  return all
      .where((h) => !h.date.isBefore(gridStart) && !h.date.isAfter(gridEnd))
      .toList();
});

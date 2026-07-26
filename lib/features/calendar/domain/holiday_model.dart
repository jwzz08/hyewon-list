/// Which static holiday data set a [Holiday] came from — matches the
/// toggles in CalendarSettingsSection (`showKoreanHolidays`/
/// `showCanadaHolidays`/`showLunarCalendar`, all tagged [korea]; and
/// `showSolarTerms`, tagged [solarTerm]). [solarTerm] entries are seasonal
/// markers (24절기) rather than public holidays, so UI code should style
/// them distinctly — see CalendarDayCell.
enum HolidayCountry { korea, canada, solarTerm }

/// A single public holiday on a specific date. Computed on the fly by
/// [HolidayService] — not stored in the database, since it's fully
/// deterministic from (year, country).
class Holiday {
  const Holiday({required this.date, required this.name, required this.country});

  /// Date-only (midnight local), matching [AppDateUtils.dateOnly].
  final DateTime date;
  final String name;
  final HolidayCountry country;
}

import 'holiday_model.dart';
import 'solar_term_service.dart';

/// Static, computed (not database-backed) public holiday data for Korea and
/// Canada/BC, mirroring [RecurringEventService]'s "pure logic service, no
/// UI, no storage" shape — see ARCHITECTURE.md section 8.
///
/// Scope note: fixed-Gregorian-date holidays are computed algorithmically.
/// Lunar-based KR holidays (Seollal, Chuseok, Buddha's Birthday) are *not*
/// algorithmically computed — a correct proleptic lunisolar conversion is a
/// large standalone algorithm — but real, independently-verified Gregorian
/// dates for those holidays are hardcoded in [_lunarHolidayDates] for
/// 2020-2040 (source: Wikipedia "Public holidays in South Korea", cross
/// checked against known 2024/2025 dates). Outside that range the lunar
/// holidays are simply omitted rather than guessed. The 24 solar terms
/// (24절기) *are* computed for any year via [SolarTermService], a real
/// astronomical calculation (not a lookup table) — see that file.
class HolidayService {
  const HolidayService._();

  /// All holidays in [year] for the requested countries/categories.
  static List<Holiday> forYear(
    int year, {
    bool includeKorea = true,
    bool includeCanada = true,
    bool includeLunarHolidays = false,
    bool includeSolarTerms = false,
  }) {
    return [
      if (includeKorea) ..._korea(year),
      if (includeLunarHolidays) ..._koreaLunar(year),
      if (includeCanada) ..._canada(year),
      if (includeSolarTerms) ...SolarTermService.forYear(year),
    ];
  }

  static List<Holiday> _korea(int year) => [
        Holiday(date: DateTime(year, 1, 1), name: "New Year's Day", country: HolidayCountry.korea),
        Holiday(
          date: DateTime(year, 3, 1),
          name: 'Independence Movement Day',
          country: HolidayCountry.korea,
        ),
        Holiday(date: DateTime(year, 5, 5), name: "Children's Day", country: HolidayCountry.korea),
        Holiday(date: DateTime(year, 6, 6), name: 'Memorial Day', country: HolidayCountry.korea),
        Holiday(date: DateTime(year, 8, 15), name: 'Liberation Day', country: HolidayCountry.korea),
        Holiday(
          date: DateTime(year, 10, 3),
          name: 'National Foundation Day',
          country: HolidayCountry.korea,
        ),
        Holiday(date: DateTime(year, 10, 9), name: 'Hangul Day', country: HolidayCountry.korea),
        Holiday(date: DateTime(year, 12, 25), name: 'Christmas Day', country: HolidayCountry.korea),
      ];

  /// Seollal (설날, 3-day: day before/of/after lunar new year), Chuseok
  /// (추석, same 3-day shape around the lunar Aug 15), and Buddha's Birthday
  /// (석가탄신일, single day) — gated separately from [_korea] by the
  /// "Show lunar calendar" toggle since these are lunisolar, not fixed
  /// Gregorian dates. Years outside [_lunarHolidayDates] return no lunar
  /// holidays rather than an incorrect guess.
  static List<Holiday> _koreaLunar(int year) {
    final List<DateTime>? dates = _lunarHolidayDates[year];
    if (dates == null) return const [];
    final DateTime seollal = dates[0];
    final DateTime buddhaBirthday = dates[1];
    final DateTime chuseok = dates[2];
    return [
      Holiday(
        date: seollal.subtract(const Duration(days: 1)),
        name: 'Seollal (Lunar New Year Holiday)',
        country: HolidayCountry.korea,
      ),
      Holiday(date: seollal, name: 'Seollal (Lunar New Year)', country: HolidayCountry.korea),
      Holiday(
        date: seollal.add(const Duration(days: 1)),
        name: 'Seollal (Lunar New Year Holiday)',
        country: HolidayCountry.korea,
      ),
      Holiday(
        date: buddhaBirthday,
        name: "Buddha's Birthday",
        country: HolidayCountry.korea,
      ),
      Holiday(
        date: chuseok.subtract(const Duration(days: 1)),
        name: 'Chuseok Holiday',
        country: HolidayCountry.korea,
      ),
      Holiday(date: chuseok, name: 'Chuseok', country: HolidayCountry.korea),
      Holiday(
        date: chuseok.add(const Duration(days: 1)),
        name: 'Chuseok Holiday',
        country: HolidayCountry.korea,
      ),
    ];
  }

  /// year -> [Seollal day, Buddha's Birthday, Chuseok day], all as exact
  /// Gregorian dates (not the surrounding 3-day span, which [_koreaLunar]
  /// derives by +/-1 day). Verified against Wikipedia's "Public holidays in
  /// South Korea" reference table.
  static final Map<int, List<DateTime>> _lunarHolidayDates = {
    2020: [DateTime(2020, 1, 25), DateTime(2020, 4, 30), DateTime(2020, 10, 1)],
    2021: [DateTime(2021, 2, 12), DateTime(2021, 5, 19), DateTime(2021, 9, 21)],
    2022: [DateTime(2022, 2, 1), DateTime(2022, 5, 8), DateTime(2022, 9, 10)],
    2023: [DateTime(2023, 1, 22), DateTime(2023, 5, 27), DateTime(2023, 9, 29)],
    2024: [DateTime(2024, 2, 10), DateTime(2024, 5, 15), DateTime(2024, 9, 17)],
    2025: [DateTime(2025, 1, 29), DateTime(2025, 5, 5), DateTime(2025, 10, 6)],
    2026: [DateTime(2026, 2, 17), DateTime(2026, 5, 24), DateTime(2026, 9, 25)],
    2027: [DateTime(2027, 2, 7), DateTime(2027, 5, 13), DateTime(2027, 9, 15)],
    2028: [DateTime(2028, 1, 27), DateTime(2028, 5, 2), DateTime(2028, 10, 3)],
    2029: [DateTime(2029, 2, 13), DateTime(2029, 5, 20), DateTime(2029, 9, 22)],
    2030: [DateTime(2030, 2, 3), DateTime(2030, 5, 9), DateTime(2030, 9, 12)],
    2031: [DateTime(2031, 1, 23), DateTime(2031, 5, 28), DateTime(2031, 10, 1)],
    2032: [DateTime(2032, 2, 11), DateTime(2032, 5, 16), DateTime(2032, 9, 19)],
    2033: [DateTime(2033, 1, 31), DateTime(2033, 5, 6), DateTime(2033, 9, 8)],
    2034: [DateTime(2034, 2, 19), DateTime(2034, 5, 25), DateTime(2034, 9, 27)],
    2035: [DateTime(2035, 2, 8), DateTime(2035, 5, 15), DateTime(2035, 9, 16)],
    2036: [DateTime(2036, 1, 28), DateTime(2036, 5, 3), DateTime(2036, 10, 4)],
    2037: [DateTime(2037, 2, 15), DateTime(2037, 5, 22), DateTime(2037, 9, 24)],
    2038: [DateTime(2038, 2, 4), DateTime(2038, 5, 11), DateTime(2038, 9, 13)],
    2039: [DateTime(2039, 1, 24), DateTime(2039, 4, 30), DateTime(2039, 10, 2)],
    2040: [DateTime(2040, 2, 12), DateTime(2040, 5, 18), DateTime(2040, 9, 21)],
  };

  /// Federal + BC statutory holidays (settings label is "Canada/Vancouver").
  static List<Holiday> _canada(int year) => [
        Holiday(date: DateTime(year, 1, 1), name: "New Year's Day", country: HolidayCountry.canada),
        Holiday(
          date: _nthWeekdayOfMonth(year, 2, DateTime.monday, 3),
          name: 'Family Day',
          country: HolidayCountry.canada,
        ),
        Holiday(
          date: _lastWeekdayBefore(DateTime(year, 5, 25), DateTime.monday),
          name: 'Victoria Day',
          country: HolidayCountry.canada,
        ),
        Holiday(date: DateTime(year, 7, 1), name: 'Canada Day', country: HolidayCountry.canada),
        Holiday(
          date: _nthWeekdayOfMonth(year, 8, DateTime.monday, 1),
          name: 'BC Day',
          country: HolidayCountry.canada,
        ),
        Holiday(
          date: _nthWeekdayOfMonth(year, 9, DateTime.monday, 1),
          name: 'Labour Day',
          country: HolidayCountry.canada,
        ),
        Holiday(
          date: _nthWeekdayOfMonth(year, 10, DateTime.monday, 2),
          name: 'Thanksgiving',
          country: HolidayCountry.canada,
        ),
        Holiday(date: DateTime(year, 11, 11), name: 'Remembrance Day', country: HolidayCountry.canada),
        Holiday(date: DateTime(year, 12, 25), name: 'Christmas Day', country: HolidayCountry.canada),
        Holiday(date: DateTime(year, 12, 26), name: 'Boxing Day', country: HolidayCountry.canada),
      ];

  /// The [n]th occurrence of [weekday] (1=Monday..7=Sunday) in [month].
  static DateTime _nthWeekdayOfMonth(int year, int month, int weekday, int n) {
    DateTime d = DateTime(year, month, 1);
    int count = 0;
    while (true) {
      if (d.weekday == weekday) {
        count++;
        if (count == n) return d;
      }
      d = d.add(const Duration(days: 1));
    }
  }

  /// The most recent [weekday] strictly before [date] (e.g. "Monday before
  /// May 25" for Victoria Day).
  static DateTime _lastWeekdayBefore(DateTime date, int weekday) {
    DateTime d = date.subtract(const Duration(days: 1));
    while (d.weekday != weekday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }
}

import 'dart:math';

import 'holiday_model.dart';

/// Computes the 24 solar terms (24절기) for a given Gregorian year via a real
/// astronomical calculation of the Sun's apparent geocentric ecliptic
/// longitude — not a hardcoded/guessed table, so it works correctly for any
/// year rather than only a bounded lookup range (contrast with
/// HolidayService's lunar KR holidays, which genuinely do require a
/// lunisolar conversion table and are hardcoded for that reason).
///
/// Formula source: US Naval Observatory, "Computing Approximate Solar
/// Coordinates" (https://aa.usno.navy.mil/faq/sun_approx) — accurate to
/// about 1 arcminute within two centuries of 2000. That's far more
/// precision than this needs: the Sun moves ~1deg/day and solar terms are
/// spaced 15deg apart, so a 1-arcminute longitude error is only ~1 minute of
/// time error, nowhere near enough to shift which calendar day a term falls
/// on.
class SolarTermService {
  const SolarTermService._();

  static final DateTime _j2000 = DateTime.utc(2000, 1, 1, 12, 0, 0);

  /// The 24 terms in the order they occur within a single Gregorian year,
  /// starting from "Slight Cold" (小寒/소한, ecliptic longitude 285°, early
  /// Jan) through "Winter Solstice" (冬至/동지, 270°, late Dec) — i.e. every
  /// term whose approximate date falls inside that same calendar year.
  /// approxMonth/approxDay just seed the numerical solver below; they don't
  /// need to be exact.
  static const List<_TermDef> _terms = [
    _TermDef('Slight Cold (소한)', 285, 1, 6),
    _TermDef('Great Cold (대한)', 300, 1, 20),
    _TermDef('Beginning of Spring (입춘)', 315, 2, 4),
    _TermDef('Rain Water (우수)', 330, 2, 19),
    _TermDef('Waking of Insects (경칩)', 345, 3, 6),
    _TermDef('Spring Equinox (춘분)', 0, 3, 21),
    _TermDef('Pure Brightness (청명)', 15, 4, 5),
    _TermDef('Grain Rain (곡우)', 30, 4, 20),
    _TermDef('Beginning of Summer (입하)', 45, 5, 6),
    _TermDef('Grain Full (소만)', 60, 5, 21),
    _TermDef('Grain in Ear (망종)', 75, 6, 6),
    _TermDef('Summer Solstice (하지)', 90, 6, 22),
    _TermDef('Slight Heat (소서)', 105, 7, 7),
    _TermDef('Great Heat (대서)', 120, 7, 23),
    _TermDef('Beginning of Autumn (입추)', 135, 8, 8),
    _TermDef('Limit of Heat (처서)', 150, 8, 23),
    _TermDef('White Dew (백로)', 165, 9, 8),
    _TermDef('Autumnal Equinox (추분)', 180, 9, 23),
    _TermDef('Cold Dew (한로)', 195, 10, 8),
    _TermDef('Descent of Frost (상강)', 210, 10, 23),
    _TermDef('Beginning of Winter (입동)', 225, 11, 7),
    _TermDef('Slight Snow (소설)', 240, 11, 22),
    _TermDef('Great Snow (대설)', 255, 12, 7),
    _TermDef('Winter Solstice (동지)', 270, 12, 22),
  ];

  /// All 24 solar terms in [year], as [Holiday]s with
  /// [HolidayCountry.solarTerm], dated in Korea Standard Time (UTC+9) since
  /// that's the conventional timezone these are published in.
  static List<Holiday> forYear(int year) {
    return [
      for (final _TermDef term in _terms)
        Holiday(date: _dateOf(year, term), name: term.name, country: HolidayCountry.solarTerm),
    ];
  }

  static DateTime _dateOf(int year, _TermDef term) {
    final DateTime approx = DateTime.utc(year, term.approxMonth, term.approxDay, 12);
    final DateTime instant = _refine(approx, term.longitudeDeg.toDouble());
    final DateTime kst = instant.add(const Duration(hours: 9));
    return DateTime(kst.year, kst.month, kst.day);
  }

  /// Newton-ish refinement: the Sun's ecliptic longitude increases by a
  /// nearly-constant ~0.9856°/day, so converting the longitude error into a
  /// day-offset and re-evaluating converges to well under a minute of
  /// precision in just a few iterations.
  static DateTime _refine(DateTime approxUtc, double targetDeg) {
    DateTime guess = approxUtc;
    for (int i = 0; i < 4; i++) {
      final double l = _sunEclipticLongitudeDeg(guess);
      double diff = (targetDeg - l) % 360; // Euclidean mod -> [0, 360)
      if (diff > 180) diff -= 360; // shortest signed path, (-180, 180]
      final double dayStep = diff / 0.9856;
      guess = guess.add(Duration(microseconds: (dayStep * Duration.microsecondsPerDay).round()));
    }
    return guess;
  }

  /// Sun's apparent geocentric ecliptic longitude, in degrees [0, 360).
  static double _sunEclipticLongitudeDeg(DateTime whenUtc) {
    final double d = whenUtc.difference(_j2000).inMicroseconds / Duration.microsecondsPerDay;
    final double gDeg = 357.529 + 0.98560028 * d;
    final double qDeg = 280.459 + 0.98564736 * d;
    final double gRad = gDeg * pi / 180;
    final double lDeg = qDeg + 1.915 * sin(gRad) + 0.020 * sin(2 * gRad);
    return lDeg % 360;
  }
}

class _TermDef {
  const _TermDef(this.name, this.longitudeDeg, this.approxMonth, this.approxDay);
  final String name;
  final int longitudeDeg;
  final int approxMonth;
  final int approxDay;
}

/// App-wide settings (syncable later; distinct from device-local
/// [WidgetPreference]).
///
/// Holiday/lunar/solar-term calculation is intentionally NOT implemented in
/// MVP — these booleans only gate UI toggles and future data-source lookups.
/// See ARCHITECTURE.md "Calendar data TODOs".
class AppSettings {
  const AppSettings({
    this.id = 'default',
    this.startDayOfWeek = 1, // Monday, matches DateTime.weekday numbering
    this.showKoreanHolidays = false,
    this.showCanadaHolidays = false,
    this.showLunarCalendar = false,
    this.showSolarTerms = false,
    this.showCompletedTasksOnCalendar = true,
    this.showOverdueTasksOnCalendar = true,
    this.monthItemTextScale = 1.3,
    required this.updatedAt,
  });

  final String id;
  final int startDayOfWeek;
  final bool showKoreanHolidays;
  final bool showCanadaHolidays;
  final bool showLunarCalendar;
  final bool showSolarTerms;
  final bool showCompletedTasksOnCalendar;
  final bool showOverdueTasksOnCalendar;

  /// Multiplier applied to month-view chip/holiday text size — see
  /// CalendarSettingsSection's "Month view text size" slider and
  /// CalendarDayCell/_MultiDayBarChip, which read this to scale their fixed
  /// base font sizes.
  final double monthItemTextScale;
  final DateTime updatedAt;

  AppSettings copyWith({
    int? startDayOfWeek,
    bool? showKoreanHolidays,
    bool? showCanadaHolidays,
    bool? showLunarCalendar,
    bool? showSolarTerms,
    bool? showCompletedTasksOnCalendar,
    bool? showOverdueTasksOnCalendar,
    double? monthItemTextScale,
    DateTime? updatedAt,
  }) =>
      AppSettings(
        id: id,
        startDayOfWeek: startDayOfWeek ?? this.startDayOfWeek,
        showKoreanHolidays: showKoreanHolidays ?? this.showKoreanHolidays,
        showCanadaHolidays: showCanadaHolidays ?? this.showCanadaHolidays,
        showLunarCalendar: showLunarCalendar ?? this.showLunarCalendar,
        showSolarTerms: showSolarTerms ?? this.showSolarTerms,
        showCompletedTasksOnCalendar:
            showCompletedTasksOnCalendar ?? this.showCompletedTasksOnCalendar,
        showOverdueTasksOnCalendar:
            showOverdueTasksOnCalendar ?? this.showOverdueTasksOnCalendar,
        monthItemTextScale: monthItemTextScale ?? this.monthItemTextScale,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDayOfWeek': startDayOfWeek,
        'showKoreanHolidays': showKoreanHolidays,
        'showCanadaHolidays': showCanadaHolidays,
        'showLunarCalendar': showLunarCalendar,
        'showSolarTerms': showSolarTerms,
        'showCompletedTasksOnCalendar': showCompletedTasksOnCalendar,
        'showOverdueTasksOnCalendar': showOverdueTasksOnCalendar,
        'monthItemTextScale': monthItemTextScale,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        id: json['id'] as String? ?? 'default',
        startDayOfWeek: json['startDayOfWeek'] as int? ?? 1,
        showKoreanHolidays: json['showKoreanHolidays'] as bool? ?? false,
        showCanadaHolidays: json['showCanadaHolidays'] as bool? ?? false,
        showLunarCalendar: json['showLunarCalendar'] as bool? ?? false,
        showSolarTerms: json['showSolarTerms'] as bool? ?? false,
        showCompletedTasksOnCalendar: json['showCompletedTasksOnCalendar'] as bool? ?? true,
        showOverdueTasksOnCalendar: json['showOverdueTasksOnCalendar'] as bool? ?? true,
        monthItemTextScale: (json['monthItemTextScale'] as num?)?.toDouble() ?? 1.3,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

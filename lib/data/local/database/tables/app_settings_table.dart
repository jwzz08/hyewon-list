import 'package:drift/drift.dart';

/// Single-row table (id is always `'default'`). Syncable later, unlike
/// [WidgetPreferences]. See ARCHITECTURE.md "Sync boundaries".
///
/// Holiday/lunar/solar-term flags only gate UI toggles for MVP — no actual
/// calculation is implemented yet. See ARCHITECTURE.md "Calendar data TODOs".
@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  TextColumn get id => text()();
  IntColumn get startDayOfWeek => integer().withDefault(const Constant(1))();
  BoolColumn get showKoreanHolidays => boolean().withDefault(const Constant(false))();
  BoolColumn get showCanadaHolidays => boolean().withDefault(const Constant(false))();
  BoolColumn get showLunarCalendar => boolean().withDefault(const Constant(false))();
  BoolColumn get showSolarTerms => boolean().withDefault(const Constant(false))();
  BoolColumn get showCompletedTasksOnCalendar =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showOverdueTasksOnCalendar =>
      boolean().withDefault(const Constant(true))();

  /// Multiplier applied to month-view chip/holiday text (see
  /// CalendarDayCell/_MultiDayBarChip) — the fixed 9px chip text read as too
  /// small to some users. 1.0 = original size; default is already bumped up
  /// from that since the un-scaled size was the actual complaint.
  RealColumn get monthItemTextScale => real().withDefault(const Constant(1.3))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

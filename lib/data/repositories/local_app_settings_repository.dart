import 'package:drift/drift.dart' show Value;

import '../../domain/models/app_settings.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../local/dao/app_settings_dao.dart';
import '../local/database/database.dart';

class LocalAppSettingsRepository implements AppSettingsRepository {
  LocalAppSettingsRepository(this._dao);

  final AppSettingsDao _dao;

  @override
  Stream<AppSettings> watch() => _dao.watch().map(_mapRow);

  @override
  Future<AppSettings> get() async => _mapRow(await _dao.getOnce());

  @override
  Future<void> save(AppSettings settings) => _dao.save(AppSettingsTableCompanion(
        id: const Value(kDefaultAppSettingsId),
        startDayOfWeek: Value(settings.startDayOfWeek),
        showKoreanHolidays: Value(settings.showKoreanHolidays),
        showCanadaHolidays: Value(settings.showCanadaHolidays),
        showLunarCalendar: Value(settings.showLunarCalendar),
        showSolarTerms: Value(settings.showSolarTerms),
        showCompletedTasksOnCalendar: Value(settings.showCompletedTasksOnCalendar),
        showOverdueTasksOnCalendar: Value(settings.showOverdueTasksOnCalendar),
        monthItemTextScale: Value(settings.monthItemTextScale),
        updatedAt: Value(settings.updatedAt),
      ));

  AppSettings _mapRow(AppSettingsRow? row) {
    if (row == null) {
      return AppSettings(updatedAt: DateTime.now());
    }
    return AppSettings(
      id: row.id,
      startDayOfWeek: row.startDayOfWeek,
      showKoreanHolidays: row.showKoreanHolidays,
      showCanadaHolidays: row.showCanadaHolidays,
      showLunarCalendar: row.showLunarCalendar,
      showSolarTerms: row.showSolarTerms,
      showCompletedTasksOnCalendar: row.showCompletedTasksOnCalendar,
      showOverdueTasksOnCalendar: row.showOverdueTasksOnCalendar,
      monthItemTextScale: row.monthItemTextScale,
      updatedAt: row.updatedAt,
    );
  }
}

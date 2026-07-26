import 'package:drift/drift.dart';

import '../database/database.dart';

const String kDefaultWidgetPreferenceId = 'default';

class WidgetPreferenceDao {
  WidgetPreferenceDao(this._db);

  final AppDatabase _db;

  Stream<WidgetPreferenceRow?> watch() {
    return (_db.select(_db.widgetPreferences)
          ..where((w) => w.id.equals(kDefaultWidgetPreferenceId)))
        .watchSingleOrNull();
  }

  Future<WidgetPreferenceRow?> getOnce() => (_db.select(_db.widgetPreferences)
        ..where((w) => w.id.equals(kDefaultWidgetPreferenceId)))
      .getSingleOrNull();

  Future<void> save(WidgetPreferencesCompanion entry) =>
      _db.into(_db.widgetPreferences).insertOnConflictUpdate(entry);
}

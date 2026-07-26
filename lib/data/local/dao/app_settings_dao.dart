import 'package:drift/drift.dart';

import '../database/database.dart';

const String kDefaultAppSettingsId = 'default';

class AppSettingsDao {
  AppSettingsDao(this._db);

  final AppDatabase _db;

  Stream<AppSettingsRow?> watch() {
    return (_db.select(_db.appSettingsTable)
          ..where((s) => s.id.equals(kDefaultAppSettingsId)))
        .watchSingleOrNull();
  }

  Future<AppSettingsRow?> getOnce() => (_db.select(_db.appSettingsTable)
        ..where((s) => s.id.equals(kDefaultAppSettingsId)))
      .getSingleOrNull();

  Future<void> save(AppSettingsTableCompanion entry) =>
      _db.into(_db.appSettingsTable).insertOnConflictUpdate(entry);
}

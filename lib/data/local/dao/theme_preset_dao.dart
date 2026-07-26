import 'package:drift/drift.dart';

import '../database/database.dart';

class ThemePresetDao {
  ThemePresetDao(this._db);

  final AppDatabase _db;

  Stream<List<ThemePresetRow>> watchAll() {
    return (_db.select(_db.themePresets)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch();
  }

  Future<ThemePresetRow?> getById(String id) =>
      (_db.select(_db.themePresets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertOrUpdate(ThemePresetsCompanion entry) =>
      _db.into(_db.themePresets).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (_db.delete(_db.themePresets)..where((t) => t.id.equals(id))).go();
}

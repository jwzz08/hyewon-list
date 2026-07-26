import 'package:drift/drift.dart';

import '../database/database.dart';

class TagDao {
  TagDao(this._db);

  final AppDatabase _db;

  Stream<List<TagRow>> watchAll() {
    return (_db.select(_db.tags)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  Future<TagRow?> getById(String id) =>
      (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<TagRow?> getByName(String name) =>
      (_db.select(_db.tags)..where((t) => t.name.equals(name))).getSingleOrNull();

  Future<void> insertOrUpdate(TagsCompanion entry) =>
      _db.into(_db.tags).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) => (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
}

import 'package:drift/drift.dart';

import '../database/database.dart';

class CategoryDao {
  CategoryDao(this._db);

  final AppDatabase _db;

  Stream<List<CategoryRow>> watchAll() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
        .watch();
  }

  Future<CategoryRow?> getById(String id) =>
      (_db.select(_db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<void> insertOrUpdate(CategoriesCompanion entry) =>
      _db.into(_db.categories).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();

  Future<List<CategoryRow>> getAllOnce() => _db.select(_db.categories).get();
}

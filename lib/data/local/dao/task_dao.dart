import 'package:drift/drift.dart';

import '../database/database.dart';

/// Thin query layer over the `Tasks` table. Returns raw [TaskRow]s —
/// mapping to/from the domain `Task` model happens in
/// data/repositories/drift_task_repository.dart, keeping Drift entirely out
/// of the domain/feature layers.
class TaskDao {
  TaskDao(this._db);

  final AppDatabase _db;

  Stream<List<TaskRow>> watchAll() {
    return (_db.select(_db.tasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.createdAt),
          ]))
        .watch();
  }

  Stream<List<TaskRow>> watchByDateRange(DateTime start, DateTime end) {
    return (_db.select(_db.tasks)
          ..where((t) => t.dueDate.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch();
  }

  Stream<List<TaskRow>> watchOverdue() {
    final DateTime today = DateTime.now();
    final DateTime todayStart = DateTime(today.year, today.month, today.day);
    return (_db.select(_db.tasks)
          ..where((t) => t.dueDate.isSmallerThanValue(todayStart) & t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch();
  }

  Stream<List<TaskRow>> watchCompleted() {
    return (_db.select(_db.tasks)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<TaskRow?> getById(String id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertOrUpdate(TasksCompanion entry) =>
      _db.into(_db.tasks).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();

  Future<List<TaskRow>> searchByText(String query) {
    final String like = '%$query%';
    return (_db.select(_db.tasks)
          ..where((t) => t.title.like(like) | t.description.like(like)))
        .get();
  }

  Future<List<TaskRow>> getAllOnce() => _db.select(_db.tasks).get();
}

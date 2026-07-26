import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/utils/id_generator.dart';
import '../../domain/models/priority.dart';
import '../../domain/models/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/dao/task_dao.dart';
import '../local/database/database.dart';

/// Drift-backed implementation of [TaskRepository]. Owns all mapping between
/// the persistence row ([TaskRow]/[TasksCompanion]) and the domain [Task]
/// model, so no other layer needs to know Drift exists.
class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this._dao);

  final TaskDao _dao;

  @override
  Stream<List<Task>> watchAll() => _dao.watchAll().map(_mapRows);

  @override
  Stream<List<Task>> watchByDateRange(DateTime start, DateTime end) =>
      _dao.watchByDateRange(start, end).map(_mapRows);

  @override
  Stream<List<Task>> watchOverdue() => _dao.watchOverdue().map(_mapRows);

  @override
  Stream<List<Task>> watchCompleted() => _dao.watchCompleted().map(_mapRows);

  @override
  Future<Task?> getById(String id) async {
    final TaskRow? row = await _dao.getById(id);
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> create(Task task) => _dao.insertOrUpdate(_toCompanion(task));

  @override
  Future<void> update(Task task) => _dao.insertOrUpdate(_toCompanion(task));

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  @override
  Future<void> setCompleted(String id, bool isCompleted) async {
    final Task? task = await getById(id);
    if (task == null) return;
    final DateTime now = DateTime.now();
    await update(task.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? now : null,
      updatedAt: now,
    ));
  }

  @override
  Future<void> moveToDate(String id, DateTime? newDueDate) async {
    final Task? task = await getById(id);
    if (task == null) return;
    await update(task.copyWith(dueDate: newDueDate, updatedAt: DateTime.now()));
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      final Task? task = await getById(orderedIds[i]);
      if (task == null) continue;
      await update(task.copyWith(sortOrder: i, updatedAt: DateTime.now()));
    }
  }

  @override
  Future<List<Task>> searchByText(String query) async {
    final List<TaskRow> rows = await _dao.searchByText(query);
    return _mapRows(rows);
  }

  List<Task> _mapRows(List<TaskRow> rows) => rows.map(_mapRow).toList();

  Task _mapRow(TaskRow row) {
    final List<String> tagIds =
        (jsonDecode(row.tagIdsJson) as List).cast<String>();
    return Task(
      id: row.id,
      title: row.title,
      description: row.description,
      isCompleted: row.isCompleted,
      dueDate: row.dueDate,
      dueTimeMinutes: row.dueTimeMinutes,
      priority: TaskPriority.fromValue(row.priority),
      categoryId: row.categoryId,
      tagIds: tagIds,
      sortOrder: row.sortOrder,
      reminderMinutesBefore: row.reminderMinutesBefore,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }

  TasksCompanion _toCompanion(Task task) => TasksCompanion(
        id: Value(task.id),
        title: Value(task.title),
        description: Value(task.description),
        isCompleted: Value(task.isCompleted),
        dueDate: Value(task.dueDate),
        dueTimeMinutes: Value(task.dueTimeMinutes),
        priority: Value(task.priority.value),
        categoryId: Value(task.categoryId),
        tagIdsJson: Value(jsonEncode(task.tagIds)),
        sortOrder: Value(task.sortOrder),
        reminderMinutesBefore: Value(task.reminderMinutesBefore),
        createdAt: Value(task.createdAt),
        updatedAt: Value(task.updatedAt),
        completedAt: Value(task.completedAt),
      );

  /// Helper for [ImportExportService] and initial sample-data seeding.
  static Task newTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int? dueTimeMinutes,
    TaskPriority priority = TaskPriority.medium,
    String? categoryId,
    List<String> tagIds = const [],
  }) {
    final DateTime now = DateTime.now();
    return Task(
      id: IdGenerator.newId(),
      title: title,
      description: description,
      dueDate: dueDate,
      dueTimeMinutes: dueTimeMinutes,
      priority: priority,
      categoryId: categoryId,
      tagIds: tagIds,
      createdAt: now,
      updatedAt: now,
    );
  }
}

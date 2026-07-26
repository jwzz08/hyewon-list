import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/priority.dart';
import '../../../domain/models/task.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../reminders/domain/reminder_scheduler.dart';

final StreamProvider<List<Task>> allTasksProvider =
    StreamProvider<List<Task>>((ref) => ref.watch(taskRepositoryProvider).watchAll());

final StreamProvider<List<Task>> overdueTasksProvider =
    StreamProvider<List<Task>>((ref) => ref.watch(taskRepositoryProvider).watchOverdue());

final StreamProvider<List<Task>> completedTasksProvider =
    StreamProvider<List<Task>>((ref) => ref.watch(taskRepositoryProvider).watchCompleted());

final StreamProvider<List<Task>> todayTasksProvider = StreamProvider<List<Task>>((ref) {
  final DateTime todayStart = AppDateUtils.dateOnly(DateTime.now());
  final DateTime todayEnd = todayStart.add(const Duration(hours: 23, minutes: 59, seconds: 59));
  return ref.watch(taskRepositoryProvider).watchByDateRange(todayStart, todayEnd);
});

/// Keyed by `(rangeStart, rangeEnd)` — Dart records give this family
/// structural equality for free, so callers can pass fresh DateTime pairs
/// each build without breaking Riverpod's caching.
final StreamProviderFamily<List<Task>, (DateTime, DateTime)> tasksInRangeProvider =
    StreamProvider.family<List<Task>, (DateTime, DateTime)>((ref, range) {
  return ref.watch(taskRepositoryProvider).watchByDateRange(range.$1, range.$2);
});

/// Thin facade over [TaskRepository] for CRUD actions from the UI, so
/// widgets never import the repository provider directly.
class TaskActions {
  TaskActions(this._repository, this._reminderScheduler);

  final TaskRepository _repository;
  final ReminderScheduler _reminderScheduler;

  Future<void> create(Task task) async {
    await _repository.create(task);
    await _reminderScheduler.syncForTask(task);
  }

  /// Convenience for quick-add UI (widget mode + weekly planner composer) —
  /// builds a well-formed [Task] (id/timestamps) from just a title so
  /// widgets never need to touch [IdGenerator] or construct the model by
  /// hand.
  Future<void> createQuickTask(
    String title, {
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    String? categoryId,
  }) {
    final DateTime now = DateTime.now();
    return create(Task(
      id: IdGenerator.newId(),
      title: title,
      dueDate: dueDate,
      priority: priority,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> update(Task task) async {
    await _repository.update(task);
    await _reminderScheduler.syncForTask(task);
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await _reminderScheduler.cancelForTask(id);
  }

  Future<void> setCompleted(String id, bool isCompleted) async {
    await _repository.setCompleted(id, isCompleted);
    final Task? task = await _repository.getById(id);
    if (task != null) await _reminderScheduler.syncForTask(task);
  }

  /// Used by drag-and-drop (weekly planner + month view).
  Future<void> moveToDate(String id, DateTime? newDueDate) async {
    await _repository.moveToDate(id, newDueDate);
    final Task? task = await _repository.getById(id);
    if (task != null) await _reminderScheduler.syncForTask(task);
  }

  Future<List<Task>> search(String query) => _repository.searchByText(query);
}

final Provider<TaskActions> taskActionsProvider = Provider<TaskActions>(
  (ref) => TaskActions(ref.watch(taskRepositoryProvider), ref.watch(reminderSchedulerProvider)),
);

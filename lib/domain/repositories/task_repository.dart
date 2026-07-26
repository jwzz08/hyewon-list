import '../models/task.dart';

/// Persistence-agnostic contract for tasks. [DriftTaskRepository] is the
/// only implementation for now; a future `FirebaseTaskRepository` or
/// sync-decorator can implement the same interface without touching any
/// feature code (see ARCHITECTURE.md).
abstract class TaskRepository {
  Stream<List<Task>> watchAll();

  /// Inclusive date range, compared on [Task.dueDate] only (date part).
  Stream<List<Task>> watchByDateRange(DateTime start, DateTime end);

  Stream<List<Task>> watchOverdue();

  Stream<List<Task>> watchCompleted();

  Future<Task?> getById(String id);

  Future<void> create(Task task);

  Future<void> update(Task task);

  Future<void> delete(String id);

  Future<void> setCompleted(String id, bool isCompleted);

  /// Used by drag-and-drop: changes only the due date, preserving time.
  Future<void> moveToDate(String id, DateTime? newDueDate);

  Future<void> reorder(List<String> orderedIds);

  Future<List<Task>> searchByText(String query);
}

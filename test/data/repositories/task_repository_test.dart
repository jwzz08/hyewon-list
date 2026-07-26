import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyewon_list/data/local/dao/task_dao.dart';
import 'package:hyewon_list/data/local/database/database.dart';
import 'package:hyewon_list/data/repositories/drift_task_repository.dart';
import 'package:hyewon_list/domain/models/priority.dart';
import 'package:hyewon_list/domain/models/task.dart';

/// Round-trip tests for [DriftTaskRepository] against an in-memory database
/// (`AppDatabase.forTesting(NativeDatabase.memory())`, already wired for
/// this per ARCHITECTURE.md). Run with `flutter test` locally — this
/// exercises the real generated `database.g.dart`, so it also doubles as a
/// compile-time check that the Task<->TaskRow mapping (including the
/// `reminderMinutesBefore` column added for reminders) is correct.
void main() {
  late AppDatabase db;
  late DriftTaskRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTaskRepository(TaskDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  Task buildTask({
    String id = 't1',
    String title = 'Buy groceries',
    DateTime? dueDate,
    int? dueTimeMinutes,
    TaskPriority priority = TaskPriority.medium,
    String? categoryId,
    List<String> tagIds = const [],
    int? reminderMinutesBefore,
    bool isCompleted = false,
  }) {
    final DateTime now = DateTime(2026, 7, 1);
    return Task(
      id: id,
      title: title,
      dueDate: dueDate,
      dueTimeMinutes: dueTimeMinutes,
      priority: priority,
      categoryId: categoryId,
      tagIds: tagIds,
      reminderMinutesBefore: reminderMinutesBefore,
      isCompleted: isCompleted,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('create then getById round-trips every field', () async {
    final Task task = buildTask(
      dueDate: DateTime(2026, 7, 10),
      dueTimeMinutes: 9 * 60,
      priority: TaskPriority.high,
      categoryId: 'cat-1',
      tagIds: const ['tag-a', 'tag-b'],
      reminderMinutesBefore: 30,
    );
    await repository.create(task);

    final Task? loaded = await repository.getById('t1');
    expect(loaded, isNotNull);
    expect(loaded!.title, task.title);
    expect(loaded.dueDate, task.dueDate);
    expect(loaded.dueTimeMinutes, task.dueTimeMinutes);
    expect(loaded.priority, TaskPriority.high);
    expect(loaded.categoryId, 'cat-1');
    expect(loaded.tagIds, ['tag-a', 'tag-b']);
    expect(loaded.reminderMinutesBefore, 30);
  });

  test('update overwrites fields via upsert semantics (create/update interchangeable)', () async {
    await repository.create(buildTask(title: 'Original title'));
    final Task? original = await repository.getById('t1');
    await repository.update(original!.copyWith(title: 'Updated title'));

    final Task? updated = await repository.getById('t1');
    expect(updated!.title, 'Updated title');
  });

  test('delete removes the row', () async {
    await repository.create(buildTask());
    await repository.delete('t1');
    expect(await repository.getById('t1'), isNull);
  });

  test('setCompleted sets isCompleted and completedAt, and can be undone', () async {
    await repository.create(buildTask());

    await repository.setCompleted('t1', true);
    final Task? completed = await repository.getById('t1');
    expect(completed!.isCompleted, isTrue);
    expect(completed.completedAt, isNotNull);

    // Regression coverage for "완료된 일정도 보고, 실수면 취소할 수도 있게" —
    // un-completing must be possible and must clear completedAt.
    await repository.setCompleted('t1', false);
    final Task? uncompleted = await repository.getById('t1');
    expect(uncompleted!.isCompleted, isFalse);
    expect(uncompleted.completedAt, isNull);
  });

  test('moveToDate changes dueDate only', () async {
    await repository.create(buildTask(dueDate: DateTime(2026, 7, 1)));
    await repository.moveToDate('t1', DateTime(2026, 7, 15));
    final Task? moved = await repository.getById('t1');
    expect(moved!.dueDate, DateTime(2026, 7, 15));
  });

  test('watchByDateRange only returns tasks due within the range', () async {
    await repository.create(buildTask(id: 'in-range', dueDate: DateTime(2026, 7, 10)));
    await repository.create(buildTask(id: 'out-of-range', dueDate: DateTime(2026, 8, 1)));

    final List<Task> tasks =
        await repository.watchByDateRange(DateTime(2026, 7, 1), DateTime(2026, 7, 31)).first;
    expect(tasks.map((t) => t.id), ['in-range']);
  });

  test('searchByText matches title', () async {
    await repository.create(buildTask(id: 't1', title: 'Renew passport'));
    await repository.create(buildTask(id: 't2', title: 'Buy milk'));

    final List<Task> results = await repository.searchByText('passport');
    expect(results.map((t) => t.id), ['t1']);
  });
}

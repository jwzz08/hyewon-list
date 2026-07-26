import 'package:drift/drift.dart';

/// MVP simplification: [tagIdsJson] stores a JSON-encoded `List<String>` of
/// tag IDs directly on the row instead of a normalized `TaskTags` join
/// table. This is enough for tagging/filtering at MVP scale and keeps
/// queries simple; if tag-heavy features grow, replace with a real join
/// table without changing the domain [Task] model (it already exposes
/// `tagIds` as a plain list — only DriftTaskRepository would change).
@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get dueTimeMinutes => integer().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  // TODO(schema): add .references(Categories, #id) once category deletion
  // cascade/set-null behavior is decided.
  TextColumn get categoryId => text().nullable()();
  TextColumn get tagIdsJson => text().withDefault(const Constant('[]'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Minutes before `dueDate`+`dueTimeMinutes` to fire a local notification.
  /// Null = no reminder. Added in schema v2 — see database.dart migration.
  IntColumn get reminderMinutesBefore => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

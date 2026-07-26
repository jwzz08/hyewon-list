// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueTimeMinutesMeta =
      const VerificationMeta('dueTimeMinutes');
  @override
  late final GeneratedColumn<int> dueTimeMinutes = GeneratedColumn<int>(
      'due_time_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagIdsJsonMeta =
      const VerificationMeta('tagIdsJson');
  @override
  late final GeneratedColumn<String> tagIdsJson = GeneratedColumn<String>(
      'tag_ids_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reminderMinutesBeforeMeta =
      const VerificationMeta('reminderMinutesBefore');
  @override
  late final GeneratedColumn<int> reminderMinutesBefore = GeneratedColumn<int>(
      'reminder_minutes_before', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        isCompleted,
        dueDate,
        dueTimeMinutes,
        priority,
        categoryId,
        tagIdsJson,
        sortOrder,
        reminderMinutesBefore,
        createdAt,
        updatedAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('due_time_minutes')) {
      context.handle(
          _dueTimeMinutesMeta,
          dueTimeMinutes.isAcceptableOrUnknown(
              data['due_time_minutes']!, _dueTimeMinutesMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('tag_ids_json')) {
      context.handle(
          _tagIdsJsonMeta,
          tagIdsJson.isAcceptableOrUnknown(
              data['tag_ids_json']!, _tagIdsJsonMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('reminder_minutes_before')) {
      context.handle(
          _reminderMinutesBeforeMeta,
          reminderMinutesBefore.isAcceptableOrUnknown(
              data['reminder_minutes_before']!, _reminderMinutesBeforeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      dueTimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_time_minutes']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      tagIdsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_ids_json'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      reminderMinutesBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_minutes_before']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final int? dueTimeMinutes;
  final String priority;
  final String? categoryId;
  final String tagIdsJson;
  final int sortOrder;

  /// Minutes before `dueDate`+`dueTimeMinutes` to fire a local notification.
  /// Null = no reminder. Added in schema v2 — see database.dart migration.
  final int? reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  const TaskRow(
      {required this.id,
      required this.title,
      this.description,
      required this.isCompleted,
      this.dueDate,
      this.dueTimeMinutes,
      required this.priority,
      this.categoryId,
      required this.tagIdsJson,
      required this.sortOrder,
      this.reminderMinutesBefore,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || dueTimeMinutes != null) {
      map['due_time_minutes'] = Variable<int>(dueTimeMinutes);
    }
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['tag_ids_json'] = Variable<String>(tagIdsJson);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || reminderMinutesBefore != null) {
      map['reminder_minutes_before'] = Variable<int>(reminderMinutesBefore);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isCompleted: Value(isCompleted),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      dueTimeMinutes: dueTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(dueTimeMinutes),
      priority: Value(priority),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      tagIdsJson: Value(tagIdsJson),
      sortOrder: Value(sortOrder),
      reminderMinutesBefore: reminderMinutesBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutesBefore),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory TaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      dueTimeMinutes: serializer.fromJson<int?>(json['dueTimeMinutes']),
      priority: serializer.fromJson<String>(json['priority']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      tagIdsJson: serializer.fromJson<String>(json['tagIdsJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      reminderMinutesBefore:
          serializer.fromJson<int?>(json['reminderMinutesBefore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'dueTimeMinutes': serializer.toJson<int?>(dueTimeMinutes),
      'priority': serializer.toJson<String>(priority),
      'categoryId': serializer.toJson<String?>(categoryId),
      'tagIdsJson': serializer.toJson<String>(tagIdsJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'reminderMinutesBefore': serializer.toJson<int?>(reminderMinutesBefore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  TaskRow copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          bool? isCompleted,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<int?> dueTimeMinutes = const Value.absent(),
          String? priority,
          Value<String?> categoryId = const Value.absent(),
          String? tagIdsJson,
          int? sortOrder,
          Value<int?> reminderMinutesBefore = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      TaskRow(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        dueTimeMinutes:
            dueTimeMinutes.present ? dueTimeMinutes.value : this.dueTimeMinutes,
        priority: priority ?? this.priority,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        tagIdsJson: tagIdsJson ?? this.tagIdsJson,
        sortOrder: sortOrder ?? this.sortOrder,
        reminderMinutesBefore: reminderMinutesBefore.present
            ? reminderMinutesBefore.value
            : this.reminderMinutesBefore,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dueTimeMinutes: data.dueTimeMinutes.present
          ? data.dueTimeMinutes.value
          : this.dueTimeMinutes,
      priority: data.priority.present ? data.priority.value : this.priority,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      tagIdsJson:
          data.tagIdsJson.present ? data.tagIdsJson.value : this.tagIdsJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      reminderMinutesBefore: data.reminderMinutesBefore.present
          ? data.reminderMinutesBefore.value
          : this.reminderMinutesBefore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTimeMinutes: $dueTimeMinutes, ')
          ..write('priority: $priority, ')
          ..write('categoryId: $categoryId, ')
          ..write('tagIdsJson: $tagIdsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      isCompleted,
      dueDate,
      dueTimeMinutes,
      priority,
      categoryId,
      tagIdsJson,
      sortOrder,
      reminderMinutesBefore,
      createdAt,
      updatedAt,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isCompleted == this.isCompleted &&
          other.dueDate == this.dueDate &&
          other.dueTimeMinutes == this.dueTimeMinutes &&
          other.priority == this.priority &&
          other.categoryId == this.categoryId &&
          other.tagIdsJson == this.tagIdsJson &&
          other.sortOrder == this.sortOrder &&
          other.reminderMinutesBefore == this.reminderMinutesBefore &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isCompleted;
  final Value<DateTime?> dueDate;
  final Value<int?> dueTimeMinutes;
  final Value<String> priority;
  final Value<String?> categoryId;
  final Value<String> tagIdsJson;
  final Value<int> sortOrder;
  final Value<int?> reminderMinutesBefore;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTimeMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.tagIdsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTimeMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.tagIdsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isCompleted,
    Expression<DateTime>? dueDate,
    Expression<int>? dueTimeMinutes,
    Expression<String>? priority,
    Expression<String>? categoryId,
    Expression<String>? tagIdsJson,
    Expression<int>? sortOrder,
    Expression<int>? reminderMinutesBefore,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (dueDate != null) 'due_date': dueDate,
      if (dueTimeMinutes != null) 'due_time_minutes': dueTimeMinutes,
      if (priority != null) 'priority': priority,
      if (categoryId != null) 'category_id': categoryId,
      if (tagIdsJson != null) 'tag_ids_json': tagIdsJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (reminderMinutesBefore != null)
        'reminder_minutes_before': reminderMinutesBefore,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<bool>? isCompleted,
      Value<DateTime?>? dueDate,
      Value<int?>? dueTimeMinutes,
      Value<String>? priority,
      Value<String?>? categoryId,
      Value<String>? tagIdsJson,
      Value<int>? sortOrder,
      Value<int?>? reminderMinutesBefore,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      dueTimeMinutes: dueTimeMinutes ?? this.dueTimeMinutes,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      tagIdsJson: tagIdsJson ?? this.tagIdsJson,
      sortOrder: sortOrder ?? this.sortOrder,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (dueTimeMinutes.present) {
      map['due_time_minutes'] = Variable<int>(dueTimeMinutes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (tagIdsJson.present) {
      map['tag_ids_json'] = Variable<String>(tagIdsJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (reminderMinutesBefore.present) {
      map['reminder_minutes_before'] =
          Variable<int>(reminderMinutesBefore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTimeMinutes: $dueTimeMinutes, ')
          ..write('priority: $priority, ')
          ..write('categoryId: $categoryId, ')
          ..write('tagIdsJson: $tagIdsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateTimeMeta =
      const VerificationMeta('startDateTime');
  @override
  late final GeneratedColumn<DateTime> startDateTime =
      GeneratedColumn<DateTime>('start_date_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateTimeMeta =
      const VerificationMeta('endDateTime');
  @override
  late final GeneratedColumn<DateTime> endDateTime = GeneratedColumn<DateTime>(
      'end_date_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isAllDayMeta =
      const VerificationMeta('isAllDay');
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
      'is_all_day', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_all_day" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurrenceRuleMeta =
      const VerificationMeta('recurrenceRule');
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
      'recurrence_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceEndDateMeta =
      const VerificationMeta('recurrenceEndDate');
  @override
  late final GeneratedColumn<DateTime> recurrenceEndDate =
      GeneratedColumn<DateTime>('recurrence_end_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceCountMeta =
      const VerificationMeta('recurrenceCount');
  @override
  late final GeneratedColumn<int> recurrenceCount = GeneratedColumn<int>(
      'recurrence_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parentEventIdMeta =
      const VerificationMeta('parentEventId');
  @override
  late final GeneratedColumn<String> parentEventId = GeneratedColumn<String>(
      'parent_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalOccurrenceDateMeta =
      const VerificationMeta('originalOccurrenceDate');
  @override
  late final GeneratedColumn<DateTime> originalOccurrenceDate =
      GeneratedColumn<DateTime>('original_occurrence_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceExceptionDatesJsonMeta =
      const VerificationMeta('recurrenceExceptionDatesJson');
  @override
  late final GeneratedColumn<String> recurrenceExceptionDatesJson =
      GeneratedColumn<String>(
          'recurrence_exception_dates_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _reminderMinutesBeforeMeta =
      const VerificationMeta('reminderMinutesBefore');
  @override
  late final GeneratedColumn<int> reminderMinutesBefore = GeneratedColumn<int>(
      'reminder_minutes_before', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        startDateTime,
        endDateTime,
        isAllDay,
        categoryId,
        color,
        location,
        isRecurring,
        recurrenceRule,
        recurrenceEndDate,
        recurrenceCount,
        parentEventId,
        originalOccurrenceDate,
        recurrenceExceptionDatesJson,
        reminderMinutesBefore,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('start_date_time')) {
      context.handle(
          _startDateTimeMeta,
          startDateTime.isAcceptableOrUnknown(
              data['start_date_time']!, _startDateTimeMeta));
    } else if (isInserting) {
      context.missing(_startDateTimeMeta);
    }
    if (data.containsKey('end_date_time')) {
      context.handle(
          _endDateTimeMeta,
          endDateTime.isAcceptableOrUnknown(
              data['end_date_time']!, _endDateTimeMeta));
    } else if (isInserting) {
      context.missing(_endDateTimeMeta);
    }
    if (data.containsKey('is_all_day')) {
      context.handle(_isAllDayMeta,
          isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
          _recurrenceRuleMeta,
          recurrenceRule.isAcceptableOrUnknown(
              data['recurrence_rule']!, _recurrenceRuleMeta));
    }
    if (data.containsKey('recurrence_end_date')) {
      context.handle(
          _recurrenceEndDateMeta,
          recurrenceEndDate.isAcceptableOrUnknown(
              data['recurrence_end_date']!, _recurrenceEndDateMeta));
    }
    if (data.containsKey('recurrence_count')) {
      context.handle(
          _recurrenceCountMeta,
          recurrenceCount.isAcceptableOrUnknown(
              data['recurrence_count']!, _recurrenceCountMeta));
    }
    if (data.containsKey('parent_event_id')) {
      context.handle(
          _parentEventIdMeta,
          parentEventId.isAcceptableOrUnknown(
              data['parent_event_id']!, _parentEventIdMeta));
    }
    if (data.containsKey('original_occurrence_date')) {
      context.handle(
          _originalOccurrenceDateMeta,
          originalOccurrenceDate.isAcceptableOrUnknown(
              data['original_occurrence_date']!, _originalOccurrenceDateMeta));
    }
    if (data.containsKey('recurrence_exception_dates_json')) {
      context.handle(
          _recurrenceExceptionDatesJsonMeta,
          recurrenceExceptionDatesJson.isAcceptableOrUnknown(
              data['recurrence_exception_dates_json']!,
              _recurrenceExceptionDatesJsonMeta));
    }
    if (data.containsKey('reminder_minutes_before')) {
      context.handle(
          _reminderMinutesBeforeMeta,
          reminderMinutesBefore.isAcceptableOrUnknown(
              data['reminder_minutes_before']!, _reminderMinutesBeforeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      startDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}start_date_time'])!,
      endDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}end_date_time'])!,
      isAllDay: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_all_day'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurrenceRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_rule']),
      recurrenceEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}recurrence_end_date']),
      recurrenceCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_count']),
      parentEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_event_id']),
      originalOccurrenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}original_occurrence_date']),
      recurrenceExceptionDatesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence_exception_dates_json'])!,
      reminderMinutesBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_minutes_before']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEventRow extends DataClass
    implements Insertable<CalendarEventRow> {
  final String id;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isAllDay;
  final String? categoryId;
  final int? color;
  final String? location;
  final bool isRecurring;

  /// RRULE-style string, e.g. `FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR`.
  final String? recurrenceRule;
  final DateTime? recurrenceEndDate;
  final int? recurrenceCount;

  /// Set when this row is a detached single-occurrence override.
  final String? parentEventId;
  final DateTime? originalOccurrenceDate;

  /// JSON array of ISO date strings excluded from the recurring series.
  /// MVP stores this as JSON text; see ARCHITECTURE.md for the future
  /// `RecurrenceExceptions` table if this grows unwieldy.
  final String recurrenceExceptionDatesJson;

  /// Minutes before `startDateTime` to fire a local notification. Null = no
  /// reminder. Added in schema v2 — see database.dart migration. For a
  /// recurring series this only schedules against the parent row's own
  /// `startDateTime` (i.e. the first occurrence) — see ReminderScheduler
  /// doc comment for why per-occurrence recurring reminders are out of scope.
  final int? reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CalendarEventRow(
      {required this.id,
      required this.title,
      this.description,
      required this.startDateTime,
      required this.endDateTime,
      required this.isAllDay,
      this.categoryId,
      this.color,
      this.location,
      required this.isRecurring,
      this.recurrenceRule,
      this.recurrenceEndDate,
      this.recurrenceCount,
      this.parentEventId,
      this.originalOccurrenceDate,
      required this.recurrenceExceptionDatesJson,
      this.reminderMinutesBefore,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_date_time'] = Variable<DateTime>(startDateTime);
    map['end_date_time'] = Variable<DateTime>(endDateTime);
    map['is_all_day'] = Variable<bool>(isAllDay);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || recurrenceEndDate != null) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate);
    }
    if (!nullToAbsent || recurrenceCount != null) {
      map['recurrence_count'] = Variable<int>(recurrenceCount);
    }
    if (!nullToAbsent || parentEventId != null) {
      map['parent_event_id'] = Variable<String>(parentEventId);
    }
    if (!nullToAbsent || originalOccurrenceDate != null) {
      map['original_occurrence_date'] =
          Variable<DateTime>(originalOccurrenceDate);
    }
    map['recurrence_exception_dates_json'] =
        Variable<String>(recurrenceExceptionDatesJson);
    if (!nullToAbsent || reminderMinutesBefore != null) {
      map['reminder_minutes_before'] = Variable<int>(reminderMinutesBefore);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDateTime: Value(startDateTime),
      endDateTime: Value(endDateTime),
      isAllDay: Value(isAllDay),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      isRecurring: Value(isRecurring),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      recurrenceEndDate: recurrenceEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEndDate),
      recurrenceCount: recurrenceCount == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceCount),
      parentEventId: parentEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentEventId),
      originalOccurrenceDate: originalOccurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(originalOccurrenceDate),
      recurrenceExceptionDatesJson: Value(recurrenceExceptionDatesJson),
      reminderMinutesBefore: reminderMinutesBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutesBefore),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CalendarEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEventRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startDateTime: serializer.fromJson<DateTime>(json['startDateTime']),
      endDateTime: serializer.fromJson<DateTime>(json['endDateTime']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      color: serializer.fromJson<int?>(json['color']),
      location: serializer.fromJson<String?>(json['location']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      recurrenceEndDate:
          serializer.fromJson<DateTime?>(json['recurrenceEndDate']),
      recurrenceCount: serializer.fromJson<int?>(json['recurrenceCount']),
      parentEventId: serializer.fromJson<String?>(json['parentEventId']),
      originalOccurrenceDate:
          serializer.fromJson<DateTime?>(json['originalOccurrenceDate']),
      recurrenceExceptionDatesJson:
          serializer.fromJson<String>(json['recurrenceExceptionDatesJson']),
      reminderMinutesBefore:
          serializer.fromJson<int?>(json['reminderMinutesBefore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startDateTime': serializer.toJson<DateTime>(startDateTime),
      'endDateTime': serializer.toJson<DateTime>(endDateTime),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'categoryId': serializer.toJson<String?>(categoryId),
      'color': serializer.toJson<int?>(color),
      'location': serializer.toJson<String?>(location),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'recurrenceEndDate': serializer.toJson<DateTime?>(recurrenceEndDate),
      'recurrenceCount': serializer.toJson<int?>(recurrenceCount),
      'parentEventId': serializer.toJson<String?>(parentEventId),
      'originalOccurrenceDate':
          serializer.toJson<DateTime?>(originalOccurrenceDate),
      'recurrenceExceptionDatesJson':
          serializer.toJson<String>(recurrenceExceptionDatesJson),
      'reminderMinutesBefore': serializer.toJson<int?>(reminderMinutesBefore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CalendarEventRow copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? startDateTime,
          DateTime? endDateTime,
          bool? isAllDay,
          Value<String?> categoryId = const Value.absent(),
          Value<int?> color = const Value.absent(),
          Value<String?> location = const Value.absent(),
          bool? isRecurring,
          Value<String?> recurrenceRule = const Value.absent(),
          Value<DateTime?> recurrenceEndDate = const Value.absent(),
          Value<int?> recurrenceCount = const Value.absent(),
          Value<String?> parentEventId = const Value.absent(),
          Value<DateTime?> originalOccurrenceDate = const Value.absent(),
          String? recurrenceExceptionDatesJson,
          Value<int?> reminderMinutesBefore = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CalendarEventRow(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        startDateTime: startDateTime ?? this.startDateTime,
        endDateTime: endDateTime ?? this.endDateTime,
        isAllDay: isAllDay ?? this.isAllDay,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        color: color.present ? color.value : this.color,
        location: location.present ? location.value : this.location,
        isRecurring: isRecurring ?? this.isRecurring,
        recurrenceRule:
            recurrenceRule.present ? recurrenceRule.value : this.recurrenceRule,
        recurrenceEndDate: recurrenceEndDate.present
            ? recurrenceEndDate.value
            : this.recurrenceEndDate,
        recurrenceCount: recurrenceCount.present
            ? recurrenceCount.value
            : this.recurrenceCount,
        parentEventId:
            parentEventId.present ? parentEventId.value : this.parentEventId,
        originalOccurrenceDate: originalOccurrenceDate.present
            ? originalOccurrenceDate.value
            : this.originalOccurrenceDate,
        recurrenceExceptionDatesJson:
            recurrenceExceptionDatesJson ?? this.recurrenceExceptionDatesJson,
        reminderMinutesBefore: reminderMinutesBefore.present
            ? reminderMinutesBefore.value
            : this.reminderMinutesBefore,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CalendarEventRow copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEventRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      startDateTime: data.startDateTime.present
          ? data.startDateTime.value
          : this.startDateTime,
      endDateTime:
          data.endDateTime.present ? data.endDateTime.value : this.endDateTime,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      color: data.color.present ? data.color.value : this.color,
      location: data.location.present ? data.location.value : this.location,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      recurrenceEndDate: data.recurrenceEndDate.present
          ? data.recurrenceEndDate.value
          : this.recurrenceEndDate,
      recurrenceCount: data.recurrenceCount.present
          ? data.recurrenceCount.value
          : this.recurrenceCount,
      parentEventId: data.parentEventId.present
          ? data.parentEventId.value
          : this.parentEventId,
      originalOccurrenceDate: data.originalOccurrenceDate.present
          ? data.originalOccurrenceDate.value
          : this.originalOccurrenceDate,
      recurrenceExceptionDatesJson: data.recurrenceExceptionDatesJson.present
          ? data.recurrenceExceptionDatesJson.value
          : this.recurrenceExceptionDatesJson,
      reminderMinutesBefore: data.reminderMinutesBefore.present
          ? data.reminderMinutesBefore.value
          : this.reminderMinutesBefore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDateTime: $startDateTime, ')
          ..write('endDateTime: $endDateTime, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('categoryId: $categoryId, ')
          ..write('color: $color, ')
          ..write('location: $location, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('recurrenceCount: $recurrenceCount, ')
          ..write('parentEventId: $parentEventId, ')
          ..write('originalOccurrenceDate: $originalOccurrenceDate, ')
          ..write(
              'recurrenceExceptionDatesJson: $recurrenceExceptionDatesJson, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      startDateTime,
      endDateTime,
      isAllDay,
      categoryId,
      color,
      location,
      isRecurring,
      recurrenceRule,
      recurrenceEndDate,
      recurrenceCount,
      parentEventId,
      originalOccurrenceDate,
      recurrenceExceptionDatesJson,
      reminderMinutesBefore,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEventRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.startDateTime == this.startDateTime &&
          other.endDateTime == this.endDateTime &&
          other.isAllDay == this.isAllDay &&
          other.categoryId == this.categoryId &&
          other.color == this.color &&
          other.location == this.location &&
          other.isRecurring == this.isRecurring &&
          other.recurrenceRule == this.recurrenceRule &&
          other.recurrenceEndDate == this.recurrenceEndDate &&
          other.recurrenceCount == this.recurrenceCount &&
          other.parentEventId == this.parentEventId &&
          other.originalOccurrenceDate == this.originalOccurrenceDate &&
          other.recurrenceExceptionDatesJson ==
              this.recurrenceExceptionDatesJson &&
          other.reminderMinutesBefore == this.reminderMinutesBefore &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEventRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> startDateTime;
  final Value<DateTime> endDateTime;
  final Value<bool> isAllDay;
  final Value<String?> categoryId;
  final Value<int?> color;
  final Value<String?> location;
  final Value<bool> isRecurring;
  final Value<String?> recurrenceRule;
  final Value<DateTime?> recurrenceEndDate;
  final Value<int?> recurrenceCount;
  final Value<String?> parentEventId;
  final Value<DateTime?> originalOccurrenceDate;
  final Value<String> recurrenceExceptionDatesJson;
  final Value<int?> reminderMinutesBefore;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startDateTime = const Value.absent(),
    this.endDateTime = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.color = const Value.absent(),
    this.location = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.recurrenceCount = const Value.absent(),
    this.parentEventId = const Value.absent(),
    this.originalOccurrenceDate = const Value.absent(),
    this.recurrenceExceptionDatesJson = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required DateTime startDateTime,
    required DateTime endDateTime,
    this.isAllDay = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.color = const Value.absent(),
    this.location = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.recurrenceCount = const Value.absent(),
    this.parentEventId = const Value.absent(),
    this.originalOccurrenceDate = const Value.absent(),
    this.recurrenceExceptionDatesJson = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        startDateTime = Value(startDateTime),
        endDateTime = Value(endDateTime),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CalendarEventRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startDateTime,
    Expression<DateTime>? endDateTime,
    Expression<bool>? isAllDay,
    Expression<String>? categoryId,
    Expression<int>? color,
    Expression<String>? location,
    Expression<bool>? isRecurring,
    Expression<String>? recurrenceRule,
    Expression<DateTime>? recurrenceEndDate,
    Expression<int>? recurrenceCount,
    Expression<String>? parentEventId,
    Expression<DateTime>? originalOccurrenceDate,
    Expression<String>? recurrenceExceptionDatesJson,
    Expression<int>? reminderMinutesBefore,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startDateTime != null) 'start_date_time': startDateTime,
      if (endDateTime != null) 'end_date_time': endDateTime,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (categoryId != null) 'category_id': categoryId,
      if (color != null) 'color': color,
      if (location != null) 'location': location,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (recurrenceEndDate != null) 'recurrence_end_date': recurrenceEndDate,
      if (recurrenceCount != null) 'recurrence_count': recurrenceCount,
      if (parentEventId != null) 'parent_event_id': parentEventId,
      if (originalOccurrenceDate != null)
        'original_occurrence_date': originalOccurrenceDate,
      if (recurrenceExceptionDatesJson != null)
        'recurrence_exception_dates_json': recurrenceExceptionDatesJson,
      if (reminderMinutesBefore != null)
        'reminder_minutes_before': reminderMinutesBefore,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? startDateTime,
      Value<DateTime>? endDateTime,
      Value<bool>? isAllDay,
      Value<String?>? categoryId,
      Value<int?>? color,
      Value<String?>? location,
      Value<bool>? isRecurring,
      Value<String?>? recurrenceRule,
      Value<DateTime?>? recurrenceEndDate,
      Value<int?>? recurrenceCount,
      Value<String?>? parentEventId,
      Value<DateTime?>? originalOccurrenceDate,
      Value<String>? recurrenceExceptionDatesJson,
      Value<int?>? reminderMinutesBefore,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isAllDay: isAllDay ?? this.isAllDay,
      categoryId: categoryId ?? this.categoryId,
      color: color ?? this.color,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      recurrenceCount: recurrenceCount ?? this.recurrenceCount,
      parentEventId: parentEventId ?? this.parentEventId,
      originalOccurrenceDate:
          originalOccurrenceDate ?? this.originalOccurrenceDate,
      recurrenceExceptionDatesJson:
          recurrenceExceptionDatesJson ?? this.recurrenceExceptionDatesJson,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDateTime.present) {
      map['start_date_time'] = Variable<DateTime>(startDateTime.value);
    }
    if (endDateTime.present) {
      map['end_date_time'] = Variable<DateTime>(endDateTime.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (recurrenceEndDate.present) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate.value);
    }
    if (recurrenceCount.present) {
      map['recurrence_count'] = Variable<int>(recurrenceCount.value);
    }
    if (parentEventId.present) {
      map['parent_event_id'] = Variable<String>(parentEventId.value);
    }
    if (originalOccurrenceDate.present) {
      map['original_occurrence_date'] =
          Variable<DateTime>(originalOccurrenceDate.value);
    }
    if (recurrenceExceptionDatesJson.present) {
      map['recurrence_exception_dates_json'] =
          Variable<String>(recurrenceExceptionDatesJson.value);
    }
    if (reminderMinutesBefore.present) {
      map['reminder_minutes_before'] =
          Variable<int>(reminderMinutesBefore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDateTime: $startDateTime, ')
          ..write('endDateTime: $endDateTime, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('categoryId: $categoryId, ')
          ..write('color: $color, ')
          ..write('location: $location, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('recurrenceCount: $recurrenceCount, ')
          ..write('parentEventId: $parentEventId, ')
          ..write('originalOccurrenceDate: $originalOccurrenceDate, ')
          ..write(
              'recurrenceExceptionDatesJson: $recurrenceExceptionDatesJson, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, color, icon, sortOrder, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final int color;
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CategoryRow(
      {required this.id,
      required this.name,
      required this.color,
      this.icon,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'icon': serializer.toJson<String?>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CategoryRow copyWith(
          {String? id,
          String? name,
          int? color,
          Value<String?> icon = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryRow(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        icon: icon.present ? icon.value : this.icon,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, icon, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<String?> icon;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int color,
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        color = Value(color),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? color,
      Value<String?>? icon,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<TagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TagRow(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TagRow copyWith(
          {String? id,
          String? name,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TagRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WidgetPreferencesTable extends WidgetPreferences
    with TableInfo<$WidgetPreferencesTable, WidgetPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _windowXMeta =
      const VerificationMeta('windowX');
  @override
  late final GeneratedColumn<double> windowX = GeneratedColumn<double>(
      'window_x', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _windowYMeta =
      const VerificationMeta('windowY');
  @override
  late final GeneratedColumn<double> windowY = GeneratedColumn<double>(
      'window_y', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _windowWidthMeta =
      const VerificationMeta('windowWidth');
  @override
  late final GeneratedColumn<double> windowWidth = GeneratedColumn<double>(
      'window_width', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(360));
  static const VerificationMeta _windowHeightMeta =
      const VerificationMeta('windowHeight');
  @override
  late final GeneratedColumn<double> windowHeight = GeneratedColumn<double>(
      'window_height', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(480));
  static const VerificationMeta _opacityMeta =
      const VerificationMeta('opacity');
  @override
  late final GeneratedColumn<double> opacity = GeneratedColumn<double>(
      'opacity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _backgroundOpacityMeta =
      const VerificationMeta('backgroundOpacity');
  @override
  late final GeneratedColumn<double> backgroundOpacity =
      GeneratedColumn<double>('background_opacity', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(100));
  static const VerificationMeta _cardOpacityMeta =
      const VerificationMeta('cardOpacity');
  @override
  late final GeneratedColumn<double> cardOpacity = GeneratedColumn<double>(
      'card_opacity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _isAlwaysOnTopMeta =
      const VerificationMeta('isAlwaysOnTop');
  @override
  late final GeneratedColumn<bool> isAlwaysOnTop = GeneratedColumn<bool>(
      'is_always_on_top', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_always_on_top" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPositionLockedMeta =
      const VerificationMeta('isPositionLocked');
  @override
  late final GeneratedColumn<bool> isPositionLocked = GeneratedColumn<bool>(
      'is_position_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_position_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSizeLockedMeta =
      const VerificationMeta('isSizeLocked');
  @override
  late final GeneratedColumn<bool> isSizeLocked = GeneratedColumn<bool>(
      'is_size_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_size_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showInTaskbarMeta =
      const VerificationMeta('showInTaskbar');
  @override
  late final GeneratedColumn<bool> showInTaskbar = GeneratedColumn<bool>(
      'show_in_taskbar', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_in_taskbar" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _widgetModeMeta =
      const VerificationMeta('widgetMode');
  @override
  late final GeneratedColumn<String> widgetMode = GeneratedColumn<String>(
      'widget_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('expanded'));
  static const VerificationMeta _themePresetIdMeta =
      const VerificationMeta('themePresetId');
  @override
  late final GeneratedColumn<String> themePresetId = GeneratedColumn<String>(
      'theme_preset_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        windowX,
        windowY,
        windowWidth,
        windowHeight,
        opacity,
        backgroundOpacity,
        cardOpacity,
        isAlwaysOnTop,
        isPositionLocked,
        isSizeLocked,
        showInTaskbar,
        widgetMode,
        themePresetId,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_preferences';
  @override
  VerificationContext validateIntegrity(
      Insertable<WidgetPreferenceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('window_x')) {
      context.handle(_windowXMeta,
          windowX.isAcceptableOrUnknown(data['window_x']!, _windowXMeta));
    }
    if (data.containsKey('window_y')) {
      context.handle(_windowYMeta,
          windowY.isAcceptableOrUnknown(data['window_y']!, _windowYMeta));
    }
    if (data.containsKey('window_width')) {
      context.handle(
          _windowWidthMeta,
          windowWidth.isAcceptableOrUnknown(
              data['window_width']!, _windowWidthMeta));
    }
    if (data.containsKey('window_height')) {
      context.handle(
          _windowHeightMeta,
          windowHeight.isAcceptableOrUnknown(
              data['window_height']!, _windowHeightMeta));
    }
    if (data.containsKey('opacity')) {
      context.handle(_opacityMeta,
          opacity.isAcceptableOrUnknown(data['opacity']!, _opacityMeta));
    }
    if (data.containsKey('background_opacity')) {
      context.handle(
          _backgroundOpacityMeta,
          backgroundOpacity.isAcceptableOrUnknown(
              data['background_opacity']!, _backgroundOpacityMeta));
    }
    if (data.containsKey('card_opacity')) {
      context.handle(
          _cardOpacityMeta,
          cardOpacity.isAcceptableOrUnknown(
              data['card_opacity']!, _cardOpacityMeta));
    }
    if (data.containsKey('is_always_on_top')) {
      context.handle(
          _isAlwaysOnTopMeta,
          isAlwaysOnTop.isAcceptableOrUnknown(
              data['is_always_on_top']!, _isAlwaysOnTopMeta));
    }
    if (data.containsKey('is_position_locked')) {
      context.handle(
          _isPositionLockedMeta,
          isPositionLocked.isAcceptableOrUnknown(
              data['is_position_locked']!, _isPositionLockedMeta));
    }
    if (data.containsKey('is_size_locked')) {
      context.handle(
          _isSizeLockedMeta,
          isSizeLocked.isAcceptableOrUnknown(
              data['is_size_locked']!, _isSizeLockedMeta));
    }
    if (data.containsKey('show_in_taskbar')) {
      context.handle(
          _showInTaskbarMeta,
          showInTaskbar.isAcceptableOrUnknown(
              data['show_in_taskbar']!, _showInTaskbarMeta));
    }
    if (data.containsKey('widget_mode')) {
      context.handle(
          _widgetModeMeta,
          widgetMode.isAcceptableOrUnknown(
              data['widget_mode']!, _widgetModeMeta));
    }
    if (data.containsKey('theme_preset_id')) {
      context.handle(
          _themePresetIdMeta,
          themePresetId.isAcceptableOrUnknown(
              data['theme_preset_id']!, _themePresetIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetPreferenceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      windowX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}window_x']),
      windowY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}window_y']),
      windowWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}window_width'])!,
      windowHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}window_height'])!,
      opacity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}opacity'])!,
      backgroundOpacity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}background_opacity'])!,
      cardOpacity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}card_opacity'])!,
      isAlwaysOnTop: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_always_on_top'])!,
      isPositionLocked: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_position_locked'])!,
      isSizeLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_size_locked'])!,
      showInTaskbar: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_in_taskbar'])!,
      widgetMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}widget_mode'])!,
      themePresetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_preset_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WidgetPreferencesTable createAlias(String alias) {
    return $WidgetPreferencesTable(attachedDatabase, alias);
  }
}

class WidgetPreferenceRow extends DataClass
    implements Insertable<WidgetPreferenceRow> {
  final String id;
  final double? windowX;
  final double? windowY;
  final double windowWidth;
  final double windowHeight;
  final double opacity;
  final double backgroundOpacity;
  final double cardOpacity;
  final bool isAlwaysOnTop;
  final bool isPositionLocked;
  final bool isSizeLocked;
  final bool showInTaskbar;
  final String widgetMode;
  final String? themePresetId;
  final DateTime updatedAt;
  const WidgetPreferenceRow(
      {required this.id,
      this.windowX,
      this.windowY,
      required this.windowWidth,
      required this.windowHeight,
      required this.opacity,
      required this.backgroundOpacity,
      required this.cardOpacity,
      required this.isAlwaysOnTop,
      required this.isPositionLocked,
      required this.isSizeLocked,
      required this.showInTaskbar,
      required this.widgetMode,
      this.themePresetId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || windowX != null) {
      map['window_x'] = Variable<double>(windowX);
    }
    if (!nullToAbsent || windowY != null) {
      map['window_y'] = Variable<double>(windowY);
    }
    map['window_width'] = Variable<double>(windowWidth);
    map['window_height'] = Variable<double>(windowHeight);
    map['opacity'] = Variable<double>(opacity);
    map['background_opacity'] = Variable<double>(backgroundOpacity);
    map['card_opacity'] = Variable<double>(cardOpacity);
    map['is_always_on_top'] = Variable<bool>(isAlwaysOnTop);
    map['is_position_locked'] = Variable<bool>(isPositionLocked);
    map['is_size_locked'] = Variable<bool>(isSizeLocked);
    map['show_in_taskbar'] = Variable<bool>(showInTaskbar);
    map['widget_mode'] = Variable<String>(widgetMode);
    if (!nullToAbsent || themePresetId != null) {
      map['theme_preset_id'] = Variable<String>(themePresetId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WidgetPreferencesCompanion toCompanion(bool nullToAbsent) {
    return WidgetPreferencesCompanion(
      id: Value(id),
      windowX: windowX == null && nullToAbsent
          ? const Value.absent()
          : Value(windowX),
      windowY: windowY == null && nullToAbsent
          ? const Value.absent()
          : Value(windowY),
      windowWidth: Value(windowWidth),
      windowHeight: Value(windowHeight),
      opacity: Value(opacity),
      backgroundOpacity: Value(backgroundOpacity),
      cardOpacity: Value(cardOpacity),
      isAlwaysOnTop: Value(isAlwaysOnTop),
      isPositionLocked: Value(isPositionLocked),
      isSizeLocked: Value(isSizeLocked),
      showInTaskbar: Value(showInTaskbar),
      widgetMode: Value(widgetMode),
      themePresetId: themePresetId == null && nullToAbsent
          ? const Value.absent()
          : Value(themePresetId),
      updatedAt: Value(updatedAt),
    );
  }

  factory WidgetPreferenceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetPreferenceRow(
      id: serializer.fromJson<String>(json['id']),
      windowX: serializer.fromJson<double?>(json['windowX']),
      windowY: serializer.fromJson<double?>(json['windowY']),
      windowWidth: serializer.fromJson<double>(json['windowWidth']),
      windowHeight: serializer.fromJson<double>(json['windowHeight']),
      opacity: serializer.fromJson<double>(json['opacity']),
      backgroundOpacity: serializer.fromJson<double>(json['backgroundOpacity']),
      cardOpacity: serializer.fromJson<double>(json['cardOpacity']),
      isAlwaysOnTop: serializer.fromJson<bool>(json['isAlwaysOnTop']),
      isPositionLocked: serializer.fromJson<bool>(json['isPositionLocked']),
      isSizeLocked: serializer.fromJson<bool>(json['isSizeLocked']),
      showInTaskbar: serializer.fromJson<bool>(json['showInTaskbar']),
      widgetMode: serializer.fromJson<String>(json['widgetMode']),
      themePresetId: serializer.fromJson<String?>(json['themePresetId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'windowX': serializer.toJson<double?>(windowX),
      'windowY': serializer.toJson<double?>(windowY),
      'windowWidth': serializer.toJson<double>(windowWidth),
      'windowHeight': serializer.toJson<double>(windowHeight),
      'opacity': serializer.toJson<double>(opacity),
      'backgroundOpacity': serializer.toJson<double>(backgroundOpacity),
      'cardOpacity': serializer.toJson<double>(cardOpacity),
      'isAlwaysOnTop': serializer.toJson<bool>(isAlwaysOnTop),
      'isPositionLocked': serializer.toJson<bool>(isPositionLocked),
      'isSizeLocked': serializer.toJson<bool>(isSizeLocked),
      'showInTaskbar': serializer.toJson<bool>(showInTaskbar),
      'widgetMode': serializer.toJson<String>(widgetMode),
      'themePresetId': serializer.toJson<String?>(themePresetId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WidgetPreferenceRow copyWith(
          {String? id,
          Value<double?> windowX = const Value.absent(),
          Value<double?> windowY = const Value.absent(),
          double? windowWidth,
          double? windowHeight,
          double? opacity,
          double? backgroundOpacity,
          double? cardOpacity,
          bool? isAlwaysOnTop,
          bool? isPositionLocked,
          bool? isSizeLocked,
          bool? showInTaskbar,
          String? widgetMode,
          Value<String?> themePresetId = const Value.absent(),
          DateTime? updatedAt}) =>
      WidgetPreferenceRow(
        id: id ?? this.id,
        windowX: windowX.present ? windowX.value : this.windowX,
        windowY: windowY.present ? windowY.value : this.windowY,
        windowWidth: windowWidth ?? this.windowWidth,
        windowHeight: windowHeight ?? this.windowHeight,
        opacity: opacity ?? this.opacity,
        backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
        cardOpacity: cardOpacity ?? this.cardOpacity,
        isAlwaysOnTop: isAlwaysOnTop ?? this.isAlwaysOnTop,
        isPositionLocked: isPositionLocked ?? this.isPositionLocked,
        isSizeLocked: isSizeLocked ?? this.isSizeLocked,
        showInTaskbar: showInTaskbar ?? this.showInTaskbar,
        widgetMode: widgetMode ?? this.widgetMode,
        themePresetId:
            themePresetId.present ? themePresetId.value : this.themePresetId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WidgetPreferenceRow copyWithCompanion(WidgetPreferencesCompanion data) {
    return WidgetPreferenceRow(
      id: data.id.present ? data.id.value : this.id,
      windowX: data.windowX.present ? data.windowX.value : this.windowX,
      windowY: data.windowY.present ? data.windowY.value : this.windowY,
      windowWidth:
          data.windowWidth.present ? data.windowWidth.value : this.windowWidth,
      windowHeight: data.windowHeight.present
          ? data.windowHeight.value
          : this.windowHeight,
      opacity: data.opacity.present ? data.opacity.value : this.opacity,
      backgroundOpacity: data.backgroundOpacity.present
          ? data.backgroundOpacity.value
          : this.backgroundOpacity,
      cardOpacity:
          data.cardOpacity.present ? data.cardOpacity.value : this.cardOpacity,
      isAlwaysOnTop: data.isAlwaysOnTop.present
          ? data.isAlwaysOnTop.value
          : this.isAlwaysOnTop,
      isPositionLocked: data.isPositionLocked.present
          ? data.isPositionLocked.value
          : this.isPositionLocked,
      isSizeLocked: data.isSizeLocked.present
          ? data.isSizeLocked.value
          : this.isSizeLocked,
      showInTaskbar: data.showInTaskbar.present
          ? data.showInTaskbar.value
          : this.showInTaskbar,
      widgetMode:
          data.widgetMode.present ? data.widgetMode.value : this.widgetMode,
      themePresetId: data.themePresetId.present
          ? data.themePresetId.value
          : this.themePresetId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPreferenceRow(')
          ..write('id: $id, ')
          ..write('windowX: $windowX, ')
          ..write('windowY: $windowY, ')
          ..write('windowWidth: $windowWidth, ')
          ..write('windowHeight: $windowHeight, ')
          ..write('opacity: $opacity, ')
          ..write('backgroundOpacity: $backgroundOpacity, ')
          ..write('cardOpacity: $cardOpacity, ')
          ..write('isAlwaysOnTop: $isAlwaysOnTop, ')
          ..write('isPositionLocked: $isPositionLocked, ')
          ..write('isSizeLocked: $isSizeLocked, ')
          ..write('showInTaskbar: $showInTaskbar, ')
          ..write('widgetMode: $widgetMode, ')
          ..write('themePresetId: $themePresetId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      windowX,
      windowY,
      windowWidth,
      windowHeight,
      opacity,
      backgroundOpacity,
      cardOpacity,
      isAlwaysOnTop,
      isPositionLocked,
      isSizeLocked,
      showInTaskbar,
      widgetMode,
      themePresetId,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetPreferenceRow &&
          other.id == this.id &&
          other.windowX == this.windowX &&
          other.windowY == this.windowY &&
          other.windowWidth == this.windowWidth &&
          other.windowHeight == this.windowHeight &&
          other.opacity == this.opacity &&
          other.backgroundOpacity == this.backgroundOpacity &&
          other.cardOpacity == this.cardOpacity &&
          other.isAlwaysOnTop == this.isAlwaysOnTop &&
          other.isPositionLocked == this.isPositionLocked &&
          other.isSizeLocked == this.isSizeLocked &&
          other.showInTaskbar == this.showInTaskbar &&
          other.widgetMode == this.widgetMode &&
          other.themePresetId == this.themePresetId &&
          other.updatedAt == this.updatedAt);
}

class WidgetPreferencesCompanion extends UpdateCompanion<WidgetPreferenceRow> {
  final Value<String> id;
  final Value<double?> windowX;
  final Value<double?> windowY;
  final Value<double> windowWidth;
  final Value<double> windowHeight;
  final Value<double> opacity;
  final Value<double> backgroundOpacity;
  final Value<double> cardOpacity;
  final Value<bool> isAlwaysOnTop;
  final Value<bool> isPositionLocked;
  final Value<bool> isSizeLocked;
  final Value<bool> showInTaskbar;
  final Value<String> widgetMode;
  final Value<String?> themePresetId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WidgetPreferencesCompanion({
    this.id = const Value.absent(),
    this.windowX = const Value.absent(),
    this.windowY = const Value.absent(),
    this.windowWidth = const Value.absent(),
    this.windowHeight = const Value.absent(),
    this.opacity = const Value.absent(),
    this.backgroundOpacity = const Value.absent(),
    this.cardOpacity = const Value.absent(),
    this.isAlwaysOnTop = const Value.absent(),
    this.isPositionLocked = const Value.absent(),
    this.isSizeLocked = const Value.absent(),
    this.showInTaskbar = const Value.absent(),
    this.widgetMode = const Value.absent(),
    this.themePresetId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WidgetPreferencesCompanion.insert({
    required String id,
    this.windowX = const Value.absent(),
    this.windowY = const Value.absent(),
    this.windowWidth = const Value.absent(),
    this.windowHeight = const Value.absent(),
    this.opacity = const Value.absent(),
    this.backgroundOpacity = const Value.absent(),
    this.cardOpacity = const Value.absent(),
    this.isAlwaysOnTop = const Value.absent(),
    this.isPositionLocked = const Value.absent(),
    this.isSizeLocked = const Value.absent(),
    this.showInTaskbar = const Value.absent(),
    this.widgetMode = const Value.absent(),
    this.themePresetId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt);
  static Insertable<WidgetPreferenceRow> custom({
    Expression<String>? id,
    Expression<double>? windowX,
    Expression<double>? windowY,
    Expression<double>? windowWidth,
    Expression<double>? windowHeight,
    Expression<double>? opacity,
    Expression<double>? backgroundOpacity,
    Expression<double>? cardOpacity,
    Expression<bool>? isAlwaysOnTop,
    Expression<bool>? isPositionLocked,
    Expression<bool>? isSizeLocked,
    Expression<bool>? showInTaskbar,
    Expression<String>? widgetMode,
    Expression<String>? themePresetId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (windowX != null) 'window_x': windowX,
      if (windowY != null) 'window_y': windowY,
      if (windowWidth != null) 'window_width': windowWidth,
      if (windowHeight != null) 'window_height': windowHeight,
      if (opacity != null) 'opacity': opacity,
      if (backgroundOpacity != null) 'background_opacity': backgroundOpacity,
      if (cardOpacity != null) 'card_opacity': cardOpacity,
      if (isAlwaysOnTop != null) 'is_always_on_top': isAlwaysOnTop,
      if (isPositionLocked != null) 'is_position_locked': isPositionLocked,
      if (isSizeLocked != null) 'is_size_locked': isSizeLocked,
      if (showInTaskbar != null) 'show_in_taskbar': showInTaskbar,
      if (widgetMode != null) 'widget_mode': widgetMode,
      if (themePresetId != null) 'theme_preset_id': themePresetId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WidgetPreferencesCompanion copyWith(
      {Value<String>? id,
      Value<double?>? windowX,
      Value<double?>? windowY,
      Value<double>? windowWidth,
      Value<double>? windowHeight,
      Value<double>? opacity,
      Value<double>? backgroundOpacity,
      Value<double>? cardOpacity,
      Value<bool>? isAlwaysOnTop,
      Value<bool>? isPositionLocked,
      Value<bool>? isSizeLocked,
      Value<bool>? showInTaskbar,
      Value<String>? widgetMode,
      Value<String?>? themePresetId,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WidgetPreferencesCompanion(
      id: id ?? this.id,
      windowX: windowX ?? this.windowX,
      windowY: windowY ?? this.windowY,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      opacity: opacity ?? this.opacity,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      isAlwaysOnTop: isAlwaysOnTop ?? this.isAlwaysOnTop,
      isPositionLocked: isPositionLocked ?? this.isPositionLocked,
      isSizeLocked: isSizeLocked ?? this.isSizeLocked,
      showInTaskbar: showInTaskbar ?? this.showInTaskbar,
      widgetMode: widgetMode ?? this.widgetMode,
      themePresetId: themePresetId ?? this.themePresetId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (windowX.present) {
      map['window_x'] = Variable<double>(windowX.value);
    }
    if (windowY.present) {
      map['window_y'] = Variable<double>(windowY.value);
    }
    if (windowWidth.present) {
      map['window_width'] = Variable<double>(windowWidth.value);
    }
    if (windowHeight.present) {
      map['window_height'] = Variable<double>(windowHeight.value);
    }
    if (opacity.present) {
      map['opacity'] = Variable<double>(opacity.value);
    }
    if (backgroundOpacity.present) {
      map['background_opacity'] = Variable<double>(backgroundOpacity.value);
    }
    if (cardOpacity.present) {
      map['card_opacity'] = Variable<double>(cardOpacity.value);
    }
    if (isAlwaysOnTop.present) {
      map['is_always_on_top'] = Variable<bool>(isAlwaysOnTop.value);
    }
    if (isPositionLocked.present) {
      map['is_position_locked'] = Variable<bool>(isPositionLocked.value);
    }
    if (isSizeLocked.present) {
      map['is_size_locked'] = Variable<bool>(isSizeLocked.value);
    }
    if (showInTaskbar.present) {
      map['show_in_taskbar'] = Variable<bool>(showInTaskbar.value);
    }
    if (widgetMode.present) {
      map['widget_mode'] = Variable<String>(widgetMode.value);
    }
    if (themePresetId.present) {
      map['theme_preset_id'] = Variable<String>(themePresetId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('windowX: $windowX, ')
          ..write('windowY: $windowY, ')
          ..write('windowWidth: $windowWidth, ')
          ..write('windowHeight: $windowHeight, ')
          ..write('opacity: $opacity, ')
          ..write('backgroundOpacity: $backgroundOpacity, ')
          ..write('cardOpacity: $cardOpacity, ')
          ..write('isAlwaysOnTop: $isAlwaysOnTop, ')
          ..write('isPositionLocked: $isPositionLocked, ')
          ..write('isSizeLocked: $isSizeLocked, ')
          ..write('showInTaskbar: $showInTaskbar, ')
          ..write('widgetMode: $widgetMode, ')
          ..write('themePresetId: $themePresetId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThemePresetsTable extends ThemePresets
    with TableInfo<$ThemePresetsTable, ThemePresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemePresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backgroundColorMeta =
      const VerificationMeta('backgroundColor');
  @override
  late final GeneratedColumn<int> backgroundColor = GeneratedColumn<int>(
      'background_color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cardColorMeta =
      const VerificationMeta('cardColor');
  @override
  late final GeneratedColumn<int> cardColor = GeneratedColumn<int>(
      'card_color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _textColorMeta =
      const VerificationMeta('textColor');
  @override
  late final GeneratedColumn<int> textColor = GeneratedColumn<int>(
      'text_color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accentColorMeta =
      const VerificationMeta('accentColor');
  @override
  late final GeneratedColumn<int> accentColor = GeneratedColumn<int>(
      'accent_color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _borderRadiusMeta =
      const VerificationMeta('borderRadius');
  @override
  late final GeneratedColumn<double> borderRadius = GeneratedColumn<double>(
      'border_radius', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(18));
  static const VerificationMeta _shadowIntensityMeta =
      const VerificationMeta('shadowIntensity');
  @override
  late final GeneratedColumn<double> shadowIntensity = GeneratedColumn<double>(
      'shadow_intensity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  static const VerificationMeta _blurIntensityMeta =
      const VerificationMeta('blurIntensity');
  @override
  late final GeneratedColumn<double> blurIntensity = GeneratedColumn<double>(
      'blur_intensity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  static const VerificationMeta _fontFamilyMeta =
      const VerificationMeta('fontFamily');
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
      'font_family', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Nunito'));
  static const VerificationMeta _fontSizeMeta =
      const VerificationMeta('fontSize');
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
      'font_size', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(13));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        backgroundColor,
        cardColor,
        textColor,
        accentColor,
        borderRadius,
        shadowIntensity,
        blurIntensity,
        fontFamily,
        fontSize,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'theme_presets';
  @override
  VerificationContext validateIntegrity(Insertable<ThemePresetRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('background_color')) {
      context.handle(
          _backgroundColorMeta,
          backgroundColor.isAcceptableOrUnknown(
              data['background_color']!, _backgroundColorMeta));
    } else if (isInserting) {
      context.missing(_backgroundColorMeta);
    }
    if (data.containsKey('card_color')) {
      context.handle(_cardColorMeta,
          cardColor.isAcceptableOrUnknown(data['card_color']!, _cardColorMeta));
    } else if (isInserting) {
      context.missing(_cardColorMeta);
    }
    if (data.containsKey('text_color')) {
      context.handle(_textColorMeta,
          textColor.isAcceptableOrUnknown(data['text_color']!, _textColorMeta));
    } else if (isInserting) {
      context.missing(_textColorMeta);
    }
    if (data.containsKey('accent_color')) {
      context.handle(
          _accentColorMeta,
          accentColor.isAcceptableOrUnknown(
              data['accent_color']!, _accentColorMeta));
    } else if (isInserting) {
      context.missing(_accentColorMeta);
    }
    if (data.containsKey('border_radius')) {
      context.handle(
          _borderRadiusMeta,
          borderRadius.isAcceptableOrUnknown(
              data['border_radius']!, _borderRadiusMeta));
    }
    if (data.containsKey('shadow_intensity')) {
      context.handle(
          _shadowIntensityMeta,
          shadowIntensity.isAcceptableOrUnknown(
              data['shadow_intensity']!, _shadowIntensityMeta));
    }
    if (data.containsKey('blur_intensity')) {
      context.handle(
          _blurIntensityMeta,
          blurIntensity.isAcceptableOrUnknown(
              data['blur_intensity']!, _blurIntensityMeta));
    }
    if (data.containsKey('font_family')) {
      context.handle(
          _fontFamilyMeta,
          fontFamily.isAcceptableOrUnknown(
              data['font_family']!, _fontFamilyMeta));
    }
    if (data.containsKey('font_size')) {
      context.handle(_fontSizeMeta,
          fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThemePresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemePresetRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      backgroundColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}background_color'])!,
      cardColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_color'])!,
      textColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}text_color'])!,
      accentColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}accent_color'])!,
      borderRadius: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}border_radius'])!,
      shadowIntensity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}shadow_intensity'])!,
      blurIntensity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}blur_intensity'])!,
      fontFamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}font_family'])!,
      fontSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}font_size'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ThemePresetsTable createAlias(String alias) {
    return $ThemePresetsTable(attachedDatabase, alias);
  }
}

class ThemePresetRow extends DataClass implements Insertable<ThemePresetRow> {
  final String id;
  final String name;
  final int backgroundColor;
  final int cardColor;
  final int textColor;
  final int accentColor;
  final double borderRadius;
  final double shadowIntensity;
  final double blurIntensity;
  final String fontFamily;
  final double fontSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ThemePresetRow(
      {required this.id,
      required this.name,
      required this.backgroundColor,
      required this.cardColor,
      required this.textColor,
      required this.accentColor,
      required this.borderRadius,
      required this.shadowIntensity,
      required this.blurIntensity,
      required this.fontFamily,
      required this.fontSize,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['background_color'] = Variable<int>(backgroundColor);
    map['card_color'] = Variable<int>(cardColor);
    map['text_color'] = Variable<int>(textColor);
    map['accent_color'] = Variable<int>(accentColor);
    map['border_radius'] = Variable<double>(borderRadius);
    map['shadow_intensity'] = Variable<double>(shadowIntensity);
    map['blur_intensity'] = Variable<double>(blurIntensity);
    map['font_family'] = Variable<String>(fontFamily);
    map['font_size'] = Variable<double>(fontSize);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ThemePresetsCompanion toCompanion(bool nullToAbsent) {
    return ThemePresetsCompanion(
      id: Value(id),
      name: Value(name),
      backgroundColor: Value(backgroundColor),
      cardColor: Value(cardColor),
      textColor: Value(textColor),
      accentColor: Value(accentColor),
      borderRadius: Value(borderRadius),
      shadowIntensity: Value(shadowIntensity),
      blurIntensity: Value(blurIntensity),
      fontFamily: Value(fontFamily),
      fontSize: Value(fontSize),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ThemePresetRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemePresetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      backgroundColor: serializer.fromJson<int>(json['backgroundColor']),
      cardColor: serializer.fromJson<int>(json['cardColor']),
      textColor: serializer.fromJson<int>(json['textColor']),
      accentColor: serializer.fromJson<int>(json['accentColor']),
      borderRadius: serializer.fromJson<double>(json['borderRadius']),
      shadowIntensity: serializer.fromJson<double>(json['shadowIntensity']),
      blurIntensity: serializer.fromJson<double>(json['blurIntensity']),
      fontFamily: serializer.fromJson<String>(json['fontFamily']),
      fontSize: serializer.fromJson<double>(json['fontSize']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'backgroundColor': serializer.toJson<int>(backgroundColor),
      'cardColor': serializer.toJson<int>(cardColor),
      'textColor': serializer.toJson<int>(textColor),
      'accentColor': serializer.toJson<int>(accentColor),
      'borderRadius': serializer.toJson<double>(borderRadius),
      'shadowIntensity': serializer.toJson<double>(shadowIntensity),
      'blurIntensity': serializer.toJson<double>(blurIntensity),
      'fontFamily': serializer.toJson<String>(fontFamily),
      'fontSize': serializer.toJson<double>(fontSize),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ThemePresetRow copyWith(
          {String? id,
          String? name,
          int? backgroundColor,
          int? cardColor,
          int? textColor,
          int? accentColor,
          double? borderRadius,
          double? shadowIntensity,
          double? blurIntensity,
          String? fontFamily,
          double? fontSize,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ThemePresetRow(
        id: id ?? this.id,
        name: name ?? this.name,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        cardColor: cardColor ?? this.cardColor,
        textColor: textColor ?? this.textColor,
        accentColor: accentColor ?? this.accentColor,
        borderRadius: borderRadius ?? this.borderRadius,
        shadowIntensity: shadowIntensity ?? this.shadowIntensity,
        blurIntensity: blurIntensity ?? this.blurIntensity,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ThemePresetRow copyWithCompanion(ThemePresetsCompanion data) {
    return ThemePresetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      backgroundColor: data.backgroundColor.present
          ? data.backgroundColor.value
          : this.backgroundColor,
      cardColor: data.cardColor.present ? data.cardColor.value : this.cardColor,
      textColor: data.textColor.present ? data.textColor.value : this.textColor,
      accentColor:
          data.accentColor.present ? data.accentColor.value : this.accentColor,
      borderRadius: data.borderRadius.present
          ? data.borderRadius.value
          : this.borderRadius,
      shadowIntensity: data.shadowIntensity.present
          ? data.shadowIntensity.value
          : this.shadowIntensity,
      blurIntensity: data.blurIntensity.present
          ? data.blurIntensity.value
          : this.blurIntensity,
      fontFamily:
          data.fontFamily.present ? data.fontFamily.value : this.fontFamily,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemePresetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('cardColor: $cardColor, ')
          ..write('textColor: $textColor, ')
          ..write('accentColor: $accentColor, ')
          ..write('borderRadius: $borderRadius, ')
          ..write('shadowIntensity: $shadowIntensity, ')
          ..write('blurIntensity: $blurIntensity, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('fontSize: $fontSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      backgroundColor,
      cardColor,
      textColor,
      accentColor,
      borderRadius,
      shadowIntensity,
      blurIntensity,
      fontFamily,
      fontSize,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemePresetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.backgroundColor == this.backgroundColor &&
          other.cardColor == this.cardColor &&
          other.textColor == this.textColor &&
          other.accentColor == this.accentColor &&
          other.borderRadius == this.borderRadius &&
          other.shadowIntensity == this.shadowIntensity &&
          other.blurIntensity == this.blurIntensity &&
          other.fontFamily == this.fontFamily &&
          other.fontSize == this.fontSize &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ThemePresetsCompanion extends UpdateCompanion<ThemePresetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> backgroundColor;
  final Value<int> cardColor;
  final Value<int> textColor;
  final Value<int> accentColor;
  final Value<double> borderRadius;
  final Value<double> shadowIntensity;
  final Value<double> blurIntensity;
  final Value<String> fontFamily;
  final Value<double> fontSize;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ThemePresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.cardColor = const Value.absent(),
    this.textColor = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.borderRadius = const Value.absent(),
    this.shadowIntensity = const Value.absent(),
    this.blurIntensity = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThemePresetsCompanion.insert({
    required String id,
    required String name,
    required int backgroundColor,
    required int cardColor,
    required int textColor,
    required int accentColor,
    this.borderRadius = const Value.absent(),
    this.shadowIntensity = const Value.absent(),
    this.blurIntensity = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.fontSize = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        backgroundColor = Value(backgroundColor),
        cardColor = Value(cardColor),
        textColor = Value(textColor),
        accentColor = Value(accentColor),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ThemePresetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? backgroundColor,
    Expression<int>? cardColor,
    Expression<int>? textColor,
    Expression<int>? accentColor,
    Expression<double>? borderRadius,
    Expression<double>? shadowIntensity,
    Expression<double>? blurIntensity,
    Expression<String>? fontFamily,
    Expression<double>? fontSize,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (backgroundColor != null) 'background_color': backgroundColor,
      if (cardColor != null) 'card_color': cardColor,
      if (textColor != null) 'text_color': textColor,
      if (accentColor != null) 'accent_color': accentColor,
      if (borderRadius != null) 'border_radius': borderRadius,
      if (shadowIntensity != null) 'shadow_intensity': shadowIntensity,
      if (blurIntensity != null) 'blur_intensity': blurIntensity,
      if (fontFamily != null) 'font_family': fontFamily,
      if (fontSize != null) 'font_size': fontSize,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThemePresetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? backgroundColor,
      Value<int>? cardColor,
      Value<int>? textColor,
      Value<int>? accentColor,
      Value<double>? borderRadius,
      Value<double>? shadowIntensity,
      Value<double>? blurIntensity,
      Value<String>? fontFamily,
      Value<double>? fontSize,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ThemePresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowIntensity: shadowIntensity ?? this.shadowIntensity,
      blurIntensity: blurIntensity ?? this.blurIntensity,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (backgroundColor.present) {
      map['background_color'] = Variable<int>(backgroundColor.value);
    }
    if (cardColor.present) {
      map['card_color'] = Variable<int>(cardColor.value);
    }
    if (textColor.present) {
      map['text_color'] = Variable<int>(textColor.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<int>(accentColor.value);
    }
    if (borderRadius.present) {
      map['border_radius'] = Variable<double>(borderRadius.value);
    }
    if (shadowIntensity.present) {
      map['shadow_intensity'] = Variable<double>(shadowIntensity.value);
    }
    if (blurIntensity.present) {
      map['blur_intensity'] = Variable<double>(blurIntensity.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemePresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('cardColor: $cardColor, ')
          ..write('textColor: $textColor, ')
          ..write('accentColor: $accentColor, ')
          ..write('borderRadius: $borderRadius, ')
          ..write('shadowIntensity: $shadowIntensity, ')
          ..write('blurIntensity: $blurIntensity, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('fontSize: $fontSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDayOfWeekMeta =
      const VerificationMeta('startDayOfWeek');
  @override
  late final GeneratedColumn<int> startDayOfWeek = GeneratedColumn<int>(
      'start_day_of_week', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _showKoreanHolidaysMeta =
      const VerificationMeta('showKoreanHolidays');
  @override
  late final GeneratedColumn<bool> showKoreanHolidays = GeneratedColumn<bool>(
      'show_korean_holidays', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_korean_holidays" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showCanadaHolidaysMeta =
      const VerificationMeta('showCanadaHolidays');
  @override
  late final GeneratedColumn<bool> showCanadaHolidays = GeneratedColumn<bool>(
      'show_canada_holidays', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_canada_holidays" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showLunarCalendarMeta =
      const VerificationMeta('showLunarCalendar');
  @override
  late final GeneratedColumn<bool> showLunarCalendar = GeneratedColumn<bool>(
      'show_lunar_calendar', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_lunar_calendar" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showSolarTermsMeta =
      const VerificationMeta('showSolarTerms');
  @override
  late final GeneratedColumn<bool> showSolarTerms = GeneratedColumn<bool>(
      'show_solar_terms', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_solar_terms" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showCompletedTasksOnCalendarMeta =
      const VerificationMeta('showCompletedTasksOnCalendar');
  @override
  late final GeneratedColumn<bool> showCompletedTasksOnCalendar =
      GeneratedColumn<bool>(
          'show_completed_tasks_on_calendar', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("show_completed_tasks_on_calendar" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _showOverdueTasksOnCalendarMeta =
      const VerificationMeta('showOverdueTasksOnCalendar');
  @override
  late final GeneratedColumn<bool> showOverdueTasksOnCalendar =
      GeneratedColumn<bool>(
          'show_overdue_tasks_on_calendar', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("show_overdue_tasks_on_calendar" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _monthItemTextScaleMeta =
      const VerificationMeta('monthItemTextScale');
  @override
  late final GeneratedColumn<double> monthItemTextScale =
      GeneratedColumn<double>('month_item_text_scale', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(1.3));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startDayOfWeek,
        showKoreanHolidays,
        showCanadaHolidays,
        showLunarCalendar,
        showSolarTerms,
        showCompletedTasksOnCalendar,
        showOverdueTasksOnCalendar,
        monthItemTextScale,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_day_of_week')) {
      context.handle(
          _startDayOfWeekMeta,
          startDayOfWeek.isAcceptableOrUnknown(
              data['start_day_of_week']!, _startDayOfWeekMeta));
    }
    if (data.containsKey('show_korean_holidays')) {
      context.handle(
          _showKoreanHolidaysMeta,
          showKoreanHolidays.isAcceptableOrUnknown(
              data['show_korean_holidays']!, _showKoreanHolidaysMeta));
    }
    if (data.containsKey('show_canada_holidays')) {
      context.handle(
          _showCanadaHolidaysMeta,
          showCanadaHolidays.isAcceptableOrUnknown(
              data['show_canada_holidays']!, _showCanadaHolidaysMeta));
    }
    if (data.containsKey('show_lunar_calendar')) {
      context.handle(
          _showLunarCalendarMeta,
          showLunarCalendar.isAcceptableOrUnknown(
              data['show_lunar_calendar']!, _showLunarCalendarMeta));
    }
    if (data.containsKey('show_solar_terms')) {
      context.handle(
          _showSolarTermsMeta,
          showSolarTerms.isAcceptableOrUnknown(
              data['show_solar_terms']!, _showSolarTermsMeta));
    }
    if (data.containsKey('show_completed_tasks_on_calendar')) {
      context.handle(
          _showCompletedTasksOnCalendarMeta,
          showCompletedTasksOnCalendar.isAcceptableOrUnknown(
              data['show_completed_tasks_on_calendar']!,
              _showCompletedTasksOnCalendarMeta));
    }
    if (data.containsKey('show_overdue_tasks_on_calendar')) {
      context.handle(
          _showOverdueTasksOnCalendarMeta,
          showOverdueTasksOnCalendar.isAcceptableOrUnknown(
              data['show_overdue_tasks_on_calendar']!,
              _showOverdueTasksOnCalendarMeta));
    }
    if (data.containsKey('month_item_text_scale')) {
      context.handle(
          _monthItemTextScaleMeta,
          monthItemTextScale.isAcceptableOrUnknown(
              data['month_item_text_scale']!, _monthItemTextScaleMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startDayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_day_of_week'])!,
      showKoreanHolidays: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}show_korean_holidays'])!,
      showCanadaHolidays: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}show_canada_holidays'])!,
      showLunarCalendar: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}show_lunar_calendar'])!,
      showSolarTerms: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_solar_terms'])!,
      showCompletedTasksOnCalendar: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}show_completed_tasks_on_calendar'])!,
      showOverdueTasksOnCalendar: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}show_overdue_tasks_on_calendar'])!,
      monthItemTextScale: attachedDatabase.typeMapping.read(DriftSqlType.double,
          data['${effectivePrefix}month_item_text_scale'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final String id;
  final int startDayOfWeek;
  final bool showKoreanHolidays;
  final bool showCanadaHolidays;
  final bool showLunarCalendar;
  final bool showSolarTerms;
  final bool showCompletedTasksOnCalendar;
  final bool showOverdueTasksOnCalendar;

  /// Multiplier applied to month-view chip/holiday text (see
  /// CalendarDayCell/_MultiDayBarChip) — the fixed 9px chip text read as too
  /// small to some users. 1.0 = original size; default is already bumped up
  /// from that since the un-scaled size was the actual complaint.
  final double monthItemTextScale;
  final DateTime updatedAt;
  const AppSettingsRow(
      {required this.id,
      required this.startDayOfWeek,
      required this.showKoreanHolidays,
      required this.showCanadaHolidays,
      required this.showLunarCalendar,
      required this.showSolarTerms,
      required this.showCompletedTasksOnCalendar,
      required this.showOverdueTasksOnCalendar,
      required this.monthItemTextScale,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_day_of_week'] = Variable<int>(startDayOfWeek);
    map['show_korean_holidays'] = Variable<bool>(showKoreanHolidays);
    map['show_canada_holidays'] = Variable<bool>(showCanadaHolidays);
    map['show_lunar_calendar'] = Variable<bool>(showLunarCalendar);
    map['show_solar_terms'] = Variable<bool>(showSolarTerms);
    map['show_completed_tasks_on_calendar'] =
        Variable<bool>(showCompletedTasksOnCalendar);
    map['show_overdue_tasks_on_calendar'] =
        Variable<bool>(showOverdueTasksOnCalendar);
    map['month_item_text_scale'] = Variable<double>(monthItemTextScale);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      startDayOfWeek: Value(startDayOfWeek),
      showKoreanHolidays: Value(showKoreanHolidays),
      showCanadaHolidays: Value(showCanadaHolidays),
      showLunarCalendar: Value(showLunarCalendar),
      showSolarTerms: Value(showSolarTerms),
      showCompletedTasksOnCalendar: Value(showCompletedTasksOnCalendar),
      showOverdueTasksOnCalendar: Value(showOverdueTasksOnCalendar),
      monthItemTextScale: Value(monthItemTextScale),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      startDayOfWeek: serializer.fromJson<int>(json['startDayOfWeek']),
      showKoreanHolidays: serializer.fromJson<bool>(json['showKoreanHolidays']),
      showCanadaHolidays: serializer.fromJson<bool>(json['showCanadaHolidays']),
      showLunarCalendar: serializer.fromJson<bool>(json['showLunarCalendar']),
      showSolarTerms: serializer.fromJson<bool>(json['showSolarTerms']),
      showCompletedTasksOnCalendar:
          serializer.fromJson<bool>(json['showCompletedTasksOnCalendar']),
      showOverdueTasksOnCalendar:
          serializer.fromJson<bool>(json['showOverdueTasksOnCalendar']),
      monthItemTextScale:
          serializer.fromJson<double>(json['monthItemTextScale']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startDayOfWeek': serializer.toJson<int>(startDayOfWeek),
      'showKoreanHolidays': serializer.toJson<bool>(showKoreanHolidays),
      'showCanadaHolidays': serializer.toJson<bool>(showCanadaHolidays),
      'showLunarCalendar': serializer.toJson<bool>(showLunarCalendar),
      'showSolarTerms': serializer.toJson<bool>(showSolarTerms),
      'showCompletedTasksOnCalendar':
          serializer.toJson<bool>(showCompletedTasksOnCalendar),
      'showOverdueTasksOnCalendar':
          serializer.toJson<bool>(showOverdueTasksOnCalendar),
      'monthItemTextScale': serializer.toJson<double>(monthItemTextScale),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsRow copyWith(
          {String? id,
          int? startDayOfWeek,
          bool? showKoreanHolidays,
          bool? showCanadaHolidays,
          bool? showLunarCalendar,
          bool? showSolarTerms,
          bool? showCompletedTasksOnCalendar,
          bool? showOverdueTasksOnCalendar,
          double? monthItemTextScale,
          DateTime? updatedAt}) =>
      AppSettingsRow(
        id: id ?? this.id,
        startDayOfWeek: startDayOfWeek ?? this.startDayOfWeek,
        showKoreanHolidays: showKoreanHolidays ?? this.showKoreanHolidays,
        showCanadaHolidays: showCanadaHolidays ?? this.showCanadaHolidays,
        showLunarCalendar: showLunarCalendar ?? this.showLunarCalendar,
        showSolarTerms: showSolarTerms ?? this.showSolarTerms,
        showCompletedTasksOnCalendar:
            showCompletedTasksOnCalendar ?? this.showCompletedTasksOnCalendar,
        showOverdueTasksOnCalendar:
            showOverdueTasksOnCalendar ?? this.showOverdueTasksOnCalendar,
        monthItemTextScale: monthItemTextScale ?? this.monthItemTextScale,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingsRow copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      startDayOfWeek: data.startDayOfWeek.present
          ? data.startDayOfWeek.value
          : this.startDayOfWeek,
      showKoreanHolidays: data.showKoreanHolidays.present
          ? data.showKoreanHolidays.value
          : this.showKoreanHolidays,
      showCanadaHolidays: data.showCanadaHolidays.present
          ? data.showCanadaHolidays.value
          : this.showCanadaHolidays,
      showLunarCalendar: data.showLunarCalendar.present
          ? data.showLunarCalendar.value
          : this.showLunarCalendar,
      showSolarTerms: data.showSolarTerms.present
          ? data.showSolarTerms.value
          : this.showSolarTerms,
      showCompletedTasksOnCalendar: data.showCompletedTasksOnCalendar.present
          ? data.showCompletedTasksOnCalendar.value
          : this.showCompletedTasksOnCalendar,
      showOverdueTasksOnCalendar: data.showOverdueTasksOnCalendar.present
          ? data.showOverdueTasksOnCalendar.value
          : this.showOverdueTasksOnCalendar,
      monthItemTextScale: data.monthItemTextScale.present
          ? data.monthItemTextScale.value
          : this.monthItemTextScale,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('startDayOfWeek: $startDayOfWeek, ')
          ..write('showKoreanHolidays: $showKoreanHolidays, ')
          ..write('showCanadaHolidays: $showCanadaHolidays, ')
          ..write('showLunarCalendar: $showLunarCalendar, ')
          ..write('showSolarTerms: $showSolarTerms, ')
          ..write(
              'showCompletedTasksOnCalendar: $showCompletedTasksOnCalendar, ')
          ..write('showOverdueTasksOnCalendar: $showOverdueTasksOnCalendar, ')
          ..write('monthItemTextScale: $monthItemTextScale, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      startDayOfWeek,
      showKoreanHolidays,
      showCanadaHolidays,
      showLunarCalendar,
      showSolarTerms,
      showCompletedTasksOnCalendar,
      showOverdueTasksOnCalendar,
      monthItemTextScale,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.startDayOfWeek == this.startDayOfWeek &&
          other.showKoreanHolidays == this.showKoreanHolidays &&
          other.showCanadaHolidays == this.showCanadaHolidays &&
          other.showLunarCalendar == this.showLunarCalendar &&
          other.showSolarTerms == this.showSolarTerms &&
          other.showCompletedTasksOnCalendar ==
              this.showCompletedTasksOnCalendar &&
          other.showOverdueTasksOnCalendar == this.showOverdueTasksOnCalendar &&
          other.monthItemTextScale == this.monthItemTextScale &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<String> id;
  final Value<int> startDayOfWeek;
  final Value<bool> showKoreanHolidays;
  final Value<bool> showCanadaHolidays;
  final Value<bool> showLunarCalendar;
  final Value<bool> showSolarTerms;
  final Value<bool> showCompletedTasksOnCalendar;
  final Value<bool> showOverdueTasksOnCalendar;
  final Value<double> monthItemTextScale;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.startDayOfWeek = const Value.absent(),
    this.showKoreanHolidays = const Value.absent(),
    this.showCanadaHolidays = const Value.absent(),
    this.showLunarCalendar = const Value.absent(),
    this.showSolarTerms = const Value.absent(),
    this.showCompletedTasksOnCalendar = const Value.absent(),
    this.showOverdueTasksOnCalendar = const Value.absent(),
    this.monthItemTextScale = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String id,
    this.startDayOfWeek = const Value.absent(),
    this.showKoreanHolidays = const Value.absent(),
    this.showCanadaHolidays = const Value.absent(),
    this.showLunarCalendar = const Value.absent(),
    this.showSolarTerms = const Value.absent(),
    this.showCompletedTasksOnCalendar = const Value.absent(),
    this.showOverdueTasksOnCalendar = const Value.absent(),
    this.monthItemTextScale = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<String>? id,
    Expression<int>? startDayOfWeek,
    Expression<bool>? showKoreanHolidays,
    Expression<bool>? showCanadaHolidays,
    Expression<bool>? showLunarCalendar,
    Expression<bool>? showSolarTerms,
    Expression<bool>? showCompletedTasksOnCalendar,
    Expression<bool>? showOverdueTasksOnCalendar,
    Expression<double>? monthItemTextScale,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDayOfWeek != null) 'start_day_of_week': startDayOfWeek,
      if (showKoreanHolidays != null)
        'show_korean_holidays': showKoreanHolidays,
      if (showCanadaHolidays != null)
        'show_canada_holidays': showCanadaHolidays,
      if (showLunarCalendar != null) 'show_lunar_calendar': showLunarCalendar,
      if (showSolarTerms != null) 'show_solar_terms': showSolarTerms,
      if (showCompletedTasksOnCalendar != null)
        'show_completed_tasks_on_calendar': showCompletedTasksOnCalendar,
      if (showOverdueTasksOnCalendar != null)
        'show_overdue_tasks_on_calendar': showOverdueTasksOnCalendar,
      if (monthItemTextScale != null)
        'month_item_text_scale': monthItemTextScale,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith(
      {Value<String>? id,
      Value<int>? startDayOfWeek,
      Value<bool>? showKoreanHolidays,
      Value<bool>? showCanadaHolidays,
      Value<bool>? showLunarCalendar,
      Value<bool>? showSolarTerms,
      Value<bool>? showCompletedTasksOnCalendar,
      Value<bool>? showOverdueTasksOnCalendar,
      Value<double>? monthItemTextScale,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      startDayOfWeek: startDayOfWeek ?? this.startDayOfWeek,
      showKoreanHolidays: showKoreanHolidays ?? this.showKoreanHolidays,
      showCanadaHolidays: showCanadaHolidays ?? this.showCanadaHolidays,
      showLunarCalendar: showLunarCalendar ?? this.showLunarCalendar,
      showSolarTerms: showSolarTerms ?? this.showSolarTerms,
      showCompletedTasksOnCalendar:
          showCompletedTasksOnCalendar ?? this.showCompletedTasksOnCalendar,
      showOverdueTasksOnCalendar:
          showOverdueTasksOnCalendar ?? this.showOverdueTasksOnCalendar,
      monthItemTextScale: monthItemTextScale ?? this.monthItemTextScale,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startDayOfWeek.present) {
      map['start_day_of_week'] = Variable<int>(startDayOfWeek.value);
    }
    if (showKoreanHolidays.present) {
      map['show_korean_holidays'] = Variable<bool>(showKoreanHolidays.value);
    }
    if (showCanadaHolidays.present) {
      map['show_canada_holidays'] = Variable<bool>(showCanadaHolidays.value);
    }
    if (showLunarCalendar.present) {
      map['show_lunar_calendar'] = Variable<bool>(showLunarCalendar.value);
    }
    if (showSolarTerms.present) {
      map['show_solar_terms'] = Variable<bool>(showSolarTerms.value);
    }
    if (showCompletedTasksOnCalendar.present) {
      map['show_completed_tasks_on_calendar'] =
          Variable<bool>(showCompletedTasksOnCalendar.value);
    }
    if (showOverdueTasksOnCalendar.present) {
      map['show_overdue_tasks_on_calendar'] =
          Variable<bool>(showOverdueTasksOnCalendar.value);
    }
    if (monthItemTextScale.present) {
      map['month_item_text_scale'] = Variable<double>(monthItemTextScale.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('startDayOfWeek: $startDayOfWeek, ')
          ..write('showKoreanHolidays: $showKoreanHolidays, ')
          ..write('showCanadaHolidays: $showCanadaHolidays, ')
          ..write('showLunarCalendar: $showLunarCalendar, ')
          ..write('showSolarTerms: $showSolarTerms, ')
          ..write(
              'showCompletedTasksOnCalendar: $showCompletedTasksOnCalendar, ')
          ..write('showOverdueTasksOnCalendar: $showOverdueTasksOnCalendar, ')
          ..write('monthItemTextScale: $monthItemTextScale, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $WidgetPreferencesTable widgetPreferences =
      $WidgetPreferencesTable(this);
  late final $ThemePresetsTable themePresets = $ThemePresetsTable(this);
  late final $AppSettingsTableTable appSettingsTable =
      $AppSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        tasks,
        calendarEvents,
        categories,
        tags,
        widgetPreferences,
        themePresets,
        appSettingsTable
      ];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  Value<bool> isCompleted,
  Value<DateTime?> dueDate,
  Value<int?> dueTimeMinutes,
  Value<String> priority,
  Value<String?> categoryId,
  Value<String> tagIdsJson,
  Value<int> sortOrder,
  Value<int?> reminderMinutesBefore,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<bool> isCompleted,
  Value<DateTime?> dueDate,
  Value<int?> dueTimeMinutes,
  Value<String> priority,
  Value<String?> categoryId,
  Value<String> tagIdsJson,
  Value<int> sortOrder,
  Value<int?> reminderMinutesBefore,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueTimeMinutes => $composableBuilder(
      column: $table.dueTimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagIdsJson => $composableBuilder(
      column: $table.tagIdsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueTimeMinutes => $composableBuilder(
      column: $table.dueTimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagIdsJson => $composableBuilder(
      column: $table.tagIdsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get dueTimeMinutes => $composableBuilder(
      column: $table.dueTimeMinutes, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get tagIdsJson => $composableBuilder(
      column: $table.tagIdsJson, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskRow,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
    TaskRow,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<int?> dueTimeMinutes = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> tagIdsJson = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int?> reminderMinutesBefore = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            description: description,
            isCompleted: isCompleted,
            dueDate: dueDate,
            dueTimeMinutes: dueTimeMinutes,
            priority: priority,
            categoryId: categoryId,
            tagIdsJson: tagIdsJson,
            sortOrder: sortOrder,
            reminderMinutesBefore: reminderMinutesBefore,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<int?> dueTimeMinutes = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> tagIdsJson = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int?> reminderMinutesBefore = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            isCompleted: isCompleted,
            dueDate: dueDate,
            dueTimeMinutes: dueTimeMinutes,
            priority: priority,
            categoryId: categoryId,
            tagIdsJson: tagIdsJson,
            sortOrder: sortOrder,
            reminderMinutesBefore: reminderMinutesBefore,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskRow,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
    TaskRow,
    PrefetchHooks Function()>;
typedef $$CalendarEventsTableCreateCompanionBuilder = CalendarEventsCompanion
    Function({
  required String id,
  required String title,
  Value<String?> description,
  required DateTime startDateTime,
  required DateTime endDateTime,
  Value<bool> isAllDay,
  Value<String?> categoryId,
  Value<int?> color,
  Value<String?> location,
  Value<bool> isRecurring,
  Value<String?> recurrenceRule,
  Value<DateTime?> recurrenceEndDate,
  Value<int?> recurrenceCount,
  Value<String?> parentEventId,
  Value<DateTime?> originalOccurrenceDate,
  Value<String> recurrenceExceptionDatesJson,
  Value<int?> reminderMinutesBefore,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CalendarEventsTableUpdateCompanionBuilder = CalendarEventsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> startDateTime,
  Value<DateTime> endDateTime,
  Value<bool> isAllDay,
  Value<String?> categoryId,
  Value<int?> color,
  Value<String?> location,
  Value<bool> isRecurring,
  Value<String?> recurrenceRule,
  Value<DateTime?> recurrenceEndDate,
  Value<int?> recurrenceCount,
  Value<String?> parentEventId,
  Value<DateTime?> originalOccurrenceDate,
  Value<String> recurrenceExceptionDatesJson,
  Value<int?> reminderMinutesBefore,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CalendarEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDateTime => $composableBuilder(
      column: $table.startDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDateTime => $composableBuilder(
      column: $table.endDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceCount => $composableBuilder(
      column: $table.recurrenceCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentEventId => $composableBuilder(
      column: $table.parentEventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get originalOccurrenceDate => $composableBuilder(
      column: $table.originalOccurrenceDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceExceptionDatesJson => $composableBuilder(
      column: $table.recurrenceExceptionDatesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDateTime => $composableBuilder(
      column: $table.startDateTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDateTime => $composableBuilder(
      column: $table.endDateTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceCount => $composableBuilder(
      column: $table.recurrenceCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentEventId => $composableBuilder(
      column: $table.parentEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get originalOccurrenceDate => $composableBuilder(
      column: $table.originalOccurrenceDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceExceptionDatesJson =>
      $composableBuilder(
          column: $table.recurrenceExceptionDatesJson,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get startDateTime => $composableBuilder(
      column: $table.startDateTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endDateTime => $composableBuilder(
      column: $table.endDateTime, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule, builder: (column) => column);

  GeneratedColumn<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate, builder: (column) => column);

  GeneratedColumn<int> get recurrenceCount => $composableBuilder(
      column: $table.recurrenceCount, builder: (column) => column);

  GeneratedColumn<String> get parentEventId => $composableBuilder(
      column: $table.parentEventId, builder: (column) => column);

  GeneratedColumn<DateTime> get originalOccurrenceDate => $composableBuilder(
      column: $table.originalOccurrenceDate, builder: (column) => column);

  GeneratedColumn<String> get recurrenceExceptionDatesJson =>
      $composableBuilder(
          column: $table.recurrenceExceptionDatesJson,
          builder: (column) => column);

  GeneratedColumn<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CalendarEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CalendarEventsTable,
    CalendarEventRow,
    $$CalendarEventsTableFilterComposer,
    $$CalendarEventsTableOrderingComposer,
    $$CalendarEventsTableAnnotationComposer,
    $$CalendarEventsTableCreateCompanionBuilder,
    $$CalendarEventsTableUpdateCompanionBuilder,
    (
      CalendarEventRow,
      BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEventRow>
    ),
    CalendarEventRow,
    PrefetchHooks Function()> {
  $$CalendarEventsTableTableManager(
      _$AppDatabase db, $CalendarEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> startDateTime = const Value.absent(),
            Value<DateTime> endDateTime = const Value.absent(),
            Value<bool> isAllDay = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int?> color = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<DateTime?> recurrenceEndDate = const Value.absent(),
            Value<int?> recurrenceCount = const Value.absent(),
            Value<String?> parentEventId = const Value.absent(),
            Value<DateTime?> originalOccurrenceDate = const Value.absent(),
            Value<String> recurrenceExceptionDatesJson = const Value.absent(),
            Value<int?> reminderMinutesBefore = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarEventsCompanion(
            id: id,
            title: title,
            description: description,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            isAllDay: isAllDay,
            categoryId: categoryId,
            color: color,
            location: location,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            recurrenceEndDate: recurrenceEndDate,
            recurrenceCount: recurrenceCount,
            parentEventId: parentEventId,
            originalOccurrenceDate: originalOccurrenceDate,
            recurrenceExceptionDatesJson: recurrenceExceptionDatesJson,
            reminderMinutesBefore: reminderMinutesBefore,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime startDateTime,
            required DateTime endDateTime,
            Value<bool> isAllDay = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int?> color = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<DateTime?> recurrenceEndDate = const Value.absent(),
            Value<int?> recurrenceCount = const Value.absent(),
            Value<String?> parentEventId = const Value.absent(),
            Value<DateTime?> originalOccurrenceDate = const Value.absent(),
            Value<String> recurrenceExceptionDatesJson = const Value.absent(),
            Value<int?> reminderMinutesBefore = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarEventsCompanion.insert(
            id: id,
            title: title,
            description: description,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            isAllDay: isAllDay,
            categoryId: categoryId,
            color: color,
            location: location,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            recurrenceEndDate: recurrenceEndDate,
            recurrenceCount: recurrenceCount,
            parentEventId: parentEventId,
            originalOccurrenceDate: originalOccurrenceDate,
            recurrenceExceptionDatesJson: recurrenceExceptionDatesJson,
            reminderMinutesBefore: reminderMinutesBefore,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CalendarEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CalendarEventsTable,
    CalendarEventRow,
    $$CalendarEventsTableFilterComposer,
    $$CalendarEventsTableOrderingComposer,
    $$CalendarEventsTableAnnotationComposer,
    $$CalendarEventsTableCreateCompanionBuilder,
    $$CalendarEventsTableUpdateCompanionBuilder,
    (
      CalendarEventRow,
      BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEventRow>
    ),
    CalendarEventRow,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required int color,
  Value<String?> icon,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> color,
  Value<String?> icon,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            color: color,
            icon: icon,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int color,
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            color: color,
            icon: icon,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    TagRow,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagRow, BaseReferences<_$AppDatabase, $TagsTable, TagRow>),
    TagRow,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    TagRow,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagRow, BaseReferences<_$AppDatabase, $TagsTable, TagRow>),
    TagRow,
    PrefetchHooks Function()>;
typedef $$WidgetPreferencesTableCreateCompanionBuilder
    = WidgetPreferencesCompanion Function({
  required String id,
  Value<double?> windowX,
  Value<double?> windowY,
  Value<double> windowWidth,
  Value<double> windowHeight,
  Value<double> opacity,
  Value<double> backgroundOpacity,
  Value<double> cardOpacity,
  Value<bool> isAlwaysOnTop,
  Value<bool> isPositionLocked,
  Value<bool> isSizeLocked,
  Value<bool> showInTaskbar,
  Value<String> widgetMode,
  Value<String?> themePresetId,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$WidgetPreferencesTableUpdateCompanionBuilder
    = WidgetPreferencesCompanion Function({
  Value<String> id,
  Value<double?> windowX,
  Value<double?> windowY,
  Value<double> windowWidth,
  Value<double> windowHeight,
  Value<double> opacity,
  Value<double> backgroundOpacity,
  Value<double> cardOpacity,
  Value<bool> isAlwaysOnTop,
  Value<bool> isPositionLocked,
  Value<bool> isSizeLocked,
  Value<bool> showInTaskbar,
  Value<String> widgetMode,
  Value<String?> themePresetId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$WidgetPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetPreferencesTable> {
  $$WidgetPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get windowX => $composableBuilder(
      column: $table.windowX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get windowY => $composableBuilder(
      column: $table.windowY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get windowWidth => $composableBuilder(
      column: $table.windowWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get windowHeight => $composableBuilder(
      column: $table.windowHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get opacity => $composableBuilder(
      column: $table.opacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get backgroundOpacity => $composableBuilder(
      column: $table.backgroundOpacity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cardOpacity => $composableBuilder(
      column: $table.cardOpacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAlwaysOnTop => $composableBuilder(
      column: $table.isAlwaysOnTop, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPositionLocked => $composableBuilder(
      column: $table.isPositionLocked,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSizeLocked => $composableBuilder(
      column: $table.isSizeLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showInTaskbar => $composableBuilder(
      column: $table.showInTaskbar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get widgetMode => $composableBuilder(
      column: $table.widgetMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themePresetId => $composableBuilder(
      column: $table.themePresetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$WidgetPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetPreferencesTable> {
  $$WidgetPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get windowX => $composableBuilder(
      column: $table.windowX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get windowY => $composableBuilder(
      column: $table.windowY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get windowWidth => $composableBuilder(
      column: $table.windowWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get windowHeight => $composableBuilder(
      column: $table.windowHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get opacity => $composableBuilder(
      column: $table.opacity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get backgroundOpacity => $composableBuilder(
      column: $table.backgroundOpacity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cardOpacity => $composableBuilder(
      column: $table.cardOpacity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAlwaysOnTop => $composableBuilder(
      column: $table.isAlwaysOnTop,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPositionLocked => $composableBuilder(
      column: $table.isPositionLocked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSizeLocked => $composableBuilder(
      column: $table.isSizeLocked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showInTaskbar => $composableBuilder(
      column: $table.showInTaskbar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get widgetMode => $composableBuilder(
      column: $table.widgetMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themePresetId => $composableBuilder(
      column: $table.themePresetId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WidgetPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetPreferencesTable> {
  $$WidgetPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get windowX =>
      $composableBuilder(column: $table.windowX, builder: (column) => column);

  GeneratedColumn<double> get windowY =>
      $composableBuilder(column: $table.windowY, builder: (column) => column);

  GeneratedColumn<double> get windowWidth => $composableBuilder(
      column: $table.windowWidth, builder: (column) => column);

  GeneratedColumn<double> get windowHeight => $composableBuilder(
      column: $table.windowHeight, builder: (column) => column);

  GeneratedColumn<double> get opacity =>
      $composableBuilder(column: $table.opacity, builder: (column) => column);

  GeneratedColumn<double> get backgroundOpacity => $composableBuilder(
      column: $table.backgroundOpacity, builder: (column) => column);

  GeneratedColumn<double> get cardOpacity => $composableBuilder(
      column: $table.cardOpacity, builder: (column) => column);

  GeneratedColumn<bool> get isAlwaysOnTop => $composableBuilder(
      column: $table.isAlwaysOnTop, builder: (column) => column);

  GeneratedColumn<bool> get isPositionLocked => $composableBuilder(
      column: $table.isPositionLocked, builder: (column) => column);

  GeneratedColumn<bool> get isSizeLocked => $composableBuilder(
      column: $table.isSizeLocked, builder: (column) => column);

  GeneratedColumn<bool> get showInTaskbar => $composableBuilder(
      column: $table.showInTaskbar, builder: (column) => column);

  GeneratedColumn<String> get widgetMode => $composableBuilder(
      column: $table.widgetMode, builder: (column) => column);

  GeneratedColumn<String> get themePresetId => $composableBuilder(
      column: $table.themePresetId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WidgetPreferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WidgetPreferencesTable,
    WidgetPreferenceRow,
    $$WidgetPreferencesTableFilterComposer,
    $$WidgetPreferencesTableOrderingComposer,
    $$WidgetPreferencesTableAnnotationComposer,
    $$WidgetPreferencesTableCreateCompanionBuilder,
    $$WidgetPreferencesTableUpdateCompanionBuilder,
    (
      WidgetPreferenceRow,
      BaseReferences<_$AppDatabase, $WidgetPreferencesTable,
          WidgetPreferenceRow>
    ),
    WidgetPreferenceRow,
    PrefetchHooks Function()> {
  $$WidgetPreferencesTableTableManager(
      _$AppDatabase db, $WidgetPreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WidgetPreferencesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double?> windowX = const Value.absent(),
            Value<double?> windowY = const Value.absent(),
            Value<double> windowWidth = const Value.absent(),
            Value<double> windowHeight = const Value.absent(),
            Value<double> opacity = const Value.absent(),
            Value<double> backgroundOpacity = const Value.absent(),
            Value<double> cardOpacity = const Value.absent(),
            Value<bool> isAlwaysOnTop = const Value.absent(),
            Value<bool> isPositionLocked = const Value.absent(),
            Value<bool> isSizeLocked = const Value.absent(),
            Value<bool> showInTaskbar = const Value.absent(),
            Value<String> widgetMode = const Value.absent(),
            Value<String?> themePresetId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WidgetPreferencesCompanion(
            id: id,
            windowX: windowX,
            windowY: windowY,
            windowWidth: windowWidth,
            windowHeight: windowHeight,
            opacity: opacity,
            backgroundOpacity: backgroundOpacity,
            cardOpacity: cardOpacity,
            isAlwaysOnTop: isAlwaysOnTop,
            isPositionLocked: isPositionLocked,
            isSizeLocked: isSizeLocked,
            showInTaskbar: showInTaskbar,
            widgetMode: widgetMode,
            themePresetId: themePresetId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<double?> windowX = const Value.absent(),
            Value<double?> windowY = const Value.absent(),
            Value<double> windowWidth = const Value.absent(),
            Value<double> windowHeight = const Value.absent(),
            Value<double> opacity = const Value.absent(),
            Value<double> backgroundOpacity = const Value.absent(),
            Value<double> cardOpacity = const Value.absent(),
            Value<bool> isAlwaysOnTop = const Value.absent(),
            Value<bool> isPositionLocked = const Value.absent(),
            Value<bool> isSizeLocked = const Value.absent(),
            Value<bool> showInTaskbar = const Value.absent(),
            Value<String> widgetMode = const Value.absent(),
            Value<String?> themePresetId = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              WidgetPreferencesCompanion.insert(
            id: id,
            windowX: windowX,
            windowY: windowY,
            windowWidth: windowWidth,
            windowHeight: windowHeight,
            opacity: opacity,
            backgroundOpacity: backgroundOpacity,
            cardOpacity: cardOpacity,
            isAlwaysOnTop: isAlwaysOnTop,
            isPositionLocked: isPositionLocked,
            isSizeLocked: isSizeLocked,
            showInTaskbar: showInTaskbar,
            widgetMode: widgetMode,
            themePresetId: themePresetId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WidgetPreferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WidgetPreferencesTable,
    WidgetPreferenceRow,
    $$WidgetPreferencesTableFilterComposer,
    $$WidgetPreferencesTableOrderingComposer,
    $$WidgetPreferencesTableAnnotationComposer,
    $$WidgetPreferencesTableCreateCompanionBuilder,
    $$WidgetPreferencesTableUpdateCompanionBuilder,
    (
      WidgetPreferenceRow,
      BaseReferences<_$AppDatabase, $WidgetPreferencesTable,
          WidgetPreferenceRow>
    ),
    WidgetPreferenceRow,
    PrefetchHooks Function()>;
typedef $$ThemePresetsTableCreateCompanionBuilder = ThemePresetsCompanion
    Function({
  required String id,
  required String name,
  required int backgroundColor,
  required int cardColor,
  required int textColor,
  required int accentColor,
  Value<double> borderRadius,
  Value<double> shadowIntensity,
  Value<double> blurIntensity,
  Value<String> fontFamily,
  Value<double> fontSize,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ThemePresetsTableUpdateCompanionBuilder = ThemePresetsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<int> backgroundColor,
  Value<int> cardColor,
  Value<int> textColor,
  Value<int> accentColor,
  Value<double> borderRadius,
  Value<double> shadowIntensity,
  Value<double> blurIntensity,
  Value<String> fontFamily,
  Value<double> fontSize,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ThemePresetsTableFilterComposer
    extends Composer<_$AppDatabase, $ThemePresetsTable> {
  $$ThemePresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardColor => $composableBuilder(
      column: $table.cardColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get textColor => $composableBuilder(
      column: $table.textColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accentColor => $composableBuilder(
      column: $table.accentColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get borderRadius => $composableBuilder(
      column: $table.borderRadius, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shadowIntensity => $composableBuilder(
      column: $table.shadowIntensity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get blurIntensity => $composableBuilder(
      column: $table.blurIntensity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ThemePresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThemePresetsTable> {
  $$ThemePresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardColor => $composableBuilder(
      column: $table.cardColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get textColor => $composableBuilder(
      column: $table.textColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accentColor => $composableBuilder(
      column: $table.accentColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get borderRadius => $composableBuilder(
      column: $table.borderRadius,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shadowIntensity => $composableBuilder(
      column: $table.shadowIntensity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get blurIntensity => $composableBuilder(
      column: $table.blurIntensity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ThemePresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThemePresetsTable> {
  $$ThemePresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor, builder: (column) => column);

  GeneratedColumn<int> get cardColor =>
      $composableBuilder(column: $table.cardColor, builder: (column) => column);

  GeneratedColumn<int> get textColor =>
      $composableBuilder(column: $table.textColor, builder: (column) => column);

  GeneratedColumn<int> get accentColor => $composableBuilder(
      column: $table.accentColor, builder: (column) => column);

  GeneratedColumn<double> get borderRadius => $composableBuilder(
      column: $table.borderRadius, builder: (column) => column);

  GeneratedColumn<double> get shadowIntensity => $composableBuilder(
      column: $table.shadowIntensity, builder: (column) => column);

  GeneratedColumn<double> get blurIntensity => $composableBuilder(
      column: $table.blurIntensity, builder: (column) => column);

  GeneratedColumn<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => column);

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ThemePresetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ThemePresetsTable,
    ThemePresetRow,
    $$ThemePresetsTableFilterComposer,
    $$ThemePresetsTableOrderingComposer,
    $$ThemePresetsTableAnnotationComposer,
    $$ThemePresetsTableCreateCompanionBuilder,
    $$ThemePresetsTableUpdateCompanionBuilder,
    (
      ThemePresetRow,
      BaseReferences<_$AppDatabase, $ThemePresetsTable, ThemePresetRow>
    ),
    ThemePresetRow,
    PrefetchHooks Function()> {
  $$ThemePresetsTableTableManager(_$AppDatabase db, $ThemePresetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemePresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemePresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemePresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> backgroundColor = const Value.absent(),
            Value<int> cardColor = const Value.absent(),
            Value<int> textColor = const Value.absent(),
            Value<int> accentColor = const Value.absent(),
            Value<double> borderRadius = const Value.absent(),
            Value<double> shadowIntensity = const Value.absent(),
            Value<double> blurIntensity = const Value.absent(),
            Value<String> fontFamily = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThemePresetsCompanion(
            id: id,
            name: name,
            backgroundColor: backgroundColor,
            cardColor: cardColor,
            textColor: textColor,
            accentColor: accentColor,
            borderRadius: borderRadius,
            shadowIntensity: shadowIntensity,
            blurIntensity: blurIntensity,
            fontFamily: fontFamily,
            fontSize: fontSize,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int backgroundColor,
            required int cardColor,
            required int textColor,
            required int accentColor,
            Value<double> borderRadius = const Value.absent(),
            Value<double> shadowIntensity = const Value.absent(),
            Value<double> blurIntensity = const Value.absent(),
            Value<String> fontFamily = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ThemePresetsCompanion.insert(
            id: id,
            name: name,
            backgroundColor: backgroundColor,
            cardColor: cardColor,
            textColor: textColor,
            accentColor: accentColor,
            borderRadius: borderRadius,
            shadowIntensity: shadowIntensity,
            blurIntensity: blurIntensity,
            fontFamily: fontFamily,
            fontSize: fontSize,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ThemePresetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ThemePresetsTable,
    ThemePresetRow,
    $$ThemePresetsTableFilterComposer,
    $$ThemePresetsTableOrderingComposer,
    $$ThemePresetsTableAnnotationComposer,
    $$ThemePresetsTableCreateCompanionBuilder,
    $$ThemePresetsTableUpdateCompanionBuilder,
    (
      ThemePresetRow,
      BaseReferences<_$AppDatabase, $ThemePresetsTable, ThemePresetRow>
    ),
    ThemePresetRow,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableTableCreateCompanionBuilder
    = AppSettingsTableCompanion Function({
  required String id,
  Value<int> startDayOfWeek,
  Value<bool> showKoreanHolidays,
  Value<bool> showCanadaHolidays,
  Value<bool> showLunarCalendar,
  Value<bool> showSolarTerms,
  Value<bool> showCompletedTasksOnCalendar,
  Value<bool> showOverdueTasksOnCalendar,
  Value<double> monthItemTextScale,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableTableUpdateCompanionBuilder
    = AppSettingsTableCompanion Function({
  Value<String> id,
  Value<int> startDayOfWeek,
  Value<bool> showKoreanHolidays,
  Value<bool> showCanadaHolidays,
  Value<bool> showLunarCalendar,
  Value<bool> showSolarTerms,
  Value<bool> showCompletedTasksOnCalendar,
  Value<bool> showOverdueTasksOnCalendar,
  Value<double> monthItemTextScale,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startDayOfWeek => $composableBuilder(
      column: $table.startDayOfWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showKoreanHolidays => $composableBuilder(
      column: $table.showKoreanHolidays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showCanadaHolidays => $composableBuilder(
      column: $table.showCanadaHolidays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showLunarCalendar => $composableBuilder(
      column: $table.showLunarCalendar,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showSolarTerms => $composableBuilder(
      column: $table.showSolarTerms,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showCompletedTasksOnCalendar => $composableBuilder(
      column: $table.showCompletedTasksOnCalendar,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showOverdueTasksOnCalendar => $composableBuilder(
      column: $table.showOverdueTasksOnCalendar,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthItemTextScale => $composableBuilder(
      column: $table.monthItemTextScale,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startDayOfWeek => $composableBuilder(
      column: $table.startDayOfWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showKoreanHolidays => $composableBuilder(
      column: $table.showKoreanHolidays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showCanadaHolidays => $composableBuilder(
      column: $table.showCanadaHolidays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showLunarCalendar => $composableBuilder(
      column: $table.showLunarCalendar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showSolarTerms => $composableBuilder(
      column: $table.showSolarTerms,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showCompletedTasksOnCalendar => $composableBuilder(
      column: $table.showCompletedTasksOnCalendar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showOverdueTasksOnCalendar => $composableBuilder(
      column: $table.showOverdueTasksOnCalendar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthItemTextScale => $composableBuilder(
      column: $table.monthItemTextScale,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startDayOfWeek => $composableBuilder(
      column: $table.startDayOfWeek, builder: (column) => column);

  GeneratedColumn<bool> get showKoreanHolidays => $composableBuilder(
      column: $table.showKoreanHolidays, builder: (column) => column);

  GeneratedColumn<bool> get showCanadaHolidays => $composableBuilder(
      column: $table.showCanadaHolidays, builder: (column) => column);

  GeneratedColumn<bool> get showLunarCalendar => $composableBuilder(
      column: $table.showLunarCalendar, builder: (column) => column);

  GeneratedColumn<bool> get showSolarTerms => $composableBuilder(
      column: $table.showSolarTerms, builder: (column) => column);

  GeneratedColumn<bool> get showCompletedTasksOnCalendar => $composableBuilder(
      column: $table.showCompletedTasksOnCalendar, builder: (column) => column);

  GeneratedColumn<bool> get showOverdueTasksOnCalendar => $composableBuilder(
      column: $table.showOverdueTasksOnCalendar, builder: (column) => column);

  GeneratedColumn<double> get monthItemTextScale => $composableBuilder(
      column: $table.monthItemTextScale, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsRow,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsRow,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSettingsRow>
    ),
    AppSettingsRow,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableTableManager(
      _$AppDatabase db, $AppSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> startDayOfWeek = const Value.absent(),
            Value<bool> showKoreanHolidays = const Value.absent(),
            Value<bool> showCanadaHolidays = const Value.absent(),
            Value<bool> showLunarCalendar = const Value.absent(),
            Value<bool> showSolarTerms = const Value.absent(),
            Value<bool> showCompletedTasksOnCalendar = const Value.absent(),
            Value<bool> showOverdueTasksOnCalendar = const Value.absent(),
            Value<double> monthItemTextScale = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion(
            id: id,
            startDayOfWeek: startDayOfWeek,
            showKoreanHolidays: showKoreanHolidays,
            showCanadaHolidays: showCanadaHolidays,
            showLunarCalendar: showLunarCalendar,
            showSolarTerms: showSolarTerms,
            showCompletedTasksOnCalendar: showCompletedTasksOnCalendar,
            showOverdueTasksOnCalendar: showOverdueTasksOnCalendar,
            monthItemTextScale: monthItemTextScale,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int> startDayOfWeek = const Value.absent(),
            Value<bool> showKoreanHolidays = const Value.absent(),
            Value<bool> showCanadaHolidays = const Value.absent(),
            Value<bool> showLunarCalendar = const Value.absent(),
            Value<bool> showSolarTerms = const Value.absent(),
            Value<bool> showCompletedTasksOnCalendar = const Value.absent(),
            Value<bool> showOverdueTasksOnCalendar = const Value.absent(),
            Value<double> monthItemTextScale = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion.insert(
            id: id,
            startDayOfWeek: startDayOfWeek,
            showKoreanHolidays: showKoreanHolidays,
            showCanadaHolidays: showCanadaHolidays,
            showLunarCalendar: showLunarCalendar,
            showSolarTerms: showSolarTerms,
            showCompletedTasksOnCalendar: showCompletedTasksOnCalendar,
            showOverdueTasksOnCalendar: showOverdueTasksOnCalendar,
            monthItemTextScale: monthItemTextScale,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsRow,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsRow,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSettingsRow>
    ),
    AppSettingsRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$WidgetPreferencesTableTableManager get widgetPreferences =>
      $$WidgetPreferencesTableTableManager(_db, _db.widgetPreferences);
  $$ThemePresetsTableTableManager get themePresets =>
      $$ThemePresetsTableTableManager(_db, _db.themePresets);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}

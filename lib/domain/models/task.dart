import 'priority.dart';

/// Domain model for a to-do item. Framework-agnostic (no Drift/Firebase
/// imports) so it can be shared by every layer, including future iOS/web UI.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.dueTimeMinutes,
    this.priority = TaskPriority.medium,
    this.categoryId,
    this.tagIds = const [],
    this.sortOrder = 0,
    this.reminderMinutesBefore,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;

  /// Calendar date only (time-of-day stripped). Null = no due date.
  final DateTime? dueDate;

  /// Minutes since midnight (0-1439), null = no specific time, just the date.
  final int? dueTimeMinutes;

  final TaskPriority priority;
  final String? categoryId;
  final List<String> tagIds;
  final int sortOrder;

  /// Minutes before `dueDate`+`dueTimeMinutes` to fire a reminder
  /// notification. Null = no reminder, or no `dueDate` (reminders need a
  /// due date to compute a fire time — see ReminderScheduler).
  final int? reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Task copyWith({
    String? title,
    Object? description = _sentinel,
    bool? isCompleted,
    Object? dueDate = _sentinel,
    Object? dueTimeMinutes = _sentinel,
    TaskPriority? priority,
    Object? categoryId = _sentinel,
    List<String>? tagIds,
    int? sortOrder,
    Object? reminderMinutesBefore = _sentinel,
    DateTime? updatedAt,
    Object? completedAt = _sentinel,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description == _sentinel ? this.description : description as String?,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate == _sentinel ? this.dueDate : dueDate as DateTime?,
      dueTimeMinutes:
          dueTimeMinutes == _sentinel ? this.dueTimeMinutes : dueTimeMinutes as int?,
      priority: priority ?? this.priority,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as String?,
      tagIds: tagIds ?? this.tagIds,
      sortOrder: sortOrder ?? this.sortOrder,
      reminderMinutesBefore: reminderMinutesBefore == _sentinel
          ? this.reminderMinutesBefore
          : reminderMinutesBefore as int?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt == _sentinel ? this.completedAt : completedAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'dueDate': dueDate?.toIso8601String(),
        'dueTimeMinutes': dueTimeMinutes,
        'priority': priority.value,
        'categoryId': categoryId,
        'tagIds': tagIds,
        'sortOrder': sortOrder,
        'reminderMinutesBefore': reminderMinutesBefore,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String),
        dueTimeMinutes: json['dueTimeMinutes'] as int?,
        priority: TaskPriority.fromValue(json['priority'] as String? ?? 'medium'),
        categoryId: json['categoryId'] as String?,
        tagIds: (json['tagIds'] as List?)?.cast<String>() ?? const [],
        sortOrder: json['sortOrder'] as int? ?? 0,
        reminderMinutesBefore: json['reminderMinutesBefore'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        completedAt:
            json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      );
}

const Object _sentinel = Object();

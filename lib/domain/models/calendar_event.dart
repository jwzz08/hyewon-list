/// Domain model for a personal calendar event, including recurrence-ready
/// fields (see ARCHITECTURE.md "Recurrence design" for the full rationale).
///
/// [RecurringEventService] generates display instances from [recurrenceRule]
/// for Daily/Weekly/Monthly/Yearly with a simple BYDAY list.
/// Occurrence-level edit/delete (this-only / this-and-following /
/// entire-series) IS implemented — see AddItemDialog's delete/save flow and
/// `showEditScopeDialog` (recurring_edit_scope_dialog.dart) for the UI, and
/// [parentEventId] / [originalOccurrenceDate] / [recurrenceExceptionDates]
/// for the fields that make it work.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    this.isAllDay = false,
    this.categoryId,
    this.color,
    this.location,
    this.isRecurring = false,
    this.recurrenceRule,
    this.recurrenceEndDate,
    this.recurrenceCount,
    this.parentEventId,
    this.originalOccurrenceDate,
    this.recurrenceExceptionDates = const [],
    this.reminderMinutesBefore,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isAllDay;
  final String? categoryId;

  /// ARGB int color, falls back to the event's category color in the UI
  /// when null.
  final int? color;
  final String? location;

  // --- Recurrence ---
  final bool isRecurring;

  /// RRULE-style string, e.g. `FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR`.
  final String? recurrenceRule;
  final DateTime? recurrenceEndDate;
  final int? recurrenceCount;

  /// Set on a *detached occurrence* row that overrides one instance of a
  /// recurring series. Null for both non-recurring events and the series
  /// "parent" row itself.
  final String? parentEventId;

  /// The date (within the parent's series) that this detached occurrence
  /// replaces. Only meaningful when [parentEventId] is set.
  final DateTime? originalOccurrenceDate;

  /// Dates removed from the parent series (deleted single occurrences)
  /// without creating a detached override row.
  final List<DateTime> recurrenceExceptionDates;

  /// Minutes before `startDateTime` to fire a reminder notification. Null =
  /// no reminder. For a recurring series, this only schedules against the
  /// parent row's own `startDateTime` — see ReminderScheduler doc comment.
  final int? reminderMinutesBefore;

  final DateTime createdAt;
  final DateTime updatedAt;

  Duration get duration => endDateTime.difference(startDateTime);

  CalendarEvent copyWith({
    String? title,
    Object? description = _sentinel,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isAllDay,
    Object? categoryId = _sentinel,
    Object? color = _sentinel,
    Object? location = _sentinel,
    bool? isRecurring,
    Object? recurrenceRule = _sentinel,
    Object? recurrenceEndDate = _sentinel,
    Object? recurrenceCount = _sentinel,
    Object? parentEventId = _sentinel,
    Object? originalOccurrenceDate = _sentinel,
    List<DateTime>? recurrenceExceptionDates,
    Object? reminderMinutesBefore = _sentinel,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      description: description == _sentinel ? this.description : description as String?,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isAllDay: isAllDay ?? this.isAllDay,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as String?,
      color: color == _sentinel ? this.color : color as int?,
      location: location == _sentinel ? this.location : location as String?,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule:
          recurrenceRule == _sentinel ? this.recurrenceRule : recurrenceRule as String?,
      recurrenceEndDate: recurrenceEndDate == _sentinel
          ? this.recurrenceEndDate
          : recurrenceEndDate as DateTime?,
      recurrenceCount:
          recurrenceCount == _sentinel ? this.recurrenceCount : recurrenceCount as int?,
      parentEventId: parentEventId == _sentinel ? this.parentEventId : parentEventId as String?,
      originalOccurrenceDate: originalOccurrenceDate == _sentinel
          ? this.originalOccurrenceDate
          : originalOccurrenceDate as DateTime?,
      recurrenceExceptionDates: recurrenceExceptionDates ?? this.recurrenceExceptionDates,
      reminderMinutesBefore: reminderMinutesBefore == _sentinel
          ? this.reminderMinutesBefore
          : reminderMinutesBefore as int?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDateTime': startDateTime.toIso8601String(),
        'endDateTime': endDateTime.toIso8601String(),
        'isAllDay': isAllDay,
        'categoryId': categoryId,
        'color': color,
        'location': location,
        'isRecurring': isRecurring,
        'recurrenceRule': recurrenceRule,
        'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
        'recurrenceCount': recurrenceCount,
        'parentEventId': parentEventId,
        'originalOccurrenceDate': originalOccurrenceDate?.toIso8601String(),
        'recurrenceExceptionDates':
            recurrenceExceptionDates.map((d) => d.toIso8601String()).toList(),
        'reminderMinutesBefore': reminderMinutesBefore,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startDateTime: DateTime.parse(json['startDateTime'] as String),
        endDateTime: DateTime.parse(json['endDateTime'] as String),
        isAllDay: json['isAllDay'] as bool? ?? false,
        categoryId: json['categoryId'] as String?,
        color: json['color'] as int?,
        location: json['location'] as String?,
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurrenceRule: json['recurrenceRule'] as String?,
        recurrenceEndDate: json['recurrenceEndDate'] == null
            ? null
            : DateTime.parse(json['recurrenceEndDate'] as String),
        recurrenceCount: json['recurrenceCount'] as int?,
        parentEventId: json['parentEventId'] as String?,
        originalOccurrenceDate: json['originalOccurrenceDate'] == null
            ? null
            : DateTime.parse(json['originalOccurrenceDate'] as String),
        recurrenceExceptionDates: (json['recurrenceExceptionDates'] as List?)
                ?.map((d) => DateTime.parse(d as String))
                .toList() ??
            const [],
        reminderMinutesBefore: json['reminderMinutesBefore'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

const Object _sentinel = Object();

/// A concrete instance of an event on the calendar — either the event itself
/// (non-recurring) or one generated occurrence of a recurring series.
/// Returned by [RecurringEventService] for rendering; never persisted.
class CalendarEventOccurrence {
  const CalendarEventOccurrence({
    required this.sourceEvent,
    required this.occurrenceStart,
    required this.occurrenceEnd,
    required this.isGeneratedRecurrence,
  });

  final CalendarEvent sourceEvent;
  final DateTime occurrenceStart;
  final DateTime occurrenceEnd;

  /// True for instances generated by [RecurringEventService] from a
  /// recurrence rule (as opposed to a literal stored row).
  final bool isGeneratedRecurrence;
}

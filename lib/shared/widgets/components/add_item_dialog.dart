import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/priority.dart';
import '../../../domain/models/recurrence_frequency.dart';
import '../../../domain/models/task.dart';
import '../../../features/calendar/application/calendar_providers.dart';
import '../../../features/calendar/domain/recurring_event_service.dart';
import '../../../features/categories/application/category_providers.dart';
import '../../../features/tasks/application/task_providers.dart';
import '../../utils/undo_actions.dart';
import 'chip_selector.dart';
import 'recurring_edit_scope_dialog.dart';

/// Which kind of item the unified [AddItemDialog] is creating. Tasks and
/// calendar events remain fully separate domain models/providers under the
/// hood (see WeeklyTaskSection/WeeklyScheduleSection docs) — this enum only
/// drives which half of *this one form* is shown, so the user can pick
/// To-do vs Schedule no matter which "+" affordance they started from.
enum AddItemType { task, event }

enum _EndCondition { never, onDate, afterCount }

/// Reminder lead-time options offered in both task and event forms — `null`
/// means no reminder. See ReminderScheduler for how these get turned into
/// actual scheduled notifications.
const List<int?> _reminderOptions = [null, 0, 5, 15, 30, 60, 1440];

String _reminderLabel(int? minutes) => switch (minutes) {
      null => 'None',
      0 => 'At time',
      5 => '5 min before',
      15 => '15 min before',
      30 => '30 min before',
      60 => '1 hour before',
      1440 => '1 day before',
      _ => '$minutes min before',
    };

/// The single entry point every "add" affordance in the app should call —
/// widget mode's "+", the planner composer, a day column's "+ add" footer,
/// and the month grid's add button all open this same dialog now, so the
/// type picker and full detail options (due time, priority, category,
/// event time range, recurrence) are available everywhere, not just in one
/// place.
Future<void> showAddItemDialog(
  BuildContext context, {
  DateTime? initialDate,
  AddItemType initialType = AddItemType.task,
  String? initialTitle,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AddItemDialog(
      initialDate: initialDate,
      initialType: initialType,
      initialTitle: initialTitle,
    ),
  );
}

/// Opens [AddItemDialog] pre-filled with [task] and switches it into edit
/// mode (Save updates the existing row instead of creating a new one; a
/// Delete button appears too).
Future<void> showEditTaskDialog(BuildContext context, Task task) {
  return showDialog<void>(
    context: context,
    builder: (_) => AddItemDialog(editingTask: task),
  );
}

/// Opens [AddItemDialog] pre-filled with [occurrence] and switches it into
/// edit mode. [occurrence] (not just the bare [CalendarEvent]) is required
/// so a recurring series knows *which date* is being edited — that date is
/// what the "this event only" / "this and following" scope choice acts on.
Future<void> showEditEventDialog(BuildContext context, CalendarEventOccurrence occurrence) {
  return showDialog<void>(
    context: context,
    builder: (_) => AddItemDialog(editingOccurrence: occurrence),
  );
}

class AddItemDialog extends ConsumerStatefulWidget {
  const AddItemDialog({
    super.key,
    this.initialDate,
    this.initialType = AddItemType.task,
    this.initialTitle,
    this.editingTask,
    this.editingOccurrence,
  });

  final DateTime? initialDate;
  final AddItemType initialType;

  /// Pre-fills the title field for a brand-new item — used by QuickAddBar's
  /// "+" button so text already typed into the composer isn't lost when it
  /// hands off to this full dialog instead of quick-adding. Ignored when
  /// editing (the title comes from [editingTask]/[editingOccurrence] then).
  final String? initialTitle;

  /// Non-null when editing an existing task instead of creating a new one.
  final Task? editingTask;

  /// Non-null when editing an existing event (or one occurrence of a
  /// recurring series) instead of creating a new one.
  final CalendarEventOccurrence? editingOccurrence;

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  late AddItemType _type;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  // --- Task fields ---
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority _priority = TaskPriority.medium;

  // --- Event fields ---
  late DateTime _startDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  late DateTime _endDate;
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isAllDay = false;

  // --- Shared ---
  String? _categoryId;

  // Event color (independent of category — see _buildColorPicker). Defaults
  // to the first palette swatch for a brand-new event so one always reads
  // as selected; overwritten from the existing event's color when editing.
  int? _colorOverride = AppColors.eventColorPalette.first.value;
  int? _reminderMinutesBefore;

  // --- Recurrence (event only) ---
  RecurrenceFrequency _frequency = RecurrenceFrequency.none;
  int _interval = 1;
  final Set<RecurrenceWeekday> _byDay = {};
  _EndCondition _endCondition = _EndCondition.never;
  DateTime? _untilDate;
  int _count = 5;

  bool get _isEditing => widget.editingTask != null || widget.editingOccurrence != null;

  @override
  void initState() {
    super.initState();
    final DateTime base = widget.initialDate ?? DateTime.now();
    _dueDate = base;
    _startDate = base;
    _endDate = base;

    if (widget.editingTask != null) {
      final Task task = widget.editingTask!;
      _type = AddItemType.task;
      _titleCtrl.text = task.title;
      _descCtrl.text = task.description ?? '';
      _dueDate = task.dueDate;
      _dueTime = task.dueTimeMinutes == null
          ? null
          : TimeOfDay(hour: task.dueTimeMinutes! ~/ 60, minute: task.dueTimeMinutes! % 60);
      _priority = task.priority;
      _categoryId = task.categoryId;
      _reminderMinutesBefore = task.reminderMinutesBefore;
      return;
    }

    if (widget.editingOccurrence != null) {
      final CalendarEventOccurrence occurrence = widget.editingOccurrence!;
      final CalendarEvent event = occurrence.sourceEvent;
      _type = AddItemType.event;
      _titleCtrl.text = event.title;
      _descCtrl.text = event.description ?? '';
      _locationCtrl.text = event.location ?? '';
      _isAllDay = event.isAllDay;
      // Pre-fill from the *occurrence's* actual date, not the series'
      // original startDateTime — editing the 3rd Tuesday of a weekly
      // series should show that Tuesday's date, not the series' first day.
      _startDate = AppDateUtils.dateOnly(occurrence.occurrenceStart);
      _startTime =
          TimeOfDay(hour: occurrence.occurrenceStart.hour, minute: occurrence.occurrenceStart.minute);
      _endDate = AppDateUtils.dateOnly(occurrence.occurrenceEnd);
      _endTime = TimeOfDay(hour: occurrence.occurrenceEnd.hour, minute: occurrence.occurrenceEnd.minute);
      _categoryId = event.categoryId;
      _colorOverride = event.color ?? AppColors.eventColorPalette.first.value;
      _reminderMinutesBefore = event.reminderMinutesBefore;

      if (event.isRecurring && event.recurrenceRule != null && event.recurrenceRule!.isNotEmpty) {
        final parts = parseRecurrenceRuleParts(event.recurrenceRule!);
        _frequency = parts.frequency;
        _interval = parts.interval;
        _byDay
          ..clear()
          ..addAll(parts.byDay);
        final DateTime? until = event.recurrenceEndDate ?? parts.until;
        final int? count = event.recurrenceCount ?? parts.count;
        if (until != null) {
          _endCondition = _EndCondition.onDate;
          _untilDate = until;
        } else if (count != null) {
          _endCondition = _EndCondition.afterCount;
          _count = count;
        } else {
          _endCondition = _EndCondition.never;
        }
      }
      return;
    }

    _type = widget.initialType;
    if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
      _titleCtrl.text = widget.initialTitle!;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = ref.watch(allCategoriesProvider).value ?? const <Category>[];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: 420, maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing
                    ? (_type == AddItemType.task ? 'Edit to-do' : 'Edit schedule')
                    : 'Add new',
                style: AppTextStyles.display(fontSize: 17),
              ),
              const SizedBox(height: 12),
              if (!_isEditing)
                ChipSelector<AddItemType>(
                  options: const [AddItemType.task, AddItemType.event],
                  value: _type,
                  labelBuilder: (t) => t == AddItemType.task ? 'To-do' : 'Schedule',
                  onChanged: (t) => setState(() => _type = t),
                ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: _type == AddItemType.task ? 'Task title' : 'Event title',
                        ),
                        style: AppTextStyles.body(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      if (_type == AddItemType.task) _buildTaskFields() else _buildEventFields(),
                      const SizedBox(height: 10),
                      _buildCategoryPicker(categories),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descCtrl,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(hintText: 'Notes (optional)'),
                        style: AppTextStyles.body(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_isEditing)
                    TextButton(
                      onPressed: _delete,
                      style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
                      child: const Text('Delete'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(_isEditing
                        ? 'Save changes'
                        : (_type == AddItemType.task ? 'Save task' : 'Save event')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Task-specific fields ----

  Widget _buildTaskFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Due date'),
        Row(
          children: [
            _pickerButton(
              label: _dueDate == null ? 'No due date' : _formatDate(_dueDate!),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                tooltip: 'Clear due date',
                onPressed: () => setState(() => _dueDate = null),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _fieldLabel('Set a time'),
            const Spacer(),
            Switch(
              value: _dueTime != null,
              onChanged: (v) async {
                if (!v) {
                  setState(() => _dueTime = null);
                  return;
                }
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _dueTime ?? const TimeOfDay(hour: 9, minute: 0),
                );
                setState(() => _dueTime = picked ?? const TimeOfDay(hour: 9, minute: 0));
              },
            ),
            if (_dueTime != null)
              _pickerButton(
                label: _dueTime!.format(context),
                onTap: () async {
                  final TimeOfDay? picked =
                      await showTimePicker(context: context, initialTime: _dueTime!);
                  if (picked != null) setState(() => _dueTime = picked);
                },
              ),
          ],
        ),
        const SizedBox(height: 6),
        _fieldLabel('Priority'),
        const SizedBox(height: 4),
        ChipSelector<TaskPriority>(
          options: TaskPriority.values,
          value: _priority,
          dense: true,
          labelBuilder: (p) => p.value[0].toUpperCase() + p.value.substring(1),
          onChanged: (p) => setState(() => _priority = p),
        ),
        const SizedBox(height: 10),
        _buildReminderPicker(),
      ],
    );
  }

  // ---- Event-specific fields ----

  Widget _buildEventFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fieldLabel('All day'),
            const Spacer(),
            Switch(value: _isAllDay, onChanged: (v) => setState(() => _isAllDay = v)),
          ],
        ),
        _fieldLabel('Starts'),
        Row(
          children: [
            _pickerButton(
              label: _formatDate(_startDate),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked == null) return;
                setState(() {
                  _startDate = picked;
                  if (_endDate.isBefore(_startDate)) _endDate = _startDate;
                });
              },
            ),
            if (!_isAllDay)
              _pickerButton(
                label: _startTime.format(context),
                onTap: () async {
                  final TimeOfDay? picked =
                      await showTimePicker(context: context, initialTime: _startTime);
                  if (picked != null) setState(() => _startTime = picked);
                },
              ),
          ],
        ),
        const SizedBox(height: 4),
        _fieldLabel('Ends'),
        Row(
          children: [
            _pickerButton(
              label: _formatDate(_endDate),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
            if (!_isAllDay)
              _pickerButton(
                label: _endTime.format(context),
                onTap: () async {
                  final TimeOfDay? picked =
                      await showTimePicker(context: context, initialTime: _endTime);
                  if (picked != null) setState(() => _endTime = picked);
                },
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _locationCtrl,
          decoration: const InputDecoration(hintText: 'Location (optional)'),
          style: AppTextStyles.body(fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        _buildColorPicker(),
        const SizedBox(height: 10),
        _buildReminderPicker(),
        const SizedBox(height: 12),
        _buildRecurrenceSection(),
      ],
    );
  }

  // ---- Color (event only) ----

  /// Independent of category — this is what actually shows on the event's
  /// month-view chip/bar (see MonthlyCalendarGrid/CalendarDayCell), so a
  /// user can give two events in the same category visibly different colors,
  /// or match an uncategorized event to whatever color they like.
  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Color'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppColors.eventColorPalette
              .map((c) => _ColorSwatch(
                    color: c,
                    selected: _colorOverride == c.value,
                    onTap: () => setState(() => _colorOverride = c.value),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ---- Reminder (shared) ----

  Widget _buildReminderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Reminder'),
        const SizedBox(height: 4),
        ChipSelector<int?>(
          options: _reminderOptions,
          value: _reminderMinutesBefore,
          dense: true,
          labelBuilder: _reminderLabel,
          onChanged: (v) => setState(() => _reminderMinutesBefore = v),
        ),
      ],
    );
  }

  Widget _buildRecurrenceSection() {
    const RecurringEventService service = RecurringEventService();
    final String preview = _frequency == RecurrenceFrequency.none
        ? 'Does not repeat'
        : service.describeRecurrence(_previewEvent());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Repeat'),
        const SizedBox(height: 4),
        ChipSelector<RecurrenceFrequency>(
          options: const [
            RecurrenceFrequency.none,
            RecurrenceFrequency.daily,
            RecurrenceFrequency.weekly,
            RecurrenceFrequency.monthly,
            RecurrenceFrequency.yearly,
          ],
          value: _frequency,
          dense: true,
          labelBuilder: (f) => switch (f) {
            RecurrenceFrequency.none => 'None',
            RecurrenceFrequency.daily => 'Daily',
            RecurrenceFrequency.weekly => 'Weekly',
            RecurrenceFrequency.monthly => 'Monthly',
            RecurrenceFrequency.yearly => 'Yearly',
            _ => f.value,
          },
          onChanged: (f) => setState(() => _frequency = f),
        ),
        if (_frequency != RecurrenceFrequency.none) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              _fieldLabel('Every'),
              const SizedBox(width: 8),
              _stepper(value: _interval, onChanged: (v) => setState(() => _interval = v)),
              const SizedBox(width: 6),
              Text(_intervalUnitLabel(), style: AppTextStyles.meta()),
            ],
          ),
          if (_frequency == RecurrenceFrequency.weekly) ...[
            const SizedBox(height: 10),
            _fieldLabel('On days'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: RecurrenceWeekday.values.map((d) {
                final bool selected = _byDay.contains(d);
                return GestureDetector(
                  onTap: () => setState(() => selected ? _byDay.remove(d) : _byDay.add(d)),
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.bgNeutral,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      d.code.substring(0, 1),
                      style: AppTextStyles.meta(
                        fontSize: 10,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 10),
          _fieldLabel('Ends'),
          const SizedBox(height: 4),
          ChipSelector<_EndCondition>(
            options: _EndCondition.values,
            value: _endCondition,
            dense: true,
            labelBuilder: (c) => switch (c) {
              _EndCondition.never => 'Never',
              _EndCondition.onDate => 'On date',
              _EndCondition.afterCount => 'After N times',
            },
            onChanged: (c) => setState(() => _endCondition = c),
          ),
          if (_endCondition == _EndCondition.onDate) ...[
            const SizedBox(height: 6),
            _pickerButton(
              label: _untilDate == null ? 'Pick end date' : _formatDate(_untilDate!),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _untilDate ?? _startDate.add(const Duration(days: 30)),
                  firstDate: _startDate,
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _untilDate = picked);
              },
            ),
          ],
          if (_endCondition == _EndCondition.afterCount) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                _stepper(value: _count, min: 1, onChanged: (v) => setState(() => _count = v)),
                const SizedBox(width: 6),
                Text('occurrences', style: AppTextStyles.meta()),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(preview,
              style: AppTextStyles.meta(fontSize: 10.5, color: AppColors.accentTextLabel)),
        ],
      ],
    );
  }

  CalendarEvent _previewEvent() {
    final DateTime start =
        DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    return CalendarEvent(
      id: 'preview',
      title: '',
      startDateTime: start,
      endDateTime: start.add(const Duration(hours: 1)),
      isRecurring: true,
      recurrenceRule: buildRecurrenceRule(
        frequency: _frequency,
        interval: _interval,
        byDay: _frequency == RecurrenceFrequency.weekly ? _byDay : const {},
        until: _endCondition == _EndCondition.onDate ? _untilDate : null,
        count: _endCondition == _EndCondition.afterCount ? _count : null,
      ),
      recurrenceEndDate: _endCondition == _EndCondition.onDate ? _untilDate : null,
      recurrenceCount: _endCondition == _EndCondition.afterCount ? _count : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _intervalUnitLabel() {
    final bool plural = _interval != 1;
    return switch (_frequency) {
      RecurrenceFrequency.daily => plural ? 'days' : 'day',
      RecurrenceFrequency.weekly => plural ? 'weeks' : 'week',
      RecurrenceFrequency.monthly => plural ? 'months' : 'month',
      RecurrenceFrequency.yearly => plural ? 'years' : 'year',
      _ => 'time(s)',
    };
  }

  // ---- Shared ----

  Widget _buildCategoryPicker(List<Category> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Category'),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _CategoryPickerChip(
              label: 'None',
              color: AppColors.textFaint,
              selected: _categoryId == null,
              onTap: () => setState(() => _categoryId = null),
            ),
            ...categories.map((c) => _CategoryPickerChip(
                  label: c.name,
                  color: Color(c.color),
                  selected: _categoryId == c.id,
                  onTap: () => setState(() => _categoryId = c.id),
                )),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(text, style: AppTextStyles.sectionLabel());

  Widget _pickerButton({required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgNeutral,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Text(label, style: AppTextStyles.body(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _stepper({required int value, int min = 1, required ValueChanged<int> onChanged}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(Icons.remove, () {
          if (value > min) onChanged(value - 1);
        }),
        SizedBox(
          width: 24,
          child: Text('$value', textAlign: TextAlign.center, style: AppTextStyles.body(fontSize: 13)),
        ),
        _stepperButton(Icons.add, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.bgNeutral, shape: BoxShape.circle),
        child: Icon(icon, size: 13, color: AppColors.textSecondary),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final String title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final String? description = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    final DateTime now = DateTime.now();

    if (_type == AddItemType.task) {
      if (widget.editingTask != null) {
        final Task updated = widget.editingTask!.copyWith(
          title: title,
          description: description,
          dueDate: _dueDate,
          dueTimeMinutes: _dueTime == null ? null : _dueTime!.hour * 60 + _dueTime!.minute,
          priority: _priority,
          categoryId: _categoryId,
          reminderMinutesBefore: _reminderMinutesBefore,
          updatedAt: now,
        );
        await editTaskWithUndo(context, ref, widget.editingTask!, updated);
      } else {
        final Task task = Task(
          id: IdGenerator.newId(),
          title: title,
          description: description,
          dueDate: _dueDate,
          dueTimeMinutes: _dueTime == null ? null : _dueTime!.hour * 60 + _dueTime!.minute,
          priority: _priority,
          categoryId: _categoryId,
          reminderMinutesBefore: _reminderMinutesBefore,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(taskActionsProvider).create(task);
      }
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final DateTime start = _isAllDay
        ? AppDateUtils.dateOnly(_startDate)
        : DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    DateTime end = _isAllDay
        ? AppDateUtils.dateOnly(_endDate).add(const Duration(days: 1))
        : DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);
    if (!end.isAfter(start)) end = start.add(const Duration(hours: 1));

    final bool recurring = _frequency != RecurrenceFrequency.none;
    final String? rule = recurring
        ? buildRecurrenceRule(
            frequency: _frequency,
            interval: _interval,
            byDay: _frequency == RecurrenceFrequency.weekly ? _byDay : const {},
            until: _endCondition == _EndCondition.onDate ? _untilDate : null,
            count: _endCondition == _EndCondition.afterCount ? _count : null,
          )
        : null;
    final String? location = _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim();

    if (widget.editingOccurrence == null) {
      final CalendarEvent event = CalendarEvent(
        id: IdGenerator.newId(),
        title: title,
        description: description,
        startDateTime: start,
        endDateTime: end,
        isAllDay: _isAllDay,
        categoryId: _categoryId,
        color: _colorOverride,
        location: location,
        isRecurring: recurring,
        recurrenceRule: rule,
        recurrenceEndDate: _endCondition == _EndCondition.onDate ? _untilDate : null,
        recurrenceCount: _endCondition == _EndCondition.afterCount ? _count : null,
        reminderMinutesBefore: _reminderMinutesBefore,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(calendarEventActionsProvider).create(event);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // --- Editing an existing event / occurrence ---
    final CalendarEvent parent = widget.editingOccurrence!.sourceEvent;
    final CalendarEventActions actions = ref.read(calendarEventActionsProvider);

    if (!parent.isRecurring) {
      // Plain event, or a single already-detached occurrence row — no
      // series to worry about, just update the row directly.
      final CalendarEvent updated = parent.copyWith(
        title: title,
        description: description,
        startDateTime: start,
        endDateTime: end,
        isAllDay: _isAllDay,
        categoryId: _categoryId,
        color: _colorOverride,
        location: location,
        isRecurring: recurring,
        recurrenceRule: rule,
        recurrenceEndDate: _endCondition == _EndCondition.onDate ? _untilDate : null,
        recurrenceCount: _endCondition == _EndCondition.afterCount ? _count : null,
        reminderMinutesBefore: _reminderMinutesBefore,
        updatedAt: now,
      );
      await editEventWithUndo(context, ref, parent, updated);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final EditScope? scope = await showEditScopeDialog(context, actionLabel: 'Save changes');
    if (scope == null) return; // user cancelled the scope picker — keep the form open

    const RecurringEventService service = RecurringEventService();
    final DateTime occurrenceDate =
        AppDateUtils.dateOnly(widget.editingOccurrence!.occurrenceStart);

    switch (scope) {
      case EditScope.thisOccurrence:
        final CalendarEvent detached = CalendarEvent(
          id: IdGenerator.newId(),
          title: title,
          description: description,
          startDateTime: start,
          endDateTime: end,
          isAllDay: _isAllDay,
          categoryId: _categoryId,
          color: _colorOverride,
          location: location,
          parentEventId: parent.id,
          originalOccurrenceDate: occurrenceDate,
          reminderMinutesBefore: _reminderMinutesBefore,
          createdAt: now,
          updatedAt: now,
        );
        await actions.create(detached);
        await actions.update(service.applyExceptionDate(parent, occurrenceDate));
        break;

      case EditScope.thisAndFollowing:
        final DateTime cutoff = occurrenceDate.subtract(const Duration(days: 1));
        await actions.update(parent.copyWith(recurrenceEndDate: cutoff, updatedAt: now));
        final CalendarEvent newSeries = CalendarEvent(
          id: IdGenerator.newId(),
          title: title,
          description: description,
          startDateTime: start,
          endDateTime: end,
          isAllDay: _isAllDay,
          categoryId: _categoryId,
          color: _colorOverride,
          location: location,
          isRecurring: recurring,
          recurrenceRule: rule,
          recurrenceEndDate: _endCondition == _EndCondition.onDate ? _untilDate : null,
          recurrenceCount: _endCondition == _EndCondition.afterCount ? _count : null,
          reminderMinutesBefore: _reminderMinutesBefore,
          createdAt: now,
          updatedAt: now,
        );
        await actions.create(newSeries);
        break;

      case EditScope.entireSeries:
        final CalendarEvent updated = parent.copyWith(
          title: title,
          description: description,
          startDateTime: start,
          endDateTime: end,
          isAllDay: _isAllDay,
          categoryId: _categoryId,
          color: _colorOverride,
          location: location,
          isRecurring: recurring,
          recurrenceRule: rule,
          recurrenceEndDate: _endCondition == _EndCondition.onDate ? _untilDate : null,
          recurrenceCount: _endCondition == _EndCondition.afterCount ? _count : null,
          reminderMinutesBefore: _reminderMinutesBefore,
          updatedAt: now,
        );
        // Only this scope gets an Undo snackbar — it's a single-row update
        // just like the non-recurring-event branch above. `thisOccurrence`/
        // `thisAndFollowing` (above) each touch two rows (a new detached/
        // split-off event plus a parent-series mutation), so a plain
        // `update(original)` on undo wouldn't cleanly reverse either one —
        // see editEventWithUndo's doc comment.
        await editEventWithUndo(context, ref, parent, updated);
        break;
    }

    if (mounted) Navigator.of(context).pop();
  }

  /// Deletes immediately rather than showing an "are you sure?" dialog —
  /// [deleteTaskWithUndo]/[deleteEventWithUndo] pop an Undo snackbar
  /// instead, which is both faster for the common case and still fully
  /// recoverable for the rare mis-click (see shared/utils/undo_actions.dart).
  Future<void> _delete() async {
    if (widget.editingTask != null) {
      // Show the Undo snackbar (needs a still-mounted `context` to find the
      // app-level ScaffoldMessenger) *before* popping this dialog — once
      // popped, this widget's context is on its way to being disposed and
      // can no longer be used to look anything up.
      await deleteTaskWithUndo(context, ref, widget.editingTask!);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (widget.editingOccurrence == null) return;
    final CalendarEvent parent = widget.editingOccurrence!.sourceEvent;
    final CalendarEventActions actions = ref.read(calendarEventActionsProvider);

    if (!parent.isRecurring) {
      await deleteEventWithUndo(context, ref, parent);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final EditScope? scope = await showEditScopeDialog(context, actionLabel: 'Delete');
    if (scope == null) return;

    const RecurringEventService service = RecurringEventService();
    final DateTime occurrenceDate =
        AppDateUtils.dateOnly(widget.editingOccurrence!.occurrenceStart);

    switch (scope) {
      case EditScope.thisOccurrence:
        await actions.update(service.applyExceptionDate(parent, occurrenceDate));
        if (mounted) Navigator.of(context).pop();
        break;
      case EditScope.thisAndFollowing:
        final DateTime cutoff = occurrenceDate.subtract(const Duration(days: 1));
        await actions.update(parent.copyWith(recurrenceEndDate: cutoff, updatedAt: DateTime.now()));
        if (mounted) Navigator.of(context).pop();
        break;
      case EditScope.entireSeries:
        await deleteEventWithUndo(context, ref, parent);
        if (mounted) Navigator.of(context).pop();
        break;
    }
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.textBody : Colors.white,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.35), blurRadius: selected ? 6 : 0),
          ],
        ),
        child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
      ),
    );
  }
}

class _CategoryPickerChip extends StatelessWidget {
  const _CategoryPickerChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : Colors.transparent,
          border: Border.all(color: selected ? color : AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(label, style: AppTextStyles.meta(color: selected ? color : AppColors.textSecondary)),
      ),
    );
  }
}

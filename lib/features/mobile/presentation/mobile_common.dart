import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/task.dart';
import '../../../shared/widgets/components/add_item_dialog.dart';
import '../../../shared/widgets/components/event_card.dart';
import '../../../shared/widgets/components/task_row.dart';
import '../../calendar/application/calendar_providers.dart';
import '../../categories/application/category_providers.dart';
import '../../tasks/application/task_providers.dart';

/// Minimum comfortable touch target on iOS (Apple HIG).
const double kMinTouch = 44;

/// Weekend tint for date labels: Saturday blue, Sunday red, else null.
Color? weekendColor(DateTime d) {
  if (d.weekday == DateTime.saturday) return AppColors.categoryWork;
  if (d.weekday == DateTime.sunday) return AppColors.priorityHighText;
  return null;
}

/// White rounded card matching the design's grouped-list look.
class MobileCard extends StatelessWidget {
  const MobileCard({super.key, required this.child, this.padding, this.color, this.borderColor});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: borderColor ?? AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class MobileSectionLabel extends StatelessWidget {
  const MobileSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
      child: Text(text.toUpperCase(), style: AppTextStyles.sectionLabel()),
    );
  }
}

/// `[start, end-of-day]` range used for single-day provider lookups — the
/// same shape `todayTasksProvider` uses.
(DateTime, DateTime) dayRange(DateTime day) {
  final DateTime start = DateTime(day.year, day.month, day.day);
  return (start, start.add(const Duration(hours: 23, minutes: 59, seconds: 59)));
}

/// Dismissible wrapper: swipe right to toggle completion without removing
/// the row (the list reorders itself from the DB stream).
class SwipeToComplete extends ConsumerWidget {
  const SwipeToComplete({super.key, required this.task, required this.child});

  final Task task;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('swipe_${task.id}_${task.isCompleted}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        await ref.read(taskActionsProvider).setCompleted(task.id, !task.isCompleted);
        return false;
      },
      background: Container(
        color: AppColors.categoryHome.withOpacity(0.18),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          task.isCompleted ? Icons.undo_rounded : Icons.check_rounded,
          color: AppColors.categoryHome,
        ),
      ),
      child: child,
    );
  }
}

/// Tappable task row (44pt minimum height, swipe-to-complete, category chip).
class MobileTaskTile extends ConsumerWidget {
  const MobileTaskTile({super.key, required this.task, this.showDueDate = false});

  final Task task;
  final bool showDueDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, Category> categories = {
      for (final Category c in ref.watch(allCategoriesProvider).value ?? const <Category>[]) c.id: c,
    };
    final Category? category = categories[task.categoryId];
    return SwipeToComplete(
      task: task,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTouch),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TaskRow(
            task: task,
            categoryLabel: category?.name,
            categoryColor: category == null ? null : Color(category.color),
            showDueDateLabel: showDueDate,
            onToggle: (v) => ref.read(taskActionsProvider).setCompleted(task.id, v),
            onTap: () => showEditTaskDialog(context, task),
          ),
        ),
      ),
    );
  }
}

class MobileEventTile extends StatelessWidget {
  const MobileEventTile({super.key, required this.occurrence});

  final CalendarEventOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinTouch),
      child: EventCard(
        event: occurrence.sourceEvent,
        onTap: () => showEditEventDialog(context, occurrence),
      ),
    );
  }
}

/// Card of tasks with hairline dividers.
class MobileTaskList extends StatelessWidget {
  const MobileTaskList({super.key, required this.tasks, this.showDueDate = false});

  final List<Task> tasks;
  final bool showDueDate;

  @override
  Widget build(BuildContext context) {
    final List<Task> sorted = [...tasks]
      ..sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
    return MobileCard(
      child: Column(
        children: [
          for (int i = 0; i < sorted.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.borderLight),
            MobileTaskTile(task: sorted[i], showDueDate: showDueDate),
          ],
        ],
      ),
    );
  }
}

/// To-do + Schedule sections for one day, shared by Today/Week/Month.
class DayItems extends ConsumerWidget {
  const DayItems({super.key, required this.day, this.emptyLabel = 'Nothing planned'});

  final DateTime day;
  final String emptyLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = dayRange(day);
    final List<Task> tasks = ref.watch(tasksInRangeProvider(range)).value ?? const <Task>[];
    final List<CalendarEventOccurrence> events =
        ref.watch(calendarOccurrencesInRangeProvider(range)).value ?? const <CalendarEventOccurrence>[];

    if (tasks.isEmpty && events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(emptyLabel, style: AppTextStyles.meta(fontSize: 13))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tasks.isNotEmpty) ...[
          MobileSectionLabel('To-do · ${tasks.length}'),
          MobileTaskList(tasks: tasks),
        ],
        if (events.isNotEmpty) ...[
          MobileSectionLabel('Schedule · ${events.length}'),
          for (final CalendarEventOccurrence o in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MobileEventTile(occurrence: o),
            ),
        ],
      ],
    );
  }
}

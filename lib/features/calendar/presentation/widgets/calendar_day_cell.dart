import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../domain/holiday_model.dart';

/// One cell of [MonthlyCalendarGrid]. Renders up to 3 task/event chips plus
/// a "+N more" indicator — deliberately desktop-planner-dense rather than
/// mobile-calendar-sparse, per spec section 6.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.tasks,
    required this.eventOccurrences,
    this.holiday,
    required this.onTap,
    this.onAddTap,
    this.onTaskTap,
    this.onEventTap,
    this.onTaskDropped,
    this.onEventDropped,
    this.reservedTopSpace = 0,
    this.textScale = 1.0,
  });

  final DateTime day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<Task> tasks;

  /// Single-day tasks/events only — multi-day events are excluded by the
  /// caller (MonthlyCalendarGrid) and rendered instead as a continuous bar
  /// spanning cells (see _WeekRow/_MultiDayBarChip there).
  final List<CalendarEventOccurrence> eventOccurrences;

  /// Vertical space (in logical pixels) to leave blank right below the date
  /// number, reserved for that week row's multi-day event bar overlay so it
  /// doesn't cover the date number or get covered by this cell's own chips.
  /// Set by MonthlyCalendarGrid based on how many bar "lanes" that week needs.
  final double reservedTopSpace;

  /// Padding around this cell's content. Named (not just inlined below) so
  /// MonthlyCalendarGrid's _WeekRow can compute exactly where the multi-day
  /// bar overlay should start, instead of an approximate guess.
  static const double cellPadding = 6;

  /// Fixed height given to the date-number row (instead of letting the Text
  /// size itself naturally) so [headerHeight] below is an exact value, not
  /// an estimate — this is what stops a multi-day bar from ever overlapping
  /// this cell's date number or its first chip.
  static const double dateNumberRowHeight = 16;

  /// Total offset from this cell's top edge to where the reserved
  /// multi-day-bar gap begins. _WeekRow positions its bar overlay using
  /// exactly this value.
  static const double headerHeight = cellPadding + dateNumberRowHeight;

  /// A public holiday falling on [day], if any and if enabled in settings.
  /// Rendered as its own small label — deliberately NOT mixed into the
  /// task/event chip list (see HolidayService doc comment: "4th visual
  /// layer" per ARCHITECTURE.md).
  final Holiday? holiday;
  final VoidCallback onTap;
  final VoidCallback? onAddTap;

  /// Tapping an individual task chip opens that task for editing — separate
  /// from [onTap] (which selects the whole day) so a nested InkWell/tap
  /// target on the chip itself takes priority over the cell-wide one.
  final void Function(Task task)? onTaskTap;
  final void Function(CalendarEventOccurrence occurrence)? onEventTap;

  /// A task/event chip (from this cell or another) was dropped onto this
  /// day — the caller (MonthlyCalendarGrid, which has `ref`) does the
  /// actual move so this widget can stay a plain StatelessWidget.
  final void Function(Task task)? onTaskDropped;
  final void Function(CalendarEventOccurrence occurrence)? onEventDropped;

  /// Multiplier for chip/holiday text size — see AppSettings.monthItemTextScale
  /// and CalendarSettingsSection's "Month view text size" slider.
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final List<_CellItem> items = [
      ...tasks.map((t) => _CellItem.task(t)),
      ...eventOccurrences.map((o) => _CellItem.event(o)),
    ];
    final int overflow = items.length > 3 ? items.length - 3 : 0;
    final List<_CellItem> visible = items.take(3).toList();

    final Color bg = !isCurrentMonth
        ? AppColors.monthOverflowBg
        : isSelected
            ? AppColors.dragOverTint
            : isToday
                ? AppColors.todayTint
                : AppColors.cardWhite;

    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) =>
          details.data is Task || details.data is CalendarEventOccurrence,
      onAcceptWithDetails: (details) {
        final Object data = details.data;
        if (data is Task) {
          onTaskDropped?.call(data);
        } else if (data is CalendarEventOccurrence) {
          onEventDropped?.call(data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final bool isDragOver = candidateData.isNotEmpty;
        return InkWell(
          onTap: onTap,
          onDoubleTap: onAddTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(cellPadding),
            color: isDragOver ? AppColors.dragOverTint : bg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: dateNumberRowHeight,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${day.day}',
                      style: AppTextStyles.meta(
                        fontSize: 11,
                        color: !isCurrentMonth
                            ? AppColors.monthOverflowText
                            : holiday != null
                                ? (holiday!.country == HolidayCountry.solarTerm
                                    ? AppColors.accentDark
                                    : AppColors.priorityHigh)
                                : isToday
                                    ? AppColors.accentDark
                                    : AppColors.textBody,
                      ),
                    ),
                  ),
                ),
                if (reservedTopSpace > 0) SizedBox(height: reservedTopSpace),
                if (holiday != null)
                  Text(
                    holiday!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meta(
                      fontSize: 8 * textScale,
                      color: holiday!.country == HolidayCountry.solarTerm
                          ? AppColors.accentDark
                          : AppColors.priorityHigh,
                    ),
                  ),
                const SizedBox(height: 3),
                // A busy day can still exceed 3 chips' worth of height once
                // the grid gets narrow enough to shrink row height below
                // ~66px (see childAspectRatio in MonthlyCalendarGrid) —
                // wrapping in Expanded + a scroll view means that
                // clips/scrolls instead of throwing a RenderFlex overflow
                // error.
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      ...visible.map((item) => _CellChip(
                            item: item,
                            textScale: textScale,
                            onTap: item.task != null
                                ? (onTaskTap == null ? null : () => onTaskTap!(item.task!))
                                : (onEventTap == null ? null : () => onEventTap!(item.event!)),
                          )),
                      if (overflow > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('+$overflow more',
                              style: AppTextStyles.meta(fontSize: 9 * textScale)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CellItem {
  _CellItem.task(this.task) : event = null;
  _CellItem.event(this.event) : task = null;

  final Task? task;
  final CalendarEventOccurrence? event;
}

class _CellChip extends StatelessWidget {
  const _CellChip({required this.item, this.onTap, this.textScale = 1.0});

  final _CellItem item;
  final VoidCallback? onTap;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    if (item.task != null) {
      final Task task = item.task!;
      final bool overdue =
          !task.isCompleted && task.dueDate != null && AppDateUtils.isOverdue(task.dueDate!);
      final Color color =
          overdue ? AppColors.priorityHigh : AppColors.forPriorityLevel(task.priority.value);
      final Widget chip = _chip(
        color: color,
        child: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.meta(
            fontSize: 9 * textScale,
            color: task.isCompleted ? AppColors.textFaint : AppColors.textBody,
          ),
        ),
      );
      return Draggable<Object>(
        data: task,
        feedback: Opacity(
          opacity: 0.35,
          child: SizedBox(width: 120, child: Material(color: Colors.transparent, child: chip)),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: chip),
        child: chip,
      );
    }

    final CalendarEventOccurrence occurrence = item.event!;
    final Color color = occurrence.sourceEvent.color != null
        ? Color(occurrence.sourceEvent.color!)
        : AppColors.categoryWork;
    final Widget chip = _chip(
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (occurrence.sourceEvent.isRecurring) ...[
            Icon(Icons.repeat, size: 8, color: color.withOpacity(0.65)),
            const SizedBox(width: 2),
          ],
          Flexible(
            child: Text(
              occurrence.sourceEvent.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.meta(fontSize: 9 * textScale, color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
    return Draggable<Object>(
      data: occurrence,
      feedback: Opacity(
        opacity: 0.35,
        child: SizedBox(width: 120, child: Material(color: Colors.transparent, child: chip)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }

  // Was a plain square-cornered box with a flat left accent border — read as
  // "just a rectangle" per feedback. A fully-rounded pill with a small
  // leading color dot (instead of the border) is a softer, friendlier shape
  // at this chip's small size without losing the at-a-glance color coding.
  Widget _chip({required Color color, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

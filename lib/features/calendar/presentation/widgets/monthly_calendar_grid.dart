import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../../../shared/widgets/components/add_item_dialog.dart';
import '../../../tasks/application/task_providers.dart';
import '../../../settings/application/settings_providers.dart';
import '../../application/event_drag_drop.dart';
import '../../application/month_providers.dart';
import '../../domain/holiday_model.dart';
import 'calendar_day_cell.dart';

/// Full month grid (6 rows x 7 columns, padded with adjacent-month days) —
/// "should feel like a desktop planner calendar", not a small mobile
/// calendar, per spec section 6.
///
/// Multi-day events (see [AppDateUtils.isMultiDaySpan]) are pulled out of
/// the per-day chip lists and rendered instead as a single continuous bar
/// that spans the day cells it covers within a week row — matching how
/// desktop calendar apps show a consecutive event as one connected block
/// instead of a separate chip repeated on every day. A bar that continues
/// past a week-row boundary renders as two square-edged segments (one per
/// row) so it still visually reads as "the same event continuing", while a
/// bar's true start/end day gets a rounded cap.
class MonthlyCalendarGrid extends ConsumerWidget {
  const MonthlyCalendarGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DateTime> gridDates = ref.watch(monthGridDatesProvider);
    final DateTime monthAnchor = ref.watch(selectedMonthAnchorProvider);
    final DateTime? selectedDate = ref.watch(selectedDateProvider);
    final List<Task> tasks = ref.watch(monthTasksProvider).value ?? const <Task>[];
    final List<CalendarEventOccurrence> events =
        ref.watch(monthEventsProvider).value ?? const <CalendarEventOccurrence>[];
    final List<Holiday> holidays = ref.watch(monthHolidaysProvider);
    final double textScale = ref.watch(appSettingsProvider).value?.monthItemTextScale ?? 1.3;

    final List<CalendarEventOccurrence> multiDayEvents = events
        .where((o) => AppDateUtils.isMultiDaySpan(o.occurrenceStart, o.occurrenceEnd))
        .toList();
    final Set<CalendarEventOccurrence> multiDaySet = multiDayEvents.toSet();
    final List<CalendarEventOccurrence> singleDayEvents =
        events.where((o) => !multiDaySet.contains(o)).toList();

    final List<List<DateTime>> weeks = [
      for (int i = 0; i < gridDates.length; i += 7) gridDates.sublist(i, i + 7),
    ];

    return Column(
      children: [
        Row(
          children: AppDateUtils.weekdayShortLabels
              .map(
                (label) => Expanded(
                  child: Center(child: Text(label, style: AppTextStyles.sectionLabel())),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Column(
            children: [
              for (int w = 0; w < weeks.length; w++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: w < weeks.length - 1 ? 2 : 0),
                    child: _WeekRow(
                      days: weeks[w],
                      monthAnchor: monthAnchor,
                      selectedDate: selectedDate,
                      tasks: tasks,
                      singleDayEvents: singleDayEvents,
                      multiDayEvents: multiDayEvents
                          .where((o) => weeks[w]
                              .any((d) => AppDateUtils.occursOnDay(o.occurrenceStart, o.occurrenceEnd, d)))
                          .toList(),
                      holidays: holidays,
                      textScale: textScale,
                      onDayTap: (day) => ref.read(selectedDateProvider.notifier).state = day,
                      onAddTap: (day) =>
                          showAddItemDialog(context, initialDate: day, initialType: AddItemType.event),
                      onTaskTap: (task) => showEditTaskDialog(context, task),
                      onEventTap: (occurrence) => showEditEventDialog(context, occurrence),
                      onTaskDropped: (task, day) =>
                          ref.read(taskActionsProvider).moveToDate(task.id, day),
                      onEventDropped: (occurrence, day) =>
                          handleEventDroppedOnDay(context, ref, occurrence, day),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One 7-day row of the month grid, plus a [Stack]-ed overlay of any
/// multi-day event bars that touch this week.
class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.days,
    required this.monthAnchor,
    required this.selectedDate,
    required this.tasks,
    required this.singleDayEvents,
    required this.multiDayEvents,
    required this.holidays,
    required this.onDayTap,
    required this.onAddTap,
    required this.onTaskTap,
    required this.onEventTap,
    required this.onTaskDropped,
    required this.onEventDropped,
    this.textScale = 1.0,
  });

  final List<DateTime> days;
  final DateTime monthAnchor;
  final DateTime? selectedDate;
  final List<Task> tasks;
  final List<CalendarEventOccurrence> singleDayEvents;

  /// Multi-day occurrences that touch at least one day in this week — not
  /// yet clipped/laned to this row, that happens in [_layoutSegments].
  final List<CalendarEventOccurrence> multiDayEvents;
  final List<Holiday> holidays;

  /// See AppSettings.monthItemTextScale — threaded down to CalendarDayCell
  /// and _MultiDayBarChip's text.
  final double textScale;
  final void Function(DateTime day) onDayTap;
  final void Function(DateTime day) onAddTap;
  final void Function(Task task) onTaskTap;
  final void Function(CalendarEventOccurrence occurrence) onEventTap;
  final void Function(Task task, DateTime day) onTaskDropped;
  final void Function(CalendarEventOccurrence occurrence, DateTime day) onEventDropped;

  static const double _barHeight = 14;
  static const double _barSpacing = 2;

  /// Exact offset from a day cell's top edge to where its reserved
  /// multi-day-bar gap begins — sourced from CalendarDayCell itself (not
  /// re-guessed here) so a bar can never overlap the date number or, more
  /// importantly, the day's first event chip.
  static const double _headerHeight = CalendarDayCell.headerHeight;

  @override
  Widget build(BuildContext context) {
    final List<_BarSegment> segments = _layoutSegments();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellWidth = constraints.maxWidth / 7;
        return Stack(
          children: [
            Row(
              children: [
                for (int i = 0; i < days.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < days.length - 1 ? 2 : 0),
                      child: _dayCell(days[i], _reservedTopForColumn(segments, i)),
                    ),
                  ),
              ],
            ),
            for (final _BarSegment seg in segments)
              Positioned(
                left: seg.startCol * cellWidth + 2,
                top: _headerHeight + seg.lane * (_barHeight + _barSpacing),
                width: (seg.endCol - seg.startCol + 1) * cellWidth - 4,
                height: _barHeight,
                child: _MultiDayBarChip(
                  occurrence: seg.occurrence,
                  roundLeft: seg.isStart,
                  roundRight: seg.isEnd,
                  textScale: textScale,
                  onTap: () => onEventTap(seg.occurrence),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Reserved top space for the day at column [col] — based only on the
  /// bar lanes that actually pass over *that* column, not a single value
  /// shared by every day in the week. A week can easily contain a 2-day
  /// event on Mon-Tue and nothing else; before this, Wed-Sun's day cells
  /// still reserved space for a bar that was never drawn over them, pushing
  /// their own single-day chips down by a full row for no reason.
  double _reservedTopForColumn(List<_BarSegment> segments, int col) {
    int highestLane = -1;
    for (final _BarSegment seg in segments) {
      if (col >= seg.startCol && col <= seg.endCol && seg.lane > highestLane) {
        highestLane = seg.lane;
      }
    }
    return highestLane == -1 ? 0 : (highestLane + 1) * (_barHeight + _barSpacing);
  }

  Widget _dayCell(DateTime day, double reservedTop) {
    // Dart only promotes *private* final fields across null checks — since
    // this class's fields are named to match their constructor params
    // (public), copy to a local first so `selected != null` actually
    // promotes it to non-nullable below.
    final DateTime? selected = selectedDate;
    final bool isCurrentMonth = day.month == monthAnchor.month && day.year == monthAnchor.year;
    final List<Task> dayTasks =
        tasks.where((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, day)).toList();
    final List<CalendarEventOccurrence> dayEvents = singleDayEvents
        .where((o) => AppDateUtils.occursOnDay(o.occurrenceStart, o.occurrenceEnd, day))
        .toList();
    final Holiday? dayHoliday = holidays.where((h) => AppDateUtils.isSameDay(h.date, day)).isEmpty
        ? null
        : holidays.firstWhere((h) => AppDateUtils.isSameDay(h.date, day));

    return CalendarDayCell(
      day: day,
      isCurrentMonth: isCurrentMonth,
      isToday: AppDateUtils.isToday(day),
      isSelected: selected != null && AppDateUtils.isSameDay(selected, day),
      tasks: dayTasks,
      eventOccurrences: dayEvents,
      holiday: dayHoliday,
      reservedTopSpace: reservedTop,
      textScale: textScale,
      onTap: () => onDayTap(day),
      onAddTap: () => onAddTap(day),
      onTaskTap: onTaskTap,
      onEventTap: onEventTap,
      onTaskDropped: (task) => onTaskDropped(task, day),
      onEventDropped: (occurrence) => onEventDropped(occurrence, day),
    );
  }

  /// Clips each multi-day occurrence to this week's 0-6 column range and
  /// packs overlapping bars into stacked lanes via greedy interval packing
  /// (sorted by start column, then by longest span first).
  List<_BarSegment> _layoutSegments() {
    if (multiDayEvents.isEmpty) return const [];
    final DateTime weekStart = AppDateUtils.dateOnly(days.first);
    final List<_BarSegment> raw = [];
    for (final CalendarEventOccurrence o in multiDayEvents) {
      final DateTime evStart = AppDateUtils.dateOnly(o.occurrenceStart);
      final DateTime evLastDay =
          AppDateUtils.dateOnly(o.occurrenceEnd.subtract(const Duration(minutes: 1)));
      final int rawStartCol = evStart.difference(weekStart).inDays;
      final int rawEndCol = evLastDay.difference(weekStart).inDays;
      final bool isStart = rawStartCol <= 0;
      final bool isEnd = rawEndCol >= 6;
      final int startCol = rawStartCol.clamp(0, 6);
      final int endCol = rawEndCol.clamp(0, 6);
      if (startCol > endCol) continue;
      raw.add(_BarSegment(
        occurrence: o,
        startCol: startCol,
        endCol: endCol,
        lane: 0,
        isStart: isStart,
        isEnd: isEnd,
      ));
    }
    raw.sort((a, b) {
      final int byStart = a.startCol.compareTo(b.startCol);
      if (byStart != 0) return byStart;
      return (b.endCol - b.startCol).compareTo(a.endCol - a.startCol);
    });

    final List<int> laneLastCol = [];
    final List<_BarSegment> result = [];
    for (final _BarSegment seg in raw) {
      int lane = laneLastCol.indexWhere((lastCol) => lastCol < seg.startCol);
      if (lane == -1) {
        lane = laneLastCol.length;
        laneLastCol.add(seg.endCol);
      } else {
        laneLastCol[lane] = seg.endCol;
      }
      result.add(seg.copyWithLane(lane));
    }
    return result;
  }
}

class _BarSegment {
  const _BarSegment({
    required this.occurrence,
    required this.startCol,
    required this.endCol,
    required this.lane,
    required this.isStart,
    required this.isEnd,
  });

  final CalendarEventOccurrence occurrence;
  final int startCol;
  final int endCol;
  final int lane;

  /// True when this segment contains the event's real first day (i.e. it's
  /// not just clipped at this week's left edge) — gets a rounded left cap.
  final bool isStart;

  /// True when this segment contains the event's real last day — gets a
  /// rounded right cap.
  final bool isEnd;

  _BarSegment copyWithLane(int newLane) => _BarSegment(
        occurrence: occurrence,
        startCol: startCol,
        endCol: endCol,
        lane: newLane,
        isStart: isStart,
        isEnd: isEnd,
      );
}

/// The continuous bar rendered for one week-row segment of a multi-day
/// event. Square edges where the bar is clipped by the week boundary (i.e.
/// continues onto another row) signal "this keeps going", rounded edges
/// mark the event's actual start/end.
class _MultiDayBarChip extends StatelessWidget {
  const _MultiDayBarChip({
    required this.occurrence,
    required this.roundLeft,
    required this.roundRight,
    required this.onTap,
    this.textScale = 1.0,
  });

  final CalendarEventOccurrence occurrence;
  final bool roundLeft;
  final bool roundRight;
  final VoidCallback onTap;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final Color color =
        occurrence.sourceEvent.color != null ? Color(occurrence.sourceEvent.color!) : AppColors.categoryWork;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          borderRadius: BorderRadius.horizontal(
            left: roundLeft ? const Radius.circular(4) : Radius.zero,
            right: roundRight ? const Radius.circular(4) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (occurrence.sourceEvent.isRecurring) ...[
              const Icon(Icons.repeat, size: 8, color: Colors.white),
              const SizedBox(width: 2),
            ],
            Flexible(
              child: Text(
                occurrence.sourceEvent.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.meta(fontSize: 9 * textScale, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

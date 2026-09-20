import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/task.dart';
import '../../calendar/application/month_providers.dart';
import '../../calendar/domain/holiday_model.dart';
import '../../settings/application/settings_providers.dart';
import 'mobile_common.dart';

/// "Month" tab: month grid with dot markers + holiday labels; the selected
/// day's items are listed underneath. Reuses the desktop month providers.
class MobileCalendarScreen extends ConsumerWidget {
  const MobileCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime anchor = ref.watch(selectedMonthAnchorProvider);
    final DateTime selected = ref.watch(selectedDateProvider) ?? DateTime.now();
    final List<DateTime> grid = ref.watch(monthGridDatesProvider);
    final int startDay = ref.watch(startDayOfWeekProvider);
    final List<Task> tasks = ref.watch(monthTasksProvider).value ?? const <Task>[];
    final List<CalendarEventOccurrence> events =
        ref.watch(monthEventsProvider).value ?? const <CalendarEventOccurrence>[];
    final List<Holiday> holidays = ref.watch(monthHolidaysProvider);

    bool hasTask(DateTime d) => tasks.any((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, d));
    bool hasEvent(DateTime d) => events.any(
        (o) => AppDateUtils.occursOnDay(o.occurrenceStart, o.occurrenceEnd, d));
    Holiday? holidayOn(DateTime d) {
      for (final Holiday h in holidays) {
        if (h.country != HolidayCountry.solarTerm && AppDateUtils.isSameDay(h.date, d)) return h;
      }
      return null;
    }

    Holiday? termOn(DateTime d) {
      for (final Holiday h in holidays) {
        if (h.country == HolidayCountry.solarTerm && AppDateUtils.isSameDay(h.date, d)) return h;
      }
      return null;
    }

    void moveMonth(int delta) {
      final DateTime next = DateTime(anchor.year, anchor.month + delta, 1);
      ref.read(selectedMonthAnchorProvider.notifier).state = next;
      ref.read(selectedDateProvider.notifier).state = next;
    }

    final List<String> labels = AppDateUtils.weekdayLabelsFrom(startDay);
    final Holiday? selectedHoliday = holidayOn(selected);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppDateUtils.monthLabels[anchor.month - 1], style: AppTextStyles.display(fontSize: 28)),
                    Text('${anchor.year}', style: AppTextStyles.meta(fontSize: 12)),
                  ],
                ),
              ),
              _NavButton(icon: Icons.chevron_left_rounded, onTap: () => moveMonth(-1)),
              const SizedBox(width: 8),
              _NavButton(icon: Icons.chevron_right_rounded, onTap: () => moveMonth(1)),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(kMinTouch, kMinTouch),
                  backgroundColor: AppColors.accentTint,
                  foregroundColor: AppColors.accentTextStrong,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  final DateTime now = DateTime.now();
                  ref.read(selectedMonthAnchorProvider.notifier).state = now;
                  ref.read(selectedDateProvider.notifier).state = now;
                },
                child: const Text('Today'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MobileCard(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
            child: Column(
              children: [
                Row(
                  children: [
                    for (final String l in labels)
                      Expanded(
                        child: Center(
                          child: Text(
                            l.substring(0, 1),
                            style: AppTextStyles.sectionLabel(
                              color: l == 'Sat'
                                  ? AppColors.categoryWork
                                  : (l == 'Sun' ? AppColors.priorityHighText : null),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                for (int row = 0; row < 6; row++)
                  Row(
                    children: [
                      for (int col = 0; col < 7; col++)
                        Expanded(
                          child: _MonthCell(
                            date: grid[row * 7 + col],
                            inMonth: grid[row * 7 + col].month == anchor.month,
                            isSelected: AppDateUtils.isSameDay(grid[row * 7 + col], selected),
                            hasTask: hasTask(grid[row * 7 + col]),
                            hasEvent: hasEvent(grid[row * 7 + col]),
                            holiday: holidayOn(grid[row * 7 + col]),
                            term: termOn(grid[row * 7 + col]),
                            onTap: () =>
                                ref.read(selectedDateProvider.notifier).state = grid[row * 7 + col],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LegendDot(color: AppColors.priorityHigh, label: 'Holiday'),
              const SizedBox(width: 14),
              _LegendDot(color: AppColors.accent, label: 'Solar term'),
              const SizedBox(width: 14),
              _LegendDot(color: AppColors.categoryHome, label: 'Event'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AppDateUtils.weekdayShortLabels[selected.weekday - 1]}, ${AppDateUtils.formatShortDate(selected)}',
                  style: AppTextStyles.display(
                    fontSize: 18,
                    color: selectedHoliday != null ? AppColors.priorityHighText : weekendColor(selected),
                  ),
                ),
              ),
              if (selectedHoliday != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.priorityHighTint,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    selectedHoliday.name,
                    style: AppTextStyles.body(
                      fontSize: 12,
                      weight: FontWeight.w800,
                      color: AppColors.priorityHighText,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          DayItems(day: selected),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      shape: CircleBorder(side: BorderSide(color: AppColors.borderLight)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: kMinTouch, height: kMinTouch, child: Icon(icon, color: AppColors.textBody)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.meta(fontSize: 11)),
      ],
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.date,
    required this.inMonth,
    required this.isSelected,
    required this.hasTask,
    required this.hasEvent,
    required this.holiday,
    required this.term,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool isSelected;
  final bool hasTask;
  final bool hasEvent;
  final Holiday? holiday;
  final Holiday? term;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isToday = AppDateUtils.isToday(date);
    final bool isRed = holiday != null || date.weekday == DateTime.sunday;
    Color numberColor = isRed
        ? AppColors.priorityHighText
        : (weekendColor(date) ?? AppColors.textBody);
    if (!inMonth) numberColor = AppColors.textFaint.withOpacity(0.6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        height: 52,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.16) : (isToday ? AppColors.todayTint : null),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: isSelected ? Border.all(color: AppColors.accent, width: 1.2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: AppTextStyles.body(
                fontSize: 14,
                weight: isToday || isSelected ? FontWeight.w800 : FontWeight.w600,
                color: numberColor,
              ),
            ),
            SizedBox(
              height: 11,
              child: (holiday ?? term) != null && inMonth
                  ? Text(
                      (holiday ?? term)!.name,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: AppTextStyles.meta(
                        fontSize: 7.5,
                        color: holiday != null ? AppColors.priorityHighText : AppColors.accent,
                      ),
                    )
                  : null,
            ),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasTask) _dot(AppColors.accent),
                  if (hasEvent) _dot(AppColors.categoryHome),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

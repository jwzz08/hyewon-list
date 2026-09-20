import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/task.dart';
import '../../../shared/widgets/components/progress_ring.dart';
import '../../calendar/application/calendar_providers.dart';
import '../../settings/application/settings_providers.dart';
import '../../tasks/application/task_providers.dart';
import 'mobile_common.dart';

/// The day selected on the Week tab (any time of day; only the date matters).
final StateProvider<DateTime> mobileWeekDayProvider =
    StateProvider<DateTime>((ref) => AppDateUtils.dateOnly(DateTime.now()));

/// "Week" tab: 7-day strip to pick a day, a week progress card, and the
/// selected day's to-dos and schedule.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime selected = ref.watch(mobileWeekDayProvider);
    final int startDay = ref.watch(startDayOfWeekProvider);
    final DateTime weekStart = AppDateUtils.startOfWeek(selected, startDayOfWeek: startDay);
    final List<DateTime> days = [for (int i = 0; i < 7; i++) weekStart.add(Duration(days: i))];
    final DateTime weekEnd = days.last;

    final List<Task> weekTasks =
        ref.watch(tasksInRangeProvider((weekStart, dayRange(weekEnd).$2))).value ?? const <Task>[];
    final List<CalendarEventOccurrence> weekEvents = ref
            .watch(calendarOccurrencesInRangeProvider((weekStart, dayRange(weekEnd).$2)))
            .value ??
        const <CalendarEventOccurrence>[];
    final int done = weekTasks.where((t) => t.isCompleted).length;
    final int overdue = ref.watch(overdueTasksProvider).value?.length ?? 0;

    void shift(int weeks) => ref.read(mobileWeekDayProvider.notifier).state =
        AppDateUtils.dateOnly(selected.add(Duration(days: 7 * weeks)));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            children: [
              _RoundIconButton(icon: Icons.chevron_left_rounded, onTap: () => shift(-1)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      AppDateUtils.formatWeekRange(weekStart),
                      style: AppTextStyles.display(fontSize: 17),
                    ),
                    Text(
                      AppDateUtils.isSameDay(
                                  AppDateUtils.startOfWeek(DateTime.now(), startDayOfWeek: startDay),
                                  weekStart)
                              ? 'This week'
                              : '${weekStart.year}',
                      style: AppTextStyles.meta(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              _RoundIconButton(icon: Icons.chevron_right_rounded, onTap: () => shift(1)),
            ],
          ),
          const SizedBox(height: 12),
          MobileCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Row(
              children: [
                for (final DateTime d in days)
                  Expanded(
                    child: _DayCell(
                      day: d,
                      selected: AppDateUtils.isSameDay(d, selected),
                      onTap: () => ref.read(mobileWeekDayProvider.notifier).state = d,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MobileCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ProgressRing(
                  progress: weekTasks.isEmpty ? 0 : done / weekTasks.length,
                  size: 44,
                  strokeWidth: 5,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$done of ${weekTasks.length} tasks done',
                        style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w800),
                      ),
                      Text(
                        '${weekEvents.length} events this week${overdue > 0 ? ' · $overdue overdue' : ''}',
                        style: AppTextStyles.meta(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AppDateUtils.weekdayShortLabels[selected.weekday - 1]}, '
                  '${AppDateUtils.formatShortDate(selected)}',
                  style: AppTextStyles.display(fontSize: 18, color: weekendColor(selected)),
                ),
              ),
              if (AppDateUtils.isToday(selected)) Text('Today', style: AppTextStyles.meta(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          DayItems(day: selected),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

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

class _DayCell extends ConsumerWidget {
  const _DayCell({required this.day, required this.selected, required this.onTap});

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = dayRange(day);
    final int tasks = ref.watch(tasksInRangeProvider(range)).value?.length ?? 0;
    final int events = ref.watch(calendarOccurrencesInRangeProvider(range)).value?.length ?? 0;
    final int dots = (tasks + events).clamp(0, 3);
    final Color? weekend = weekendColor(day);
    final Color fg = selected ? Colors.white : (weekend ?? AppColors.textBody);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : null,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppDateUtils.weekdayShortLabels[day.weekday - 1].substring(0, 1),
              style: AppTextStyles.body(
                fontSize: 10.5,
                weight: FontWeight.w800,
                color: selected ? Colors.white70 : (weekend ?? AppColors.textFaint),
              ),
            ),
            Text('${day.day}', style: AppTextStyles.display(fontSize: 17, color: fg)),
            const SizedBox(height: 2),
            SizedBox(
              height: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < dots; i++)
                    Container(
                      width: 3,
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.white70 : AppColors.textFaint,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

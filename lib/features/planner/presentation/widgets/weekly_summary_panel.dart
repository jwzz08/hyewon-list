import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../domain/models/task.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../application/planner_providers.dart';

/// Left sidebar of the weekly planner: week progress ring, "needs
/// attention" (overdue + upcoming deadlines), a 7-day overview, and an
/// event-count summary. Compact but information-dense, per spec section 5.
class WeeklySummaryPanel extends ConsumerStatefulWidget {
  const WeeklySummaryPanel({super.key});

  @override
  ConsumerState<WeeklySummaryPanel> createState() => _WeeklySummaryPanelState();
}

class _WeeklySummaryPanelState extends ConsumerState<WeeklySummaryPanel> {
  // Both sections start collapsed (just the count/pill) — tapping expands
  // them to show the actual items, per the product request that a bare
  // count isn't actionable on its own.
  bool _overdueExpanded = false;
  bool _eventsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<WeeklySummary> summaryAsync = ref.watch(weeklySummaryProvider);
    final DateTime? focusedDay = ref.watch(focusedDayProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Could not load summary', style: AppTextStyles.meta())),
      data: (summary) => SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week of ${AppDateUtils.formatWeekRange(summary.weekStart)}',
                    style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ProgressRing(progress: summary.progress, size: 52, strokeWidth: 6),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${summary.completedCount}/${summary.totalCount} tasks complete',
                          style: AppTextStyles.meta(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEEDS ATTENTION', style: AppTextStyles.sectionLabel()),
                  const SizedBox(height: 10),
                  if (summary.overdueCount == 0 && summary.upcomingDeadlines.isEmpty)
                    Text('Nothing urgent this week', style: AppTextStyles.meta())
                  else ...[
                    if (summary.overdueCount > 0) ...[
                      _AttentionPill(
                        label: '${summary.overdueCount} overdue',
                        color: AppColors.priorityHighText,
                        tint: AppColors.priorityHighTint,
                        trailingIcon: _overdueExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        onTap: () => setState(() => _overdueExpanded = !_overdueExpanded),
                      ),
                      if (_overdueExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: summary.overdueTasks
                                .map((Task t) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '• ${t.title}',
                                        style: AppTextStyles.meta(
                                          fontSize: 10.5,
                                          color: AppColors.priorityHighText,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                    ...summary.upcomingDeadlines.map(
                      (Task t) => _AttentionPill(
                        label: t.title,
                        color: AppColors.priorityMediumText,
                        tint: AppColors.priorityMediumTint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OVERVIEW', style: AppTextStyles.sectionLabel()),
                  const SizedBox(height: 10),
                  ...List.generate(7, (i) {
                    final DateTime day = summary.weekStart.add(Duration(days: i));
                    final List<Task> dayTasks = summary.tasksByDay[i];
                    final int done = dayTasks.where((t) => t.isCompleted).length;
                    final double ratio = dayTasks.isEmpty ? 0 : done / dayTasks.length;
                    final bool isFocused =
                        focusedDay != null && AppDateUtils.isSameDay(focusedDay, day);
                    return _DayOverviewRow(
                      day: day,
                      ratio: ratio,
                      count: dayTasks.length,
                      focused: isFocused,
                      onTap: () => ref.read(focusedDayProvider.notifier).state = day,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: summary.weekEvents.isEmpty
                        ? null
                        : () => setState(() => _eventsExpanded = !_eventsExpanded),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 15, color: AppColors.categoryWork),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${summary.eventCount} events this week',
                              style: AppTextStyles.meta()),
                        ),
                        if (summary.weekEvents.isNotEmpty)
                          Icon(
                            _eventsExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                            color: AppColors.textFaint,
                          ),
                      ],
                    ),
                  ),
                  if (_eventsExpanded && summary.weekEvents.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...summary.weekEvents.map((CalendarEventOccurrence o) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 34,
                                child: Text(
                                  AppDateUtils.weekdayShortLabels[
                                      o.occurrenceStart.weekday - 1],
                                  style: AppTextStyles.meta(
                                      fontSize: 10, color: AppColors.textFaint),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  o.sourceEvent.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.meta(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: child,
      );
}

class _AttentionPill extends StatelessWidget {
  const _AttentionPill({
    required this.label,
    required this.color,
    required this.tint,
    this.onTap,
    this.trailingIcon,
  });

  final String label;
  final Color color;
  final Color tint;

  /// Non-null turns this into the expandable "N overdue" pill — see
  /// WeeklySummaryPanel's `_overdueExpanded` state.
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.meta(color: color),
          ),
        ),
        if (trailingIcon != null) Icon(trailingIcon, size: 14, color: color),
      ],
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(AppRadii.sm)),
      child: onTap == null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: content,
            )
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: content,
              ),
            ),
    );
  }
}

class _DayOverviewRow extends StatelessWidget {
  const _DayOverviewRow({
    required this.day,
    required this.ratio,
    required this.count,
    required this.focused,
    required this.onTap,
  });

  final DateTime day;
  final double ratio;
  final int count;
  final bool focused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: focused ? AppColors.accentTint : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                AppDateUtils.weekdayShortLabels[day.weekday - 1].substring(0, 1),
                style: AppTextStyles.meta(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 5,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 18,
              child: Text('$count', textAlign: TextAlign.right, style: AppTextStyles.meta(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

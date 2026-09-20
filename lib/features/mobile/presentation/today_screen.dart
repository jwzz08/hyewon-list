import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/sync_status.dart';
import '../../../domain/models/task.dart';
import '../../../shared/widgets/components/progress_ring.dart';
import '../../calendar/application/calendar_providers.dart';
import '../../tasks/application/task_providers.dart';
import 'mobile_common.dart';

const List<String> _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// "Today" tab: date header, progress summary, overdue, today's to-dos,
/// next event, undated memos, and a quick-add bar.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final TextEditingController _quickAdd = TextEditingController();

  @override
  void dispose() {
    _quickAdd.dispose();
    super.dispose();
  }

  Future<void> _submitQuickAdd() async {
    final String title = _quickAdd.text.trim();
    if (title.isEmpty) return;
    _quickAdd.clear();
    await ref.read(taskActionsProvider).createQuickTask(
          title,
          dueDate: AppDateUtils.dateOnly(DateTime.now()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final range = dayRange(now);
    final List<Task> todayTasks = ref.watch(tasksInRangeProvider(range)).value ?? const <Task>[];
    final List<Task> overdue = ref.watch(overdueTasksProvider).value ?? const <Task>[];
    final List<Task> undated = (ref.watch(undatedTasksProvider).value ?? const <Task>[]);
    final CalendarEventOccurrence? next = ref.watch(nextUpcomingEventProvider).value;
    final List<CalendarEventOccurrence> todayEvents =
        ref.watch(calendarOccurrencesInRangeProvider(range)).value ?? const <CalendarEventOccurrence>[];

    final int done = todayTasks.where((t) => t.isCompleted).length;
    final int total = todayTasks.length;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TODAY', style: AppTextStyles.eyebrow(color: AppColors.textSecondary)),
                          Text(
                            _weekdayNames[now.weekday - 1],
                            style: AppTextStyles.display(fontSize: 36),
                          ),
                          Text(
                            '${AppDateUtils.monthLabels[now.month - 1]} ${now.day}',
                            style: AppTextStyles.body(fontSize: 15, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const _SyncPill(),
                  ],
                ),
                const SizedBox(height: 14),
                _SummaryCard(done: done, total: total, overdueCount: overdue.length),
                if (overdue.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final Task t in overdue)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MobileCard(
                        color: AppColors.priorityHighTint,
                        borderColor: AppColors.priorityHigh.withOpacity(0.25),
                        child: MobileTaskTile(task: t, showDueDate: true),
                      ),
                    ),
                ],
                if (todayTasks.isNotEmpty) ...[
                  const MobileSectionLabel('To-do'),
                  MobileTaskList(tasks: todayTasks),
                ],
                if (todayEvents.isNotEmpty) ...[
                  const MobileSectionLabel('Schedule'),
                  for (final CalendarEventOccurrence o in todayEvents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MobileEventTile(occurrence: o),
                    ),
                ] else if (next != null) ...[
                  const MobileSectionLabel('Next up'),
                  MobileEventTile(occurrence: next),
                ],
                if (todayTasks.isEmpty && todayEvents.isEmpty && overdue.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text('Nothing planned for today', style: AppTextStyles.meta(fontSize: 13)),
                    ),
                  ),
                if (undated.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  const MobileSectionLabel('Memo'),
                  MobileTaskList(tasks: undated),
                ],
              ],
            ),
          ),
          _QuickAddBar(controller: _quickAdd, onSubmit: _submitQuickAdd),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.done, required this.total, required this.overdueCount});

  final int done;
  final int total;
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    final int left = total - done;
    return MobileCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ProgressRing(
            progress: total == 0 ? 0 : done / total,
            size: 60,
            strokeWidth: 6,
            centerLabel: Text('$done/$total', style: AppTextStyles.display(fontSize: 14)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$done of $total done', style: AppTextStyles.body(fontSize: 15, weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.meta(fontSize: 12.5),
                    children: [
                      TextSpan(text: '$left left'),
                      if (overdueCount > 0) ...[
                        const TextSpan(text: ' · '),
                        TextSpan(
                          text: '$overdueCount overdue',
                          style: TextStyle(color: AppColors.priorityHighText, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncPill extends ConsumerWidget {
  const _SyncPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<SyncStatus>(
      stream: ref.watch(syncRepositoryProvider).watchStatus(),
      initialData: SyncStatus.initial,
      builder: (context, snapshot) {
        final SyncStatus status = snapshot.data ?? SyncStatus.initial;
        final (IconData icon, String label, Color color) = switch (status.state) {
          SyncState.syncing => (Icons.sync_rounded, 'Syncing', AppColors.accent),
          SyncState.error => (Icons.cloud_off_rounded, 'Sync error', AppColors.priorityHigh),
          SyncState.offline => (Icons.cloud_off_rounded, 'Offline', AppColors.textFaint),
          _ => (Icons.cloud_done_outlined, 'Synced', AppColors.categoryHome),
        };
        return Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.body(fontSize: 12.5, weight: FontWeight.w700, color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAddBar extends StatelessWidget {
  const _QuickAddBar({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 14, right: 4),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.add_rounded, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                style: AppTextStyles.body(fontSize: 14),
                decoration: InputDecoration(
                  filled: false,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'New task',
                  hintStyle: AppTextStyles.body(fontSize: 14, color: AppColors.textFaint),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Add',
              onPressed: onSubmit,
              icon: Icon(Icons.arrow_upward_rounded, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/components/add_item_dialog.dart';
import '../../../tasks/application/task_providers.dart';
import '../../application/planner_providers.dart';

/// The weekly planner's composer bar: text input + 7 day-letter chips to
/// pick the target day + an "Add" button. The "+" button opens the full
/// [AddItemDialog] (To-do or Schedule, with full detail) pre-filled with
/// whatever was typed and the currently-selected day chip — pressing Enter
/// in the text field is the separate fast path (a plain quick-add task,
/// no dialog).
class QuickAddBar extends ConsumerStatefulWidget {
  const QuickAddBar({super.key});

  @override
  ConsumerState<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends ConsumerState<QuickAddBar> {
  final TextEditingController _controller = TextEditingController();
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default to *today's* column instead of always index 0 (Monday, or
    // whatever the week's first day is) — index 0 only made sense as a
    // placeholder; today is the day someone opening the planner is almost
    // always adding something for. Computed once here (not on every build)
    // so it doesn't fight with a day chip the user has since tapped
    // themselves — see the focusedDayProvider sync in build() below, which
    // still takes priority whenever it's set.
    final DateTime weekStart = ref.read(weekStartProvider);
    final int todayIdx = AppDateUtils.dateOnly(DateTime.now()).difference(weekStart).inDays;
    if (todayIdx >= 0 && todayIdx < 7) _selectedDayIndex = todayIdx;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime weekStart = ref.watch(weekStartProvider);
    final DateTime? focusedDay = ref.watch(focusedDayProvider);
    if (focusedDay != null) {
      final int idx = focusedDay.difference(weekStart).inDays;
      if (idx >= 0 && idx < 7) _selectedDayIndex = idx;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(weekStart),
              decoration: const InputDecoration(
                hintText: 'Add a task…',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyles.body(fontSize: 13),
            ),
          ),
          const SizedBox(width: 4),
          ...List.generate(7, (i) {
            final DateTime day = weekStart.add(Duration(days: i));
            final bool selected = i == _selectedDayIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedDayIndex = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 19,
                height: 19,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.bgNeutral,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  AppDateUtils.weekdayShortLabels[day.weekday - 1].substring(0, 1),
                  style: AppTextStyles.meta(
                    fontSize: 8.5,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 6),
          SizedBox(
            width: 30,
            height: 30,
            child: ElevatedButton(
              // Used to just duplicate what Enter already does (a plain
              // quick-add task) — now opens the same full To-do/Schedule
              // dialog the removed tune button used to, pre-filled with
              // whatever's already typed and the selected day chip, so it's
              // the "I want the full options" path and Enter stays the fast
              // one-line path.
              onPressed: () => _openFullDialog(weekStart),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(DateTime weekStart) {
    final String title = _controller.text.trim();
    if (title.isEmpty) return;
    final DateTime targetDay = weekStart.add(Duration(days: _selectedDayIndex));
    ref.read(taskActionsProvider).createQuickTask(title, dueDate: targetDay);
    _controller.clear();
  }

  void _openFullDialog(DateTime weekStart) {
    final String typed = _controller.text.trim();
    showAddItemDialog(
      context,
      initialDate: weekStart.add(Duration(days: _selectedDayIndex)),
      initialTitle: typed.isEmpty ? null : typed,
    );
    _controller.clear();
  }
}

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
/// pick the target day + an "Add" button. The inline row stays a fast
/// *task*-only path (one line has no room for event time fields) — the
/// tune icon next to "Add" opens the full [AddItemDialog] so a To-do or
/// Schedule with full detail can be created from this bar too, on the
/// currently-selected day chip.
class QuickAddBar extends ConsumerStatefulWidget {
  const QuickAddBar({super.key});

  @override
  ConsumerState<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends ConsumerState<QuickAddBar> {
  final TextEditingController _controller = TextEditingController();
  int _selectedDayIndex = 0;

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
              onPressed: () => _submit(weekStart),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Icon(Icons.add, size: 16),
            ),
          ),
          // Previously a bare GestureDetector around just a 15px icon with
          // 6px of left padding only — a ~21x15px hit target that was easy
          // to miss with a mouse and read as "doesn't respond to clicks".
          // InkWell + generous padding on all sides gives a much larger,
          // visually-confirmed (splash/highlight) tap target instead.
          InkWell(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            onTap: () => showAddItemDialog(
              context,
              initialDate: weekStart.add(Duration(days: _selectedDayIndex)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.tune, size: 16, color: AppColors.textFaint),
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
}

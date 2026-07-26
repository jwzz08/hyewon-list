import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../application/widget_mode_providers.dart';

/// 7 vertical bars showing each weekday's task-completion percentage — the
/// "large" widget tier's week-at-a-glance strip (>= 640px wide).
class WeekBarChart extends ConsumerWidget {
  const WeekBarChart({super.key});

  static const double _maxBarHeight = 34;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<double> ratios =
        ref.watch(weekCompletionRatiosProvider).value ?? List.filled(7, 0.0);

    return SizedBox(
      // Bar (up to _maxBarHeight, reached when a day's completion ratio
      // nears 1.0 — e.g. right after checking off today's last task) +
      // spacing(4) + the weekday-letter label's own line height. 16px of
      // headroom for that label was cutting it too close — Nunito's line
      // height at fontSize 9 comes out slightly taller than 12px once
      // rendered, so a maxed-out bar reliably overflowed by ~1px. 20px
      // leaves real margin instead of being tuned to the exact pixel.
      height: _maxBarHeight + 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final double ratio = ratios[i].clamp(0.0, 1.0);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: (_maxBarHeight * ratio).clamp(3, _maxBarHeight),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: ratio > 0 ? AppColors.accent : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.weekdayShortLabels[i].substring(0, 1),
                  // Both Saturday and Sunday's short label start with "S" —
                  // color-code them (Sat blue, Sun red, matching the
                  // conventional calendar weekend color scheme) so they're
                  // distinguishable at a glance instead of reading as the
                  // same letter twice. Indices are fixed Mon=0..Sun=6 (this
                  // chart doesn't follow the configurable start-of-week
                  // setting), so index 5 is always Sat and 6 is always Sun.
                  style: AppTextStyles.meta(
                    fontSize: 9,
                    color: i == 5
                        ? Colors.blue.shade600
                        : i == 6
                            ? Colors.red.shade600
                            : null,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

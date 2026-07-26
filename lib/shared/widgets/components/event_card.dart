import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/calendar_event.dart';

/// Visually distinct from [TaskRow] on purpose — no checkbox (events aren't
/// completable), a left color-accent stripe instead of a priority dot, and
/// a tinted background instead of a plain white row.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.color,
    this.onTap,
    this.dense = false,
    this.titleMaxLines = 1,
  });

  final CalendarEvent event;
  final Color? color;
  final VoidCallback? onTap;
  final bool dense;

  /// See TaskRow.titleMaxLines — same reasoning, WeeklyScheduleSection
  /// passes 2 so long event titles wrap instead of truncating immediately.
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        color ?? (event.color != null ? Color(event.color!) : AppColors.categoryWork);
    final String timeLabel = event.isAllDay
        ? 'All day'
        : AppDateUtils.formatTimeOfDay(event.startDateTime.hour, event.startDateTime.minute);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 6 : 8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border(left: BorderSide(color: accentColor, width: 2.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (event.isRecurring) ...[
                  Icon(Icons.repeat, size: 11, color: accentColor.withOpacity(0.65)),
                  const SizedBox(width: 3),
                ],
                Expanded(
                  child: Text(
                    event.title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      fontSize: dense ? 11 : 12,
                      weight: FontWeight.w700,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(timeLabel, style: AppTextStyles.meta(fontSize: 9.5)),
          ],
        ),
      ),
    );
  }
}

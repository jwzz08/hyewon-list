import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/calendar_event.dart';
import '../../../../shared/widgets/components/event_card.dart';

/// The "Schedule" half of a [WeeklyDayColumn] — personal calendar events
/// only, rendered with [EventCard] (never [TaskRow]). See
/// [WeeklyTaskSection] for why these stay separate components.
///
/// Each card is wrapped in `Draggable<CalendarEventOccurrence>` (see
/// [WeeklyDayColumn]'s `DragTarget<Object>`) so an event can be dragged onto
/// a different day — recurring events are intercepted with a scope picker
/// before the move actually applies (see `_handleEventDrop` there).
class WeeklyScheduleSection extends StatelessWidget {
  const WeeklyScheduleSection({
    super.key,
    required this.occurrences,
    this.onTap,
    this.titleMaxLines = 1,
  });

  final List<CalendarEventOccurrence> occurrences;
  final void Function(CalendarEventOccurrence occurrence)? onTap;

  /// See EventCard.titleMaxLines — WeeklyDayColumn passes 2, same reasoning
  /// as WeeklyTaskSection.
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: AppColors.categoryWork, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text('SCHEDULE', style: AppTextStyles.sectionLabel()),
          ],
        ),
        const SizedBox(height: 6),
        if (occurrences.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('No events', style: AppTextStyles.meta(fontSize: 10)),
          )
        else
          ...occurrences.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Draggable<CalendarEventOccurrence>(
                data: o,
                feedback: Opacity(
                  opacity: 0.35,
                  child: SizedBox(
                    width: 150,
                    child: Material(
                      color: Colors.transparent,
                      child: EventCard(event: o.sourceEvent, dense: true),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: EventCard(event: o.sourceEvent, dense: true),
                ),
                child: EventCard(
                  event: o.sourceEvent,
                  dense: true,
                  titleMaxLines: titleMaxLines,
                  onTap: onTap == null ? null : () => onTap!(o),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

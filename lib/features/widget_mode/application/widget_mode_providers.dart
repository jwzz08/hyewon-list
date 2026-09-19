import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/task.dart';
import '../../tasks/application/task_providers.dart';

/// The fluid width tiers the desktop widget reflows through (see
/// core/constants/app_dimens.dart for the breakpoints). The single-line
/// "mini" tier that used to exist below 300px was removed — see
/// WidgetTierBreakpoints' doc comment — so `compact` is now the smallest.
enum WidgetTier { compact, expanded, expandedWithWeekBar }

/// Updated by the root shell whenever the OS reports a resize (see
/// WindowService.onResize) — every widget-mode view reads this instead of
/// `MediaQuery` directly so it works identically whether driven by the real
/// OS window or (in tests) by a fake size.
final StateProvider<Size> currentWindowSizeProvider =
    StateProvider<Size>((ref) => const Size(360, 480));

/// The window size captured right before the user last tapped the small
/// widget's "expand" button (see _ExpandButton in widget_screen.dart) — lets
/// the nav-chrome shell's "shrink back to widget" button (see
/// _ShrinkToWidgetButton in custom_window_title_bar.dart) restore the exact
/// size the widget was left at, rather than jumping to some arbitrary fixed
/// size. Deliberately in-memory only (not persisted to WidgetPreference):
/// WidgetPreference.windowWidth/windowHeight already track "current window
/// size right now" for whatever mode is showing, which is overwritten by
/// every nav-chrome resize too, so it can't double as "the last *widget*
/// size" — falls back to WidgetPreference's own 360x480 default when null
/// (i.e. the user never actually shrunk from a widget this session).
final StateProvider<Size?> lastWidgetSizeProvider = StateProvider<Size?>((ref) => null);

/// Same idea as [lastWidgetSizeProvider], for the window's on-screen
/// position. Without this, the widget's spot on screen could drift every
/// time it was expanded and shrunk back — `WindowService.setSize` isn't
/// guaranteed to leave the window's top-left corner exactly where it was
/// (a `Lock position` toggle only blocks *manual* dragging, via
/// `setMovable`; it does nothing to protect against a resize call moving
/// things). Explicitly capturing the position right before expanding and
/// restoring it right after shrinking back (see `_ExpandButton`/
/// `_ShrinkToWidgetButton`) pins the widget to one spot across that
/// round-trip regardless of what the OS/window_manager did internally.
final StateProvider<Offset?> lastWidgetPositionProvider = StateProvider<Offset?>((ref) => null);

final Provider<WidgetTier> widgetTierProvider = Provider<WidgetTier>((ref) {
  final double width = ref.watch(currentWindowSizeProvider).width;
  if (width < WidgetTierBreakpoints.compactMax) return WidgetTier.compact;
  if (width < WidgetTierBreakpoints.expandedMax) return WidgetTier.expanded;
  return WidgetTier.expandedWithWeekBar;
});

/// Ticks every 30s so the widget's clock / "today" computations stay fresh
/// without a full rebuild loop.
final StreamProvider<DateTime> currentTimeProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

class TodayProgress {
  const TodayProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  double get ratio => total == 0 ? 0 : completed / total;
}

/// Per-weekday completion ratio (0.0-1.0) for the current week — powers the
/// "large" widget tier's 7-bar week-at-a-glance strip.
final Provider<AsyncValue<List<double>>> weekCompletionRatiosProvider =
    Provider<AsyncValue<List<double>>>((ref) {
  final DateTime now = DateTime.now();
  final DateTime start = AppDateUtils.startOfWeek(now);
  final DateTime end = start.add(const Duration(days: 6));
  final AsyncValue<List<Task>> tasksAsync = ref.watch(tasksInRangeProvider((start, end)));
  return tasksAsync.whenData((tasks) {
    return List<double>.generate(7, (i) {
      final DateTime day = start.add(Duration(days: i));
      final List<Task> dayTasks =
          tasks.where((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, day)).toList();
      if (dayTasks.isEmpty) return 0.0;
      final int done = dayTasks.where((t) => t.isCompleted).length;
      return done / dayTasks.length;
    });
  });
});

final Provider<AsyncValue<TodayProgress>> todayProgressProvider =
    Provider<AsyncValue<TodayProgress>>((ref) {
  final AsyncValue<List<Task>> tasksAsync = ref.watch(todayTasksProvider);
  return tasksAsync.whenData(
    (tasks) => TodayProgress(
      completed: tasks.where((t) => t.isCompleted).length,
      total: tasks.length,
    ),
  );
});

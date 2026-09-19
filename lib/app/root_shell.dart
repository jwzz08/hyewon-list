import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../domain/models/calendar_event.dart';
import '../domain/models/task.dart';
import '../domain/models/widget_mode.dart';
import '../domain/models/widget_preference.dart';
import '../features/calendar/application/month_providers.dart';
import '../features/calendar/presentation/screens/monthly_calendar_screen.dart';
import '../features/planner/application/planner_providers.dart';
import '../features/planner/presentation/screens/weekly_planner_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/application/settings_providers.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tasks/application/task_providers.dart';
import '../features/widget_mode/application/widget_mode_providers.dart';
import '../features/widget_mode/presentation/screens/widget_screen.dart';
import '../platform/window/window_service.dart';
import '../shared/widgets/components/add_item_dialog.dart';
import '../shared/widgets/components/custom_window_title_bar.dart';
import '../shared/widgets/layouts/nav_rail.dart';
import 'providers.dart';

/// Decides between the chromeless [WidgetScreen] and the full nav-rail app
/// shell purely based on window width (see AppBreakpoints.plannerMin) —
/// there is no separate "mode switch" the user has to find, resizing the
/// window IS the mode switch, matching the design mockup's fluid continuum.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  StreamSubscription<Size>? _resizeSub;
  StreamSubscription<Offset>? _moveSub;
  ProviderSubscription<String?>? _pendingTaskSub;
  ProviderSubscription<String?>? _pendingEventSub;
  ProviderSubscription<AsyncValue<List<Task>>>? _overdueSub;

  /// Debounces DB writes from a live resize/move drag — see
  /// [_scheduleGeometryPersist] for why this exists.
  Timer? _geometryDebounce;
  Size? _pendingSize;
  Offset? _pendingPosition;

  /// Keeps recurring events' reminder windows rolling forward — see
  /// [ReminderScheduler.resyncRecurringReminders].
  Timer? _reminderResyncTimer;
  static const Duration _reminderResyncInterval = Duration(hours: 12);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _wireWindowListeners());
    _wireNotificationTapListeners();
    _wireTrayTooltipListener();
    _wireReminderResync();
  }

  /// Runs once immediately (covers "app was closed longer than the
  /// lookahead window, catch up now") and then every
  /// [_reminderResyncInterval] for as long as the app stays open — see
  /// [ReminderScheduler.resyncRecurringReminders] for why a recurring
  /// event's reminders would otherwise silently run dry after enough time
  /// passes without the user ever editing that event again.
  void _wireReminderResync() {
    _resyncRecurringReminders();
    _reminderResyncTimer = Timer.periodic(
      _reminderResyncInterval,
      (_) => _resyncRecurringReminders(),
    );
  }

  Future<void> _resyncRecurringReminders() async {
    final List<CalendarEvent> events =
        await ref.read(calendarEventRepositoryProvider).watchAll().first;
    if (!mounted) return;
    await ref.read(reminderSchedulerProvider).resyncRecurringReminders(events);
  }

  /// Keeps the tray icon's hover tooltip reflecting live app state (overdue
  /// task count) — a lightweight, safe stand-in for a true "dynamic per-state
  /// icon" (which would need new icon art, not just code) or tray balloon
  /// notifications (deliberately not built at all — `tray_manager` has no
  /// balloon API, and Windows already renders `Shell_NotifyIcon` balloons as
  /// toast notifications, which `flutter_local_notifications` already shows
  /// for every reminder; see ARCHITECTURE.md §7).
  void _wireTrayTooltipListener() {
    _overdueSub = ref.listenManual<AsyncValue<List<Task>>>(overdueTasksProvider, (previous, next) {
      final int? count = next.value?.length;
      if (count == null) return;
      final String tooltip = count > 0 ? 'hyewon_list — $count overdue' : 'hyewon_list';
      ref.read(trayServiceProvider).setToolTip(tooltip);
    });
  }

  /// Reacts to `pendingOpenTaskIdProvider`/`pendingOpenEventIdProvider` (set
  /// by main.dart's NotificationService.onTapped listener when the user
  /// clicks a reminder toast — see providers.dart) by fetching the item,
  /// navigating the relevant screen's date state to it (see
  /// [_navigateToTaskDate]/[_navigateToEventDate]) so the item's actually
  /// visible in the grid behind the dialog rather than just floating over
  /// whatever date happened to already be showing, and opening it in
  /// AddItemDialog's edit mode. RootShell is always mounted regardless of
  /// which screen is showing (including chromeless widget mode, since
  /// showDialog works against the root Navigator either way), so this is
  /// the one place that can reliably catch the tap no matter what the user
  /// was looking at when the notification fired.
  void _wireNotificationTapListeners() {
    _pendingTaskSub = ref.listenManual<String?>(pendingOpenTaskIdProvider, (previous, next) async {
      if (next == null) return;
      ref.read(pendingOpenTaskIdProvider.notifier).state = null;
      final task = await ref.read(taskRepositoryProvider).getById(next);
      if (task != null && mounted) {
        _navigateToTaskDate(task);
        await showEditTaskDialog(context, task);
      }
    });
    _pendingEventSub = ref.listenManual<String?>(pendingOpenEventIdProvider, (previous, next) async {
      if (next == null) return;
      ref.read(pendingOpenEventIdProvider.notifier).state = null;
      // Set alongside the id above (see main.dart's onTapped listener) —
      // read and clear it here too so a later plain-event tap doesn't
      // accidentally reuse a stale date from a previous recurring one.
      final DateTime? occurrenceDate = ref.read(pendingOpenEventOccurrenceDateProvider);
      ref.read(pendingOpenEventOccurrenceDateProvider.notifier).state = null;
      final event = await ref.read(calendarEventRepositoryProvider).getById(next);
      if (event != null && mounted) {
        // For a recurring series, prefer the occurrence date the reminder
        // actually fired for (see pendingOpenEventOccurrenceDateProvider's
        // doc comment) over the series' own startDateTime — otherwise
        // editing "this occurrence" from the notification silently applied
        // to the wrong (usually long-past) date instead of the one shown in
        // the toast.
        final DateTime occStart = occurrenceDate ?? event.startDateTime;
        final DateTime occEnd = occurrenceDate == null
            ? event.endDateTime
            : occurrenceDate.add(event.duration);
        _navigateToEventDate(event, occurrenceDate: occurrenceDate);
        await showEditEventDialog(
          context,
          CalendarEventOccurrence(
            sourceEvent: event,
            occurrenceStart: occStart,
            occurrenceEnd: occEnd,
            isGeneratedRecurrence: occurrenceDate != null && event.isRecurring,
          ),
        );
      }
    });
  }

  /// Jumps the weekly planner to [task]'s due-date week and highlights that
  /// day (same providers `WeeklySummaryPanel`'s Overview list drives — see
  /// planner_providers.dart), so by the time `showEditTaskDialog` opens over
  /// it, the planner behind the dialog already shows the right day instead
  /// of whatever week the user happened to have open. No-ops for a task
  /// with no due date — there's no day to jump to.
  void _navigateToTaskDate(Task task) {
    final DateTime? dueDate = task.dueDate;
    if (dueDate == null) return;
    ref.read(selectedWeekAnchorProvider.notifier).state = dueDate;
    ref.read(focusedDayProvider.notifier).state = dueDate;
  }

  /// Same idea as [_navigateToTaskDate], for the month view (see
  /// month_providers.dart). [occurrenceDate] — the actual occurrence a
  /// recurring event's reminder fired for, when known (see
  /// pendingOpenEventOccurrenceDateProvider) — is preferred over
  /// [CalendarEvent.startDateTime], which for a recurring series is only
  /// ever the *first* occurrence's date.
  void _navigateToEventDate(CalendarEvent event, {DateTime? occurrenceDate}) {
    final DateTime date = occurrenceDate ?? event.startDateTime;
    ref.read(selectedMonthAnchorProvider.notifier).state = date;
    ref.read(selectedDateProvider.notifier).state = date;
  }

  void _wireWindowListeners() {
    final WindowService windowService = ref.read(windowServiceProvider);
    _resizeSub = windowService.onResize.listen((size) {
      ref.read(currentWindowSizeProvider.notifier).state = size;
      _scheduleGeometryPersist(size: size);
    });
    _moveSub = windowService.onMove.listen((position) {
      _scheduleGeometryPersist(position: position);
    });
  }

  /// `WindowService.onResize`/`onMove` fire on *every* frame of a live
  /// drag — often 60+ times/sec — and each one used to call
  /// [_persistGeometry] directly, which is a real SQLite write via
  /// `WidgetPreferenceRepository`. Since `widgetPreferenceProvider` is a
  /// live-watched Stream consumed all over the app (WidgetScreen, Appearance
  /// settings, etc.), every single one
  /// of those writes also re-emitted and cascaded a rebuild through all of
  /// them — which is exactly what made dragging the resize handle (or
  /// moving the window) feel sluggish instead of smooth. Only the final
  /// size/position at the end of a drag actually needs to be saved, so
  /// this collapses a whole drag's worth of events into one write, fired
  /// after a short pause once the events stop arriving.
  void _scheduleGeometryPersist({Size? size, Offset? position}) {
    if (size != null) _pendingSize = size;
    if (position != null) _pendingPosition = position;
    _geometryDebounce?.cancel();
    _geometryDebounce = Timer(const Duration(milliseconds: 400), () {
      _persistGeometry(size: _pendingSize, position: _pendingPosition);
      _pendingSize = null;
      _pendingPosition = null;
    });
  }

  void _persistGeometry({Size? size, Offset? position}) {
    final WidgetPreference? pref = ref.read(widgetPreferenceProvider).value;
    if (pref == null) return;
    ref.read(settingsActionsProvider).saveWidgetPreference(pref.copyWith(
          windowWidth: size?.width ?? pref.windowWidth,
          windowHeight: size?.height ?? pref.windowHeight,
          windowX: position?.dx ?? pref.windowX,
          windowY: position?.dy ?? pref.windowY,
        ));
  }

  @override
  void dispose() {
    _resizeSub?.cancel();
    _moveSub?.cancel();
    _pendingTaskSub?.close();
    _pendingEventSub?.close();
    _overdueSub?.close();
    _geometryDebounce?.cancel();
    _reminderResyncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery is the ground truth for "how big is the window right now"
    // (the Flutter view always fills the native window on desktop) — sync
    // it into currentWindowSizeProvider after each frame so widgetTierProvider
    // and the nav-rail breakpoint below react immediately, even if the
    // WindowService.onResize stream lags a frame behind.
    final Size mediaSize = MediaQuery.sizeOf(context);
    final bool showNavChrome = mediaSize.width >= AppBreakpoints.plannerMin;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(currentWindowSizeProvider) != mediaSize) {
        ref.read(currentWindowSizeProvider.notifier).state = mediaSize;
      }
    });

    if (!showNavChrome) {
      return const WidgetScreen();
    }

    final AppScreen screen = ref.watch(currentAppScreenProvider);

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            () => ref.read(currentAppScreenProvider.notifier).state = AppScreen.search,
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            () => ref.read(currentAppScreenProvider.notifier).state = AppScreen.search,
      },
      child: Focus(
        autofocus: true,
        // The window is fully frameless (see WindowsWindowService.init —
        // setAsFrameless + titleBarStyle.hidden), so outside of widget mode
        // (which is sized via its own button — see _ExpandButton in
        // widget_screen.dart, not drag-resize) there was no way to resize
        // the window at all on the planner/month/settings/search tabs — no
        // OS border exists to drag. DragToResizeArea adds a thin invisible
        // strip along every edge that hands the drag off to window_manager's
        // native resize (the same OS resize loop a normal bordered window
        // uses), so it's as smooth as native resizing with no manual setSize
        // coalescing needed. Kept thinner than CustomWindowTitleBar's 36px
        // height so the very edge resizes while the rest of the title bar
        // still drags to move, matching normal window behavior.
        child: DragToResizeArea(
          resizeEdgeSize: 6,
          child: Scaffold(
            backgroundColor: AppColors.bgNeutral,
            body: Column(
              children: [
                const CustomWindowTitleBar(),
                Expanded(
                  child: Row(
                    children: [
                      NavRail(
                        selected: screen,
                        onSelect: (s) => ref.read(currentAppScreenProvider.notifier).state = s,
                      ),
                      Expanded(child: _buildScreen(screen)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.widget:
        // Full-size "widget mode" while the window is wide — shown inside
        // the app shell (with titlebar/nav) rather than borderless, since
        // going borderless only makes sense at the small OS-window sizes
        // already handled by the `!showNavChrome` branch above. No expand
        // button here (see WidgetScreen's 3-state sizing doc comment) — the
        // nav-chrome shell is already freely resizable via DragToResizeArea,
        // and a "jump to nav-chrome size" button would be meaningless once
        // already in the nav-chrome shell.
        return const WidgetScreen(showExpandButton: false);
      case AppScreen.planner:
        return const WeeklyPlannerScreen();
      case AppScreen.month:
        return const MonthlyCalendarScreen();
      case AppScreen.search:
        return const SearchScreen();
      case AppScreen.settings:
        return const SettingsScreen();
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../shared/widgets/components/add_item_dialog.dart';
import '../../calendar/application/month_providers.dart';
import '../../search/presentation/screens/search_screen.dart';
import 'mobile_calendar_screen.dart';
import 'mobile_settings_screen.dart';
import 'today_screen.dart';
import 'week_screen.dart';

enum MobileTab { today, week, month, search, settings }

final StateProvider<MobileTab> mobileTabProvider =
    StateProvider<MobileTab>((ref) => MobileTab.today);

/// iPhone/Android root: bottom NavigationBar (Today / Week / Month / Search
/// / Settings) plus an add FAB. Counterpart of the desktop `RootShell`.
class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({super.key});

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell> {
  ProviderSubscription<String?>? _pendingTaskSub;
  ProviderSubscription<String?>? _pendingEventSub;

  /// Keeps recurring events' reminder windows rolling forward — see
  /// [ReminderScheduler.resyncRecurringReminders].
  Timer? _reminderResyncTimer;
  static const Duration _reminderResyncInterval = Duration(hours: 12);

  @override
  void initState() {
    super.initState();
    _wireNotificationTapListeners();
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

  /// Same contract as RootShell: main.dart's tap listener stores the id in
  /// the pending* providers; consume it here and open the edit dialog.
  void _wireNotificationTapListeners() {
    _pendingTaskSub = ref.listenManual<String?>(pendingOpenTaskIdProvider, (previous, next) async {
      if (next == null) return;
      ref.read(pendingOpenTaskIdProvider.notifier).state = null;
      final task = await ref.read(taskRepositoryProvider).getById(next);
      if (task != null && mounted) {
        if (task.dueDate != null) ref.read(mobileWeekDayProvider.notifier).state = task.dueDate!;
        ref.read(mobileTabProvider.notifier).state = MobileTab.today;
        await showEditTaskDialog(context, task);
      }
    }, fireImmediately: true);
    _pendingEventSub = ref.listenManual<String?>(pendingOpenEventIdProvider, (previous, next) async {
      if (next == null) return;
      ref.read(pendingOpenEventIdProvider.notifier).state = null;
      final DateTime? occurrenceDate = ref.read(pendingOpenEventOccurrenceDateProvider);
      ref.read(pendingOpenEventOccurrenceDateProvider.notifier).state = null;
      final event = await ref.read(calendarEventRepositoryProvider).getById(next);
      if (event != null && mounted) {
        final DateTime occStart = occurrenceDate ?? event.startDateTime;
        final DateTime occEnd =
            occurrenceDate == null ? event.endDateTime : occurrenceDate.add(event.duration);
        ref.read(selectedMonthAnchorProvider.notifier).state = occStart;
        ref.read(selectedDateProvider.notifier).state = occStart;
        ref.read(mobileTabProvider.notifier).state = MobileTab.month;
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
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _pendingTaskSub?.close();
    _pendingEventSub?.close();
    _reminderResyncTimer?.cancel();
    super.dispose();
  }

  DateTime _defaultAddDate(MobileTab tab) {
    switch (tab) {
      case MobileTab.week:
        return ref.read(mobileWeekDayProvider);
      case MobileTab.month:
        return ref.read(selectedDateProvider) ?? DateTime.now();
      default:
        return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final MobileTab tab = ref.watch(mobileTabProvider);
    final bool showFab = tab == MobileTab.week || tab == MobileTab.month;

    return Scaffold(
      backgroundColor: AppColors.bgNeutral,
      body: IndexedStack(
        index: tab.index,
        children: const [
          TodayScreen(),
          WeekScreen(),
          MobileCalendarScreen(),
          _SearchTab(),
          MobileSettingsScreen(),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => showAddItemDialog(context, initialDate: _defaultAddDate(tab)),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.cardWhite,
        indicatorColor: AppColors.accentTint,
        selectedIndex: tab.index,
        onDestinationSelected: (i) => ref.read(mobileTabProvider.notifier).state = MobileTab.values[i],
        labelTextStyle: WidgetStatePropertyAll(AppTextStyles.body(fontSize: 11, weight: FontWeight.w700)),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded, color: AppColors.accentTextStrong),
            label: 'Today',
          ),
          NavigationDestination(
            icon: const Icon(Icons.view_week_outlined),
            selectedIcon: Icon(Icons.view_week_rounded, color: AppColors.accentTextStrong),
            label: 'Week',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.accentTextStrong),
            label: 'Month',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded, color: AppColors.accentTextStrong),
            label: 'Search',
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            selectedIcon: Icon(Icons.tune_rounded, color: AppColors.accentTextStrong),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Reuses the desktop [SearchScreen] as-is, just kept below the status bar.
class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColors.cardWhite,
        child: const SafeArea(bottom: false, child: SearchScreen()),
      );
}

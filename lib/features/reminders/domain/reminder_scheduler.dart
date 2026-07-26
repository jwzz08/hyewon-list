import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/task.dart';
import '../../../platform/notifications/notification_service.dart';
import '../../calendar/domain/recurring_event_service.dart';

/// Computes fire-times from `reminderMinutesBefore` on [Task]/[CalendarEvent]
/// and (de)schedules them via [NotificationService]. TaskActions and
/// CalendarEventActions call this after every create/update/delete/complete
/// so a reminder is never left pointing at stale data — see
/// ARCHITECTURE.md "Reminders".
///
/// This intentionally lives outside the repositories: repositories only
/// know about persistence, never about platform notification services.
///
/// Scope note: [CalendarEventOccurrence]s are computed on the fly by
/// [RecurringEventService] and never stored, so there's no way to schedule
/// *every* future occurrence of an indefinitely-repeating event up front.
/// Instead, [syncForEvent] schedules reminders for up to
/// [_maxRecurringReminders] upcoming occurrences within
/// [_recurringReminderLookahead] — comfortably more than a user will ever
/// need reminded of before the event naturally gets re-synced again (every
/// create/update call re-rolls the window forward). Tasks don't have a
/// recurrence concept in this app (see Task model), so [syncForTask] only
/// ever deals with a single fire time.
class ReminderScheduler {
  ReminderScheduler(this._notifications, [RecurringEventService? recurringEventService])
      : _recurringEventService = recurringEventService ?? const RecurringEventService();

  final NotificationService _notifications;
  final RecurringEventService _recurringEventService;

  /// Upper bound on how many upcoming occurrences of a recurring event get
  /// their own scheduled reminder at once — keeps a daily/weekly event from
  /// silently scheduling hundreds of native notifications years out.
  static const int _maxRecurringReminders = 20;

  /// How far into the future to look for occurrences to schedule reminders
  /// for. Re-synced (see class doc) every time the event is created/updated,
  /// so this window keeps rolling forward rather than ever needing to cover
  /// "forever" up front.
  static const Duration _recurringReminderLookahead = Duration(days: 60);

  static String _taskNotificationId(String taskId) => 'task_$taskId';
  static String _eventNotificationId(String eventId) => 'event_$eventId';

  /// Deterministic per-"slot" id (not per-date) so a resync can always find
  /// and overwrite/cancel exactly the same set of ids regardless of whether
  /// the underlying occurrence dates shifted (e.g. the user edited the
  /// recurrence rule) — see [_syncRecurringEventReminders].
  static String _eventSlotNotificationId(String eventId, int slot) => 'event_${eventId}_r$slot';

  /// Schedules (or cancels, if no longer applicable) the reminder for
  /// [task]. Call after create/update/setCompleted/moveToDate.
  Future<void> syncForTask(Task task) async {
    final String notificationId = _taskNotificationId(task.id);
    final DateTime? fireAt = _taskFireTime(task);
    if (fireAt == null || task.isCompleted || !fireAt.isAfter(DateTime.now())) {
      await _notifications.cancel(notificationId);
      return;
    }
    await _notifications.scheduleAt(
      id: notificationId,
      title: task.title,
      body: 'Task reminder',
      scheduledAt: fireAt,
      payload: 'task:${task.id}',
    );
  }

  Future<void> cancelForTask(String taskId) =>
      _notifications.cancel(_taskNotificationId(taskId));

  /// Schedules (or cancels) the reminder(s) for [event]. Call after
  /// create/update/moveToDateTime. Non-recurring events get a single
  /// reminder keyed by [_eventNotificationId]; recurring events fan out into
  /// up to [_maxRecurringReminders] slot-keyed reminders — see
  /// [_syncRecurringEventReminders].
  Future<void> syncForEvent(CalendarEvent event) async {
    if (!event.isRecurring) {
      // In case this event was just switched from recurring to
      // non-recurring, also clear any leftover slot-keyed reminders from
      // its previous life as a recurring series.
      await _cancelRecurringSlots(event.id);
      final String notificationId = _eventNotificationId(event.id);
      final DateTime? fireAt = _eventFireTime(event, event.startDateTime);
      if (fireAt == null || !fireAt.isAfter(DateTime.now())) {
        await _notifications.cancel(notificationId);
        return;
      }
      await _notifications.scheduleAt(
        id: notificationId,
        title: event.title,
        body: (event.location != null && event.location!.isNotEmpty)
            ? event.location
            : 'Upcoming event',
        scheduledAt: fireAt,
        payload: 'event:${event.id}',
      );
      return;
    }
    // In case this event was just switched from non-recurring to recurring,
    // also clear the single non-slot reminder from its previous life.
    await _notifications.cancel(_eventNotificationId(event.id));
    await _syncRecurringEventReminders(event);
  }

  Future<void> _syncRecurringEventReminders(CalendarEvent event) async {
    final int? minutesBefore = event.reminderMinutesBefore;
    if (minutesBefore == null) {
      await _cancelRecurringSlots(event.id);
      return;
    }

    final DateTime now = DateTime.now();
    final List<CalendarEventOccurrence> occurrences = _recurringEventService.generateOccurrences(
      event,
      now,
      now.add(_recurringReminderLookahead),
    );

    int scheduled = 0;
    for (final CalendarEventOccurrence occurrence in occurrences) {
      if (scheduled >= _maxRecurringReminders) break;
      final DateTime fireAt = occurrence.occurrenceStart.subtract(Duration(minutes: minutesBefore));
      // An occurrence whose reminder time has already passed (e.g. it fires
      // *during* the event, or the event started less than the lead time
      // ago) is silently skipped rather than firing late/immediately.
      if (!fireAt.isAfter(now)) continue;
      await _notifications.scheduleAt(
        id: _eventSlotNotificationId(event.id, scheduled),
        title: event.title,
        body: (event.location != null && event.location!.isNotEmpty)
            ? event.location
            : 'Upcoming event',
        scheduledAt: fireAt,
        payload: 'event:${event.id}',
      );
      scheduled++;
    }
    // Cancel any slots left over from a previous, longer sync (rule
    // shortened, fewer occurrences remain in the lookahead window, etc.) —
    // slot ids are stable across resyncs specifically so this is possible
    // without having to remember what was previously scheduled.
    for (int slot = scheduled; slot < _maxRecurringReminders; slot++) {
      await _notifications.cancel(_eventSlotNotificationId(event.id, slot));
    }
  }

  /// Re-rolls the reminder window forward for every currently-recurring
  /// event in [events], without needing an actual create/update to trigger
  /// it. Why this needs to exist at all: [syncForEvent] only ever runs when
  /// something *changes* the event, so a "remind me every day" series the
  /// user never edits again would schedule its first [_maxRecurringReminders]
  /// occurrences once and then, [_recurringReminderLookahead] days later,
  /// simply run out — the user would stop getting reminded with no error or
  /// indication anything broke. Calling this periodically (see RootShell)
  /// re-syncs every recurring event's window forward purely from the app
  /// being open, so the rolling window never actually goes stale as long as
  /// hyewon_list gets opened at least once within the lookahead period. This
  /// is not, and cannot be, truly unbounded — OS-level notification
  /// scheduling always needs a concrete future time, so an event that's
  /// never opened while the app is running for [_recurringReminderLookahead]
  /// days straight will still eventually run dry. That's an acceptable
  /// trade-off for a desktop app that lives in the tray rather than a
  /// background service that's always guaranteed to be running.
  Future<void> resyncRecurringReminders(List<CalendarEvent> events) async {
    for (final CalendarEvent event in events) {
      if (event.isRecurring) await syncForEvent(event);
    }
  }

  Future<void> _cancelRecurringSlots(String eventId) async {
    for (int slot = 0; slot < _maxRecurringReminders; slot++) {
      await _notifications.cancel(_eventSlotNotificationId(eventId, slot));
    }
  }

  Future<void> cancelForEvent(String eventId) async {
    await _notifications.cancel(_eventNotificationId(eventId));
    await _cancelRecurringSlots(eventId);
  }

  DateTime? _taskFireTime(Task task) {
    final int? minutesBefore = task.reminderMinutesBefore;
    if (minutesBefore == null || task.dueDate == null) return null;
    final DateTime due = task.dueDate!.add(Duration(minutes: task.dueTimeMinutes ?? 0));
    return due.subtract(Duration(minutes: minutesBefore));
  }

  DateTime? _eventFireTime(CalendarEvent event, DateTime occurrenceStart) {
    final int? minutesBefore = event.reminderMinutesBefore;
    if (minutesBefore == null) return null;
    return occurrenceStart.subtract(Duration(minutes: minutesBefore));
  }
}

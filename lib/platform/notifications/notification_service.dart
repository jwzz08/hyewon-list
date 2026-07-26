/// Real Windows toast notification support — see
/// `local_notification_service.dart` for the `flutter_local_notifications`
/// backed implementation actually wired into the app (via
/// `notificationServiceProvider`). This interface exists so feature code
/// (ReminderScheduler) never depends on the notification plugin directly.
abstract class NotificationService {
  Future<void> init();

  Future<void> showNow({required String title, String? body});

  /// Schedules a local notification for [scheduledAt]. [id] is a stable
  /// domain id (task/event id, possibly prefixed — see ReminderScheduler) so
  /// a later `cancel(id)` reliably targets the same notification.
  ///
  /// [payload] is handed back verbatim on [onTapped] when the user clicks
  /// the notification — ReminderScheduler encodes it as `task:<id>` or
  /// `event:<id>` so the app can jump straight to the right item.
  Future<void> scheduleAt({
    required String id,
    required String title,
    String? body,
    required DateTime scheduledAt,
    String? payload,
  });

  Future<void> cancel(String id);

  /// Emits a notification's `payload` whenever the user taps it (including
  /// while the app is running in the background/minimized to tray) — see
  /// `main.dart` for the app-level listener that focuses the window and
  /// opens the relevant task/event.
  Stream<String> get onTapped;
}

/// No-op stand-in used if notification init fails (see main.dart's
/// try/catch) so a missing/unsupported notification backend never blocks
/// startup — reminders silently don't fire that session instead of crashing.
class NoopNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> showNow({required String title, String? body}) async {}

  @override
  Future<void> scheduleAt({
    required String id,
    required String title,
    String? body,
    required DateTime scheduledAt,
    String? payload,
  }) async {}

  @override
  Future<void> cancel(String id) async {}

  @override
  Stream<String> get onTapped => const Stream<String>.empty();
}

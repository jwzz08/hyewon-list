import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

/// Windows-capable local notification service backed by
/// package:flutter_local_notifications (Windows toast support via the
/// federated flutter_local_notifications_windows FFI plugin — see
/// pubspec.yaml). Every reminder in this app is a one-shot notification, so
/// the platform's lack of *repeating* Windows notification support (a known
/// limitation of that plugin) doesn't affect us.
///
/// Notification ids in [NotificationService] are Strings (task/event ids);
/// this class hashes them into the 32-bit ints the plugin requires.
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'hyewon_list_reminders';
  static const String _channelName = 'Reminders';

  final StreamController<String> _tapController = StreamController<String>.broadcast();

  @override
  Stream<String> get onTapped => _tapController.stream;

  @override
  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      // Fall back to UTC if the platform timezone name isn't in the tz
      // database (e.g. abbreviations like "PST" instead of an IANA name) —
      // scheduling still works, just computed in UTC instead of local time.
      tz.setLocalLocation(tz.UTC);
    }

    const WindowsInitializationSettings windowsSettings = WindowsInitializationSettings(
      appName: 'hyewon_list',
      appUserModelId: 'com.hyewonlist.app',
      // Generated once for this project — do not regenerate; Windows keys
      // notification identity/settings off this GUID.
      guid: 'b7f2e6b0-6f2f-4c2a-9d1e-9d7a2f5f9c11',
    );
    const InitializationSettings settings = InitializationSettings(windows: windowsSettings);
    // `onDidReceiveNotificationResponse` fires whenever the user taps a
    // notification (or one of its action buttons — we don't define any, so
    // this always means "tapped the body") while the app process is alive,
    // which covers our case: the app keeps running in the tray even when
    // its window is hidden/minimized, it's never fully killed between
    // reminders. Forwarding `response.payload` (set in scheduleAt below) is
    // what lets main.dart's listener know *which* task/event to jump to.
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null && payload.isNotEmpty && !_tapController.isClosed) {
          _tapController.add(payload);
        }
      },
    );
    _initialized = true;
  }

  @override
  Future<void> showNow({required String title, String? body}) async {
    await init();
    // flutter_local_notifications 19.5.0 (the version actually pinned in
    // pubspec.lock) still takes id/title/body/notificationDetails
    // POSITIONALLY — only payload etc. are named. (A fully-named overload
    // exists on the package's unreleased master branch, but not in any
    // published 19.x, so don't "fix" this back to named args without
    // checking the resolved version first.)
    await _plugin.show(0, title, body, _details());
  }

  @override
  Future<void> scheduleAt({
    required String id,
    required String title,
    String? body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    await init();
    final int notificationId = _toIntId(id);
    // A negative/past-due target would fail on some platforms — the caller
    // (ReminderScheduler) already filters these out, but guard here too.
    if (scheduledAt.isBefore(DateTime.now())) return;
    // id/title/body/scheduledDate/notificationDetails are positional in
    // 19.5.0; androidScheduleMode/payload etc. are named.
    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(String id) async {
    await init();
    // id is positional in 19.5.0; only `tag` is named.
    await _plugin.cancel(_toIntId(id));
  }

  NotificationDetails _details() => const NotificationDetails(
        windows: WindowsNotificationDetails(),
        // Android details are harmless dead weight on a Windows-only build
        // (the package is cross-platform and requires nothing extra to
        // compile) but are NOT what actually shows on this app's target
        // platform — `windows:` above is.
        android: AndroidNotificationDetails(_channelId, _channelName,
            channelDescription: 'Task and event reminders'),
      );

  /// Stable string-id -> positive 32-bit int, since flutter_local_notifications
  /// requires int ids but our domain ids (task/event ids) are strings.
  int _toIntId(String id) => id.hashCode & 0x7fffffff;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/dao/app_settings_dao.dart';
import '../data/local/dao/calendar_event_dao.dart';
import '../data/local/dao/category_dao.dart';
import '../data/local/dao/tag_dao.dart';
import '../data/local/dao/task_dao.dart';
import '../data/local/dao/theme_preset_dao.dart';
import '../data/local/dao/widget_preference_dao.dart';
import '../data/local/database/database.dart';
import '../data/repositories/drift_calendar_event_repository.dart';
import '../data/repositories/drift_category_repository.dart';
import '../data/repositories/drift_tag_repository.dart';
import '../data/repositories/drift_task_repository.dart';
import '../data/repositories/drift_theme_preset_repository.dart';
import '../data/repositories/local_app_settings_repository.dart';
import '../data/repositories/local_widget_preference_repository.dart';
import '../data/sync/auth_service.dart';
import '../data/sync/firebase_sync_repository.dart';
import '../domain/repositories/app_settings_repository.dart';
import '../domain/repositories/calendar_event_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/sync_repository.dart';
import '../domain/repositories/tag_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/theme_preset_repository.dart';
import '../domain/repositories/widget_preference_repository.dart';
import '../domain/models/widget_mode.dart';
import '../features/reminders/domain/reminder_scheduler.dart';
import '../platform/notifications/local_notification_service.dart';
import '../platform/notifications/notification_service.dart';
import '../platform/tray/tray_service.dart';
import '../platform/tray/windows_tray_service.dart';
import '../platform/window/window_service.dart';
import '../platform/window/windows_window_service.dart';
import '../platform/windows_native/global_hotkey_service.dart';
import '../platform/windows_native/windows_native_service.dart';

/// Root composition root. Every other provider file depends on these, never
/// on Drift/window_manager/tray_manager types directly — that keeps
/// features testable and keeps the door open for a Firebase-backed
/// repository swap later without touching feature code.

// --- Local database ---

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// --- DAOs ---

final Provider<TaskDao> taskDaoProvider =
    Provider<TaskDao>((ref) => TaskDao(ref.watch(appDatabaseProvider)));

final Provider<CalendarEventDao> calendarEventDaoProvider =
    Provider<CalendarEventDao>((ref) => CalendarEventDao(ref.watch(appDatabaseProvider)));

final Provider<CategoryDao> categoryDaoProvider =
    Provider<CategoryDao>((ref) => CategoryDao(ref.watch(appDatabaseProvider)));

final Provider<TagDao> tagDaoProvider =
    Provider<TagDao>((ref) => TagDao(ref.watch(appDatabaseProvider)));

final Provider<WidgetPreferenceDao> widgetPreferenceDaoProvider = Provider<WidgetPreferenceDao>(
  (ref) => WidgetPreferenceDao(ref.watch(appDatabaseProvider)),
);

final Provider<AppSettingsDao> appSettingsDaoProvider =
    Provider<AppSettingsDao>((ref) => AppSettingsDao(ref.watch(appDatabaseProvider)));

final Provider<ThemePresetDao> themePresetDaoProvider =
    Provider<ThemePresetDao>((ref) => ThemePresetDao(ref.watch(appDatabaseProvider)));

// --- Repositories (feature code depends on these interfaces only) ---

final Provider<TaskRepository> taskRepositoryProvider =
    Provider<TaskRepository>((ref) => DriftTaskRepository(ref.watch(taskDaoProvider)));

final Provider<CalendarEventRepository> calendarEventRepositoryProvider =
    Provider<CalendarEventRepository>(
  (ref) => DriftCalendarEventRepository(ref.watch(calendarEventDaoProvider)),
);

final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => DriftCategoryRepository(ref.watch(categoryDaoProvider)));

final Provider<TagRepository> tagRepositoryProvider =
    Provider<TagRepository>((ref) => DriftTagRepository(ref.watch(tagDaoProvider)));

final Provider<WidgetPreferenceRepository> widgetPreferenceRepositoryProvider =
    Provider<WidgetPreferenceRepository>(
  (ref) => LocalWidgetPreferenceRepository(ref.watch(widgetPreferenceDaoProvider)),
);

final Provider<AppSettingsRepository> appSettingsRepositoryProvider =
    Provider<AppSettingsRepository>(
  (ref) => LocalAppSettingsRepository(ref.watch(appSettingsDaoProvider)),
);

final Provider<ThemePresetRepository> themePresetRepositoryProvider =
    Provider<ThemePresetRepository>(
  (ref) => DriftThemePresetRepository(ref.watch(themePresetDaoProvider)),
);

/// Real Firestore-backed sync (see data/sync/firebase_sync_repository.dart)
/// — fails soft to [SyncState.offline] if Firebase wasn't initialized (see
/// main.dart) rather than throwing, so wiring this in is always safe even
/// on a machine/build without Firebase configured.
final Provider<SyncRepository> syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final FirebaseSyncRepository repository = FirebaseSyncRepository(
    taskRepository: ref.watch(taskRepositoryProvider),
    calendarEventRepository: ref.watch(calendarEventRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    appSettingsRepository: ref.watch(appSettingsRepositoryProvider),
    themePresetRepository: ref.watch(themePresetRepositoryProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Turns the per-install anonymous Firebase identity [syncRepositoryProvider]
/// uses into a real, cross-device account — see data/sync/auth_service.dart.
final Provider<AuthService> authServiceProvider = Provider<AuthService>((ref) => AuthService());

// --- Platform services ---
// TODO(platform): once iOS/web targets exist, branch on
// `defaultTargetPlatform`/`kIsWeb` here instead of hardcoding the Windows
// implementations.

final Provider<WindowService> windowServiceProvider = Provider<WindowService>((ref) {
  final WindowService service = WindowsWindowService();
  ref.onDispose(service.dispose);
  return service;
});

final Provider<TrayService> trayServiceProvider = Provider<TrayService>((ref) {
  final TrayService service = WindowsTrayService(
    ref.watch(windowServiceProvider),
    ref.watch(windowsNativeServiceProvider),
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// "Start with Windows" registry integration — see windows_native_service.dart.
final Provider<WindowsNativeService> windowsNativeServiceProvider =
    Provider<WindowsNativeService>((ref) => WindowsNativeService());

/// Global Ctrl+Alt+H click-through toggle — see global_hotkey_service.dart.
final Provider<GlobalHotkeyService> globalHotkeyServiceProvider = Provider<GlobalHotkeyService>(
  (ref) {
    final GlobalHotkeyService service = GlobalHotkeyService(ref.watch(windowServiceProvider));
    ref.onDispose(service.dispose);
    return service;
  },
);

/// Real Windows toast notifications (see local_notification_service.dart).
/// `init()` is safe to call repeatedly/lazily — every method self-inits.
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((ref) => LocalNotificationService());

/// Schedules/cancels reminders for Task/CalendarEvent — see
/// reminder_scheduler.dart for scope notes (recurring events only reminder
/// on their first occurrence).
final Provider<ReminderScheduler> reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => ReminderScheduler(ref.watch(notificationServiceProvider)),
);

// --- Root navigation ---

/// Which top-level screen the root shell shows when the window is wide
/// enough for nav chrome (see AppBreakpoints.plannerMin). Below that width
/// the root shell always shows WidgetScreen regardless of this value.
final StateProvider<AppScreen> currentAppScreenProvider =
    StateProvider<AppScreen>((ref) => AppScreen.widget);

// --- Notification tap-to-open ---
//
// Set by main.dart's NotificationService.onTapped listener (parsing the
// `task:<id>` / `event:<id>:<occurrenceDateIso>` payload ReminderScheduler
// attaches — see reminder_scheduler.dart) and consumed by RootShell, which
// fetches the item and opens it in AddItemDialog's edit mode, then resets the
// value back to null. A plain StateProvider (not a one-shot event/stream) is
// deliberate: RootShell is always mounted, so "set it, then read+clear it"
// is simpler here than plumbing a dedicated event bus.

/// Non-null right after a task reminder notification is tapped — the
/// tapped task's id.
final StateProvider<String?> pendingOpenTaskIdProvider = StateProvider<String?>((ref) => null);

/// Non-null right after an event reminder notification is tapped — the
/// tapped event's id.
final StateProvider<String?> pendingOpenEventIdProvider = StateProvider<String?>((ref) => null);

/// The specific occurrence date the tapped reminder was actually for — set
/// alongside [pendingOpenEventIdProvider] whenever the payload carries one
/// (recurring-event slot reminders always do; a plain single event's
/// reminder doesn't need one since it only ever has one occurrence).
///
/// **Bug this fixes**: RootShell used to always open a recurring event's
/// notification using the *series'* own `startDateTime` (its first-ever
/// occurrence) as the edited occurrence, regardless of which actual
/// occurrence's reminder fired. Picking "This event only" or "This and
/// following" from the resulting edit then applied the change to that wrong
/// (usually long-past) date instead of the one the user actually meant —
/// creating a new detached event on the wrong day while the series kept
/// producing the untouched occurrence the user was trying to edit, so the
/// old and "modified" events both appeared to show up side by side. Reading
/// the real occurrence date back out of the payload lets RootShell build the
/// correct occurrence to edit.
final StateProvider<DateTime?> pendingOpenEventOccurrenceDateProvider =
    StateProvider<DateTime?>((ref) => null);

import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'domain/models/widget_mode.dart';
import 'domain/models/widget_preference.dart';
import 'features/widget_mode/application/widget_mode_providers.dart';
import 'features/widget_mode/presentation/screens/widget_screen.dart';
import 'firebase_options.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(firebase-sync): non-fatal by design — hyewon_list is local-first,
  // so a Firebase outage, missing config, or unsupported platform must
  // never block startup. FirebaseSyncRepository also checks
  // `Firebase.apps.isEmpty` itself, so skipping this on failure just means
  // sync reports SyncState.offline instead of working, not a crash.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // No sync this session — everything else still works fully offline.
  }

  // A manually-created ProviderContainer lets us `await` restoring the last
  // window geometry/opacity BEFORE the window is created, so there's no
  // visible "snap" from a default size to the saved one. `runApp` below
  // reuses this exact container via UncontrolledProviderScope.
  final ProviderContainer container = ProviderContainer();

  // Every other init step below (Firebase, tray, notifications, hotkey) is
  // wrapped defensively so a failure there can never block the window from
  // appearing — this one wasn't, and it's the very first thing `main()`
  // awaits, before the window is created at all. If closing hyewon_list
  // doesn't let the previous process release its SQLite file handle
  // cleanly (or the file is briefly locked/busy for any other reason),
  // opening it again on a second launch can throw (or, without Drift's own
  // busy-timeout kicking in fast enough, sit retrying) right here — with no
  // try/catch, that silently kills the whole app before any window ever
  // shows, with no visible error at all in a release build (no console is
  // attached). Falling back to in-memory defaults on failure means a window
  // always appears — worst case with default size/position/opacity instead
  // of the saved ones, rather than not appearing at all.
  WidgetPreference preference;
  try {
    preference = await container
        .read(widgetPreferenceRepositoryProvider)
        .get()
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    preference = WidgetPreference(updatedAt: DateTime.now());
  }

  // A stored size from before WidgetScreen.minSize was raised to 300x220
  // (it used to be 220x150 — see WidgetTierBreakpoints' doc comment on the
  // removed "mini" tier) can still be sitting in an existing install's local
  // DB — e.g. anyone who'd shrunk the widget into that old mini range before
  // updating. Passing a saved size smaller than the OS-level minimumSize
  // window_manager now enforces (see WindowsWindowService.init) is a
  // contradiction window_manager doesn't handle gracefully on every
  // machine — it's what caused the app to launch as a process with no
  // visible window on a second computer that still had an old small size
  // saved, while a fresh/never-shrunk install never hit it. Clamping the
  // restored size up to the current minimum (never down — a bigger saved
  // "nav chrome" size, e.g. a maximized 1920x1080, must be left alone) fixes
  // it for old data without needing a DB migration.
  final Size restoredSize = Size(
    preference.windowWidth < WidgetScreen.minSize.width
        ? WidgetScreen.minSize.width
        : preference.windowWidth,
    preference.windowHeight < WidgetScreen.minSize.height
        ? WidgetScreen.minSize.height
        : preference.windowHeight,
  );

  container.read(currentWindowSizeProvider.notifier).state = restoredSize;

  // A saved absolute windowX/windowY is only safe to trust if it actually
  // lands on a monitor that's still connected — otherwise the window gets
  // created fully off-screen (still "running", per Task Manager, just not
  // visible anywhere) with no on-screen way to drag it back. This is a real
  // risk for multi-monitor setups specifically: the position was saved
  // relative to whatever monitor arrangement was active at the time, and a
  // monitor being unplugged, resized, or rearranged since then — or the
  // exact same coordinates simply not existing on a *different* computer's
  // monitor layout when a shared build carries its own leftover local DB —
  // leaves the old absolute coordinates pointing at nothing. Falling back
  // to `null` here re-centers on the primary display instead (see
  // WindowOptions(center: initialPosition == null) in
  // WindowsWindowService.init), which is always safe.
  Offset? initialPosition;
  if (preference.windowX != null && preference.windowY != null) {
    final Offset saved = Offset(preference.windowX!, preference.windowY!);
    try {
      // Timeout guard: a plugin method channel call that never resolves
      // (rather than throwing) would otherwise hang `main()` forever right
      // here, before the window is ever created at all — worse than the
      // problem this check is trying to solve. An empty list on timeout
      // just falls through to the same "can't verify, center instead"
      // behavior as the catch block below.
      final List<Display> displays = await screenRetriever
          .getAllDisplays()
          .timeout(const Duration(seconds: 2), onTimeout: () => <Display>[]);
      final bool onScreen = displays.any((d) {
        // Display has no plain `position` getter in the resolved
        // screen_retriever version (only `visiblePosition`, which can
        // itself be null) — Offset.zero is the correct fallback there in
        // practice, since a display missing visiblePosition is invariably
        // the primary display anyway, which starts at (0,0).
        final Offset origin = d.visiblePosition ?? Offset.zero;
        final Size size = d.visibleSize ?? d.size;
        return (origin & size).contains(saved);
      });
      if (onScreen) initialPosition = saved;
    } catch (_) {
      // Can't verify — safer to center than to trust a possibly-bad
      // position (see fallback below; initialPosition stays null).
    }
  }

  await container.read(windowServiceProvider).init(
        initialSize: restoredSize,
        initialPosition: initialPosition,
        alwaysOnTop: preference.isAlwaysOnTop,
        showInTaskbar: preference.showInTaskbar,
      );

  // A delayed show()/focus() "kick" was tried unconditionally on every
  // launch as a mitigation for the reboot/autostart-specific invisible-
  // window issue, but that regressed even completely normal manual
  // launches — worse than the narrower bug it was trying to fix. Scoping it
  // to *only* the Run-key autostart launch (see WindowsNativeService's
  // `--autostart` flag) keeps a manual double-click's code path exactly as
  // it was when it last worked, with zero chance of this reintroducing that
  // regression, while still addressing the actual reboot race: a fresh
  // reboot can start this Run-key launch before DWM/the graphics driver has
  // finished initializing, which a frameless fully-transparent window (see
  // WidgetScreen) is especially vulnerable to — a manual launch minutes
  // later never hits that race in the first place.
  if (args.contains('--autostart')) {
    for (final Duration delay in const [Duration(seconds: 2), Duration(seconds: 5)]) {
      Future<void>.delayed(delay, () async {
        try {
          final windowService = container.read(windowServiceProvider);
          await windowService.show();
          await windowService.focus();
        } catch (_) {
          // Best-effort only — nothing else depends on this succeeding.
        }
      });
    }
  }

  // Guarded defensively even though windows/runner/resources/app_icon.ico
  // exists — a missing/corrupt icon file should never block startup.
  try {
    await container.read(trayServiceProvider).init();
  } catch (_) {
    // Non-fatal — hyewon_list works fine without a tray icon.
  }

  // Non-fatal by design, same reasoning as Firebase above — a missing/
  // unsupported notification backend should never block startup; it just
  // means reminders silently don't fire this session.
  try {
    final notificationService = container.read(notificationServiceProvider);
    await notificationService.init();
    // Tapping a reminder toast should bring hyewon_list back to front and
    // jump straight to the task/event it was about — see
    // ReminderScheduler (payload format) and RootShell (which actually
    // opens the edit dialog once the id lands in the pending* providers
    // below). The app process stays alive in the tray between reminders,
    // so this listener is set up once here for the whole session.
    notificationService.onTapped.listen((payload) async {
      final windowService = container.read(windowServiceProvider);
      await windowService.show();
      await windowService.focus();
      final int separator = payload.indexOf(':');
      if (separator == -1) return;
      final String kind = payload.substring(0, separator);
      final String id = payload.substring(separator + 1);
      switch (kind) {
        case 'task':
          container.read(pendingOpenTaskIdProvider.notifier).state = id;
          container.read(currentAppScreenProvider.notifier).state = AppScreen.planner;
          break;
        case 'event':
          container.read(pendingOpenEventIdProvider.notifier).state = id;
          container.read(currentAppScreenProvider.notifier).state = AppScreen.month;
          break;
      }
    });
  } catch (_) {
    // No reminders this session — everything else still works.
  }

  // TODO(windows-native): non-fatal — another app may already own
  // Ctrl+Alt+H, or hotkey_manager may be unsupported on this platform. The
  // click-through toggle is still reachable from the tray menu either way.
  try {
    await container.read(globalHotkeyServiceProvider).init();
  } catch (_) {
    // No global hotkey this session — tray menu toggle still works.
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HyewonListApp(),
    ),
  );
}

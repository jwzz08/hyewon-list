import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/utils/app_log.dart';
import 'domain/models/widget_mode.dart';
import 'domain/models/widget_preference.dart';
import 'features/widget_mode/application/widget_mode_providers.dart';
import 'features/widget_mode/presentation/screens/widget_screen.dart';
import 'firebase_options.dart';

// `Offset`/`Size` string interpolation logged as a bare "Instance of
// 'Offset'"/"Instance of 'Size'" in a real release-build log from this app
// (rather than dart:ui's own `Offset(x, y)`-style toString()) — formatting
// every geometry value manually for logging sidesteps whatever's going on
// there instead of relying on toString() actually being useful.
String _fmtOffset(Offset o) => '(${o.dx.toStringAsFixed(1)}, ${o.dy.toStringAsFixed(1)})';
String _fmtSize(Size s) => '${s.width.toStringAsFixed(1)}x${s.height.toStringAsFixed(1)}';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Runs every launch now, not just `--autostart` ones (see AppLog's doc
  // comment) — a release build has no console, so this is the only trail
  // available for any "it ran but I never saw a window" report, whichever
  // launch path triggered it.
  final bool isAutostart = args.contains('--autostart');
  await AppLog.write('main() start, args=$args, isAutostart=$isAutostart');

  // TODO(firebase-sync): non-fatal by design — hyewon_list is local-first,
  // so a Firebase outage, missing config, or unsupported platform must
  // never block startup. FirebaseSyncRepository also checks
  // `Firebase.apps.isEmpty` itself, so skipping this on failure just means
  // sync reports SyncState.offline instead of working, not a crash.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await AppLog.write('Firebase init ok');
  } catch (e) {
    await AppLog.write('Firebase init failed (non-fatal): $e');
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
    await AppLog.write('WidgetPreference loaded from DB');
  } catch (e) {
    preference = WidgetPreference(updatedAt: DateTime.now());
    await AppLog.write('WidgetPreference load failed, using defaults: $e');
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
  await AppLog.write(
    'preference: saved=${preference.windowWidth.round()}x${preference.windowHeight.round()} '
    '-> restoredSize=${restoredSize.width.round()}x${restoredSize.height.round()}, '
    'savedPos=(${preference.windowX}, ${preference.windowY})',
  );

  // A saved absolute windowX/windowY *used* to be trusted once it "checked
  // out" against screen_retriever's reported display bounds — but a real
  // log from a friend's multi-monitor PC proved that's not actually safe:
  // saved (4515, 40) validated as onScreen=true against 2 reported
  // displays, was passed straight through as initialPosition, and the
  // window still came up with isVisible=false immediately after init() —
  // window_manager/Windows didn't actually show it there. Exactly why is
  // still unclear (a leading theory: per-monitor DPI scaling makes
  // screen_retriever's and window_manager's coordinate spaces disagree
  // across displays with different scale factors), but rather than chase
  // that further, saved absolute positions are no longer trusted at
  // startup at all — every launch now always computes a fresh, centered
  // position on the primary display instead (see
  // `_computeFallbackPosition`). This trades "remembers exactly where you
  // left it" for "actually shows up", which is the only acceptable
  // trade-off for a bug this severe. The validation check itself is kept,
  // but now purely for the log line — so if this *still* doesn't fix it,
  // the next log at least confirms position isn't the variable at fault.
  Offset? savedPosition;
  if (preference.windowX != null && preference.windowY != null) {
    savedPosition = Offset(preference.windowX!, preference.windowY!);
    try {
      // Timeout guard: a plugin method channel call that never resolves
      // (rather than throwing) would otherwise hang `main()` forever right
      // here, before the window is ever created at all.
      final List<Display> displays = await screenRetriever
          .getAllDisplays()
          .timeout(const Duration(seconds: 2), onTimeout: () => <Display>[]);
      final bool onScreen = displays.any((d) {
        final Offset origin = d.visiblePosition ?? Offset.zero;
        final Size size = d.visibleSize ?? d.size;
        return (origin & size).contains(savedPosition!);
      });
      await AppLog.write(
        'saved position ${_fmtOffset(savedPosition!)} onScreen=$onScreen (${displays.length} display(s)) '
        '— NOT used as initialPosition (see doc comment)',
      );
    } catch (e) {
      await AppLog.write('saved position validation threw: $e');
    }
  }

  final Offset initialPosition = await _computeFallbackPosition(restoredSize);
  await AppLog.write('initialPosition=${_fmtOffset(initialPosition)} (always-computed fallback)');

  await container.read(windowServiceProvider).init(
        initialSize: restoredSize,
        initialPosition: initialPosition,
        alwaysOnTop: preference.isAlwaysOnTop,
        showInTaskbar: preference.showInTaskbar,
      );

  final windowService = container.read(windowServiceProvider);
  await AppLog.write(
    'window init done, isVisible=${await windowService.isVisible()}, '
    'actualPosition=${_fmtOffset(await windowService.getPosition())}, '
    'actualSize=${_fmtSize(await windowService.getSize())}',
  );
  // Purely diagnostic — doesn't change anything, just tells the next log
  // whether isVisible=false above was a brief timing race that resolves
  // itself, or genuinely stuck.
  Future<void>.delayed(const Duration(milliseconds: 800), () async {
    try {
      await AppLog.write('isVisible check @800ms: ${await windowService.isVisible()}');
    } catch (_) {}
  });

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
  //
  // show()/focus() alone turned out not to be enough: WindowsWindowService
  // .init() above already calls windowManager.show() once, synchronously,
  // *before* runApp() below ever produces Flutter's first frame — so on a
  // normal launch the window briefly exists blank and then fills in within
  // milliseconds once the first frame lands. On a cold-boot autostart, that
  // first frame can stall far longer (or the engine's D3D/ANGLE surface can
  // fail to attach at all) if the GPU/display driver isn't fully up yet —
  // the win32 window is already WS_VISIBLE (hence the taskbar entry the bug
  // report describes), so re-calling show()/focus() on it is a no-op; there
  // was never anything to un-hide. What actually needs to happen is a fresh
  // paint attempt. flutter_window.cpp now also hooks WM_DISPLAYCHANGE /
  // WM_DWMCOMPOSITIONCHANGED to force a redraw the moment the OS itself
  // reports the display stack is ready, which is the real fix — this
  // Dart-side retry is a second line of defense in case that native signal
  // never fires (or fires before the engine can act on it): a tiny resize
  // nudge forces a real WM_SIZE round-trip (see win32_window.cpp's WM_SIZE
  // handler), which resizes the Flutter child HWND and forces the engine to
  // actually recreate/repaint its rendering surface — unlike show()/focus(),
  // this can't be a no-op. Retries are spread out to 20s (previously capped
  // at 5s) to cover slow boots with many competing startup programs; each
  // attempt is independently best-effort so one failing never cancels the
  // rest.
  if (isAutostart) {
    for (final Duration delay in const [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 20),
    ]) {
      Future<void>.delayed(delay, () async {
        try {
          final windowService = container.read(windowServiceProvider);
          await windowService.show();
          await windowService.focus();
          final Size current = await windowService.getSize();
          await windowService.setSize(Size(current.width, current.height + 1));
          await windowService.setSize(current);
          await AppLog.write(
            'retry @${delay.inSeconds}s done, isVisible=${await windowService.isVisible()}',
          );
        } catch (e) {
          // Best-effort only — nothing else depends on this succeeding.
          await AppLog.write('retry @${delay.inSeconds}s threw: $e');
        }
      });
    }
  }

  // Guarded defensively even though windows/runner/resources/app_icon.ico
  // exists — a missing/corrupt icon file should never block startup.
  try {
    await container.read(trayServiceProvider).init();
    await AppLog.write('tray init ok');
  } catch (e) {
    await AppLog.write('tray init failed (non-fatal): $e');
    // Non-fatal — hyewon_list works fine without a tray icon.
  }

  // Non-fatal by design, same reasoning as Firebase above — a missing/
  // unsupported notification backend should never block startup; it just
  // means reminders silently don't fire this session.
  try {
    final notificationService = container.read(notificationServiceProvider);
    await notificationService.init();
    await AppLog.write('notification service init ok');
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
      final String rest = payload.substring(separator + 1);
      switch (kind) {
        case 'task':
          container.read(pendingOpenTaskIdProvider.notifier).state = rest;
          container.read(currentAppScreenProvider.notifier).state = AppScreen.planner;
          break;
        case 'event':
          // `rest` is `<id>` for a plain event's reminder, or
          // `<id>:<occurrenceDateIso>` for a recurring-event slot reminder
          // (see ReminderScheduler._syncRecurringEventReminders) — split off
          // the occurrence date if present so RootShell can open the actual
          // occurrence that fired instead of guessing the series' first date.
          final int dateSeparator = rest.indexOf(':');
          final String id = dateSeparator == -1 ? rest : rest.substring(0, dateSeparator);
          final DateTime? occurrenceDate = dateSeparator == -1
              ? null
              : DateTime.tryParse(rest.substring(dateSeparator + 1));
          container.read(pendingOpenEventOccurrenceDateProvider.notifier).state = occurrenceDate;
          container.read(pendingOpenEventIdProvider.notifier).state = id;
          container.read(currentAppScreenProvider.notifier).state = AppScreen.month;
          break;
      }
    });
  } catch (e) {
    await AppLog.write('notification service init failed (non-fatal): $e');
    // No reminders this session — everything else still works.
  }

  // TODO(windows-native): non-fatal — another app may already own
  // Ctrl+Alt+H, or hotkey_manager may be unsupported on this platform. The
  // click-through toggle is still reachable from the tray menu either way.
  try {
    await container.read(globalHotkeyServiceProvider).init();
    await AppLog.write('global hotkey init ok');
  } catch (e) {
    await AppLog.write('global hotkey init failed (non-fatal): $e');
    // No global hotkey this session — tray menu toggle still works.
  }

  await AppLog.write('calling runApp()');
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HyewonListApp(),
    ),
  );
}

/// Centers [windowSize] within the primary display's own visible bounds
/// (per screen_retriever), for use whenever there's no validated saved
/// window position to restore — see the doc comment at its call site in
/// `main()`. Never throws: any failure (plugin channel hiccup, no displays
/// reported, etc.) falls back to a small fixed on-screen offset, which is
/// guaranteed to land inside whichever monitor Windows treats as the origin
/// (near-universally the primary one) regardless of how many displays are
/// connected or how they're arranged.
Future<Offset> _computeFallbackPosition(Size windowSize) async {
  try {
    final Display primary = await screenRetriever
        .getPrimaryDisplay()
        .timeout(const Duration(seconds: 2));
    // See the `visiblePosition` doc comment above — same nullable-field
    // reasoning applies here.
    final Offset origin = primary.visiblePosition ?? Offset.zero;
    final Size screenSize = primary.visibleSize ?? primary.size;
    final double x = origin.dx + ((screenSize.width - windowSize.width) / 2).clamp(0, double.infinity);
    final double y = origin.dy + ((screenSize.height - windowSize.height) / 2).clamp(0, double.infinity);
    return Offset(x, y);
  } catch (_) {
    return const Offset(80, 80);
  }
}


import 'dart:async';
import 'dart:ui';

import 'package:window_manager/window_manager.dart';

import 'window_service.dart';

/// Windows-desktop implementation, backed by `window_manager` (frameless/
/// resize/position/always-on-top/opacity). A mature, published plugin with
/// its own prebuilt native code; nothing here required touching
/// `windows/runner/` C++ directly.
///
/// A real OS-composited blur (via `flutter_acrylic`) was tried here and
/// removed — it never actually rendered in testing on this app's frameless
/// window setup, and wasn't worth chasing further. `_GlassFrame`'s
/// `BackdropFilter`-based glassmorphism (see widget_screen.dart) is the
/// widget's only blur/translucency effect now.
///
/// Desktop-wallpaper attachment (reparenting behind desktop icons via the
/// undocumented `Progman`/`WorkerW` trick) was also tried and removed — on
/// real hardware, reparenting turned the window into a child window that
/// `show`/`focus` could no longer bring to the foreground, so it vanished
/// with no way back short of a Task Manager force-quit. Tray balloon
/// notifications were investigated and deliberately not built at all (see
/// ARCHITECTURE.md §7 for both).
class WindowsWindowService with WindowListener implements WindowService {
  final StreamController<Size> _resizeController = StreamController<Size>.broadcast();
  final StreamController<Offset> _moveController = StreamController<Offset>.broadcast();

  @override
  Future<void> init({
    required Size initialSize,
    Offset? initialPosition,
    bool alwaysOnTop = false,
    bool showInTaskbar = true,
  }) async {
    await windowManager.ensureInitialized();

    final WindowOptions options = WindowOptions(
      size: initialSize,
      // Mirrors WidgetScreen.minSize (300x220) — the OS-level floor the
      // window can never be dragged/set below, pinned at the old
      // mini/compact tier boundary now that the single-line "mini" widget
      // tier has been removed (see WidgetTierBreakpoints' doc comment).
      minimumSize: const Size(300, 220),
      center: initialPosition == null,
      backgroundColor: const Color(0x00000000),
      skipTaskbar: !showInTaskbar,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'hyewon_list',
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setAsFrameless();
      if (initialPosition != null) {
        await windowManager.setPosition(initialPosition);
      }
      await windowManager.setAlwaysOnTop(alwaysOnTop);
      await windowManager.setHasShadow(false);
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(this);
  }

  @override
  Future<void> setSize(Size size) => windowManager.setSize(size);

  @override
  Future<Size> getSize() => windowManager.getSize();

  @override
  Future<void> setPosition(Offset position) => windowManager.setPosition(position);

  @override
  Future<Offset> getPosition() => windowManager.getPosition();

  @override
  Future<void> setAlwaysOnTop(bool isAlwaysOnTop) => windowManager.setAlwaysOnTop(isAlwaysOnTop);

  @override
  Future<void> setSkipTaskbar(bool skip) => windowManager.setSkipTaskbar(skip);

  @override
  Future<void> setResizable(bool resizable) => windowManager.setResizable(resizable);

  @override
  Future<void> setMovable(bool movable) => windowManager.setMovable(movable);

  bool _isIgnoringMouseEvents = false;

  @override
  bool get isIgnoringMouseEvents => _isIgnoringMouseEvents;

  @override
  Future<void> setIgnoreMouseEvents(bool ignore, {bool forward = false}) async {
    await windowManager.setIgnoreMouseEvents(ignore, forward: forward);
    _isIgnoringMouseEvents = ignore;
  }

  @override
  Future<void> minimize() => windowManager.minimize();

  @override
  Future<void> close() => windowManager.close();

  @override
  Future<void> hide() => windowManager.hide();

  @override
  Future<void> show() => windowManager.show();

  @override
  Future<bool> isVisible() => windowManager.isVisible();

  @override
  Future<void> focus() => windowManager.focus();

  @override
  Stream<Size> get onResize => _resizeController.stream;

  @override
  Stream<Offset> get onMove => _moveController.stream;

  @override
  void dispose() {
    windowManager.removeListener(this);
    _resizeController.close();
    _moveController.close();
  }

  // --- WindowListener callbacks we care about ---

  @override
  void onWindowResize() {
    windowManager.getSize().then((size) {
      if (!_resizeController.isClosed) _resizeController.add(size);
    });
  }

  @override
  void onWindowMove() {
    windowManager.getPosition().then((position) {
      if (!_moveController.isClosed) _moveController.add(position);
    });
  }

  // All other WindowListener callbacks (onWindowClose, onWindowFocus,
  // onWindowMaximize, etc.) use WindowListener's built-in no-op defaults —
  // we only override the two events this service actually needs.
}

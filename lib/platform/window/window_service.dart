import 'dart:ui';

/// Platform-agnostic contract for controlling the hyewon_list window
/// (frameless, resizable, always-on-top, opacity, position).
///
/// [WindowsWindowService] is the real implementation (backed by
/// `window_manager`). [WebWindowService] is a no-op stand-in so
/// feature/UI code never has to branch on platform — see
/// ARCHITECTURE.md "Platform adapters" for how a future iOS/macOS service
/// would slot in here.
abstract class WindowService {
  Future<void> init({
    required Size initialSize,
    Offset? initialPosition,
    bool alwaysOnTop = false,
    bool showInTaskbar = true,
  });

  Future<void> setSize(Size size);

  Future<Size> getSize();

  Future<void> setPosition(Offset position);

  Future<Offset> getPosition();

  Future<void> setAlwaysOnTop(bool isAlwaysOnTop);

  /// Whether the window has a taskbar entry (Windows) — when false the
  /// window is still visible/interactive but hidden from the taskbar and
  /// Alt+Tab, useful for a pure "widget" experience reachable only via the
  /// tray icon. Backed entirely by `window_manager` (`setSkipTaskbar`), no
  /// native `windows/runner/` C++ needed.
  Future<void> setSkipTaskbar(bool skip);

  Future<void> setResizable(bool resizable);

  Future<void> setMovable(bool movable);

  /// Click-through: when [ignore] is true, all mouse events pass through
  /// this window to whatever's behind it (the window still receives
  /// keyboard events if focused). Used for the global click-through hotkey
  /// — see GlobalHotkeyService. Backed entirely by `window_manager`
  /// (`setIgnoreMouseEvents`), no native `windows/runner/` C++ needed.
  Future<void> setIgnoreMouseEvents(bool ignore, {bool forward = false});

  /// Current click-through state, tracked locally since `window_manager`
  /// has no getter for it — single source of truth so the tray menu
  /// checkbox and the global hotkey (see GlobalHotkeyService) never drift
  /// out of sync with each other.
  bool get isIgnoringMouseEvents;

  Future<void> minimize();

  Future<void> close();

  /// Fully hides the window (no taskbar entry, no Alt+Tab entry, regardless
  /// of the "Show in taskbar" setting) — paired with [show]/[isVisible] so
  /// the tray's Show/Hide toggle (see WindowsTrayService) reflects real OS
  /// state instead of tracking a local guess. Unlike [minimize], this stays
  /// correct even when "Show in taskbar" is off, since there's no taskbar
  /// entry to restore from in that case.
  Future<void> hide();

  /// Un-hides a window previously hidden via [hide] and restores it if it
  /// was minimized.
  Future<void> show();

  /// True if the window is currently visible on screen (not hidden via
  /// [hide]). Used by the tray icon to decide whether its next click should
  /// show or hide the window, instead of tracking a fragile local bool.
  Future<bool> isVisible();

  /// Brings the window to the foreground and gives it input focus — used
  /// after [show] so clicking "Show" in the tray menu doesn't just make the
  /// window visible somewhere behind other windows.
  Future<void> focus();

  /// Fires whenever the OS reports the window was resized (drag-resize,
  /// snap, etc.) — feature code uses this to persist [WidgetPreference] and
  /// to drive the widget's responsive tier.
  Stream<Size> get onResize;

  /// Fires whenever the OS reports the window moved.
  Stream<Offset> get onMove;

  void dispose();
}

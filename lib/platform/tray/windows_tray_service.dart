import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';

import '../window/window_service.dart';
import '../windows_native/windows_native_service.dart';
import 'tray_service.dart';

/// Windows tray icon with a basic Show/Hide + Quit menu, plus two
/// Windows-native extras (see windows_native_service.dart): a checkable
/// "Start with Windows" item and a "Toggle click-through" item.
///
/// Icon: `windows/runner/resources/app_icon.ico`, source of truth for both
/// the taskbar/window icon (compiled straight into the exe via Runner.rc,
/// no runtime file needed) and this tray icon (loaded from disk at runtime
/// by `tray_manager.setIcon`). Swap that one file for a new design and both
/// places update automatically — see [_resolveIconPath] for why the tray
/// half specifically needs the CMake-copied sibling file next to the exe.
class WindowsTrayService with TrayListener implements TrayService {
  WindowsTrayService(this._windowService, this._nativeService);

  final WindowService _windowService;
  final WindowsNativeService _nativeService;

  @override
  Future<void> init() async {
    trayManager.addListener(this);
    await trayManager.setIcon(_resolveIconPath());
    await trayManager.setToolTip('hyewon_list');
    await _rebuildMenu();
  }

  /// `tray_manager.setIcon` (unlike Runner.rc's compiled-in taskbar icon)
  /// loads an actual file from disk at runtime, resolved against the
  /// process's working directory. The Flutter Windows runner sets that
  /// directory to the exe's own folder at startup — not the project source
  /// tree — so the old source-relative path
  /// `'windows/runner/resources/app_icon.ico'` silently resolved to nothing
  /// there (Windows shows a blank tray icon rather than an error for a
  /// missing icon file, which is why this went unnoticed for a while).
  /// `windows/runner/CMakeLists.txt` now copies `resources/app_icon.ico` to
  /// sit right next to the built exe on every build, so this just has to
  /// look in the same directory as the running executable. Falls back to
  /// the old project-relative path for the rare case this runs with a
  /// working directory that happens to already be the project root (e.g. an
  /// IDE launch config that overrides it).
  String _resolveIconPath() {
    final String besideExe = p.join(p.dirname(Platform.resolvedExecutable), 'app_icon.ico');
    if (File(besideExe).existsSync()) return besideExe;
    return 'windows/runner/resources/app_icon.ico';
  }

  Future<void> _rebuildMenu() async {
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show_hide', label: 'Show / Hide hyewon_list'),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'toggle_click_through',
        label: 'Click-through (Ctrl+Alt+H)',
        checked: _windowService.isIgnoringMouseEvents,
      ),
      MenuItem.checkbox(
        key: 'toggle_start_with_windows',
        label: 'Start with Windows',
        checked: _nativeService.isStartWithWindowsEnabled(),
      ),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: 'Quit'),
    ]));
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_hide':
        _toggleWindow();
        break;
      case 'toggle_click_through':
        _toggleClickThrough();
        break;
      case 'toggle_start_with_windows':
        _toggleStartWithWindows();
        break;
      case 'quit':
        _windowService.close();
        break;
    }
  }

  Future<void> _toggleClickThrough() async {
    await _windowService.setIgnoreMouseEvents(!_windowService.isIgnoringMouseEvents);
    await _rebuildMenu();
  }

  Future<void> _toggleStartWithWindows() async {
    _nativeService.setStartWithWindows(!_nativeService.isStartWithWindowsEnabled());
    await _rebuildMenu();
  }

  Future<void> _toggleWindow() async {
    // Queries real OS visibility (`window_manager`'s `isVisible()`) instead
    // of tracking a local bool — the old approach could drift out of sync
    // whenever the window was shown/hidden/minimized by anything other than
    // this exact menu click (taskbar, Alt+Tab, "Show in taskbar" being off
    // so there's no taskbar entry to restore from, etc.), making the next
    // tray click do the wrong thing.
    final bool visible = await _windowService.isVisible();
    if (visible) {
      await _windowService.hide();
    } else {
      await _windowService.show();
      await _windowService.focus();
    }
  }

  @override
  Future<void> setToolTip(String tooltip) => trayManager.setToolTip(tooltip);

  @override
  Future<void> dispose() async {
    trayManager.removeListener(this);
    await trayManager.destroy();
  }
}

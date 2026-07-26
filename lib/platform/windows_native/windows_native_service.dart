import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

/// "Start with Windows" via a registry Run-key entry — pure Dart FFI
/// through package:win32_registry, no `windows/runner/` C++ edits needed
/// (see ARCHITECTURE.md "Windows native TODOs"). The registry API here is
/// synchronous, so these methods don't need to be async.
///
/// Best-effort: a locked-down registry (managed/corporate device,
/// permissions issue) fails silently rather than crashing settings —
/// [isStartWithWindowsEnabled] is always safe to call to reflect the true
/// resulting state in UI after [setStartWithWindows].
class WindowsNativeService {
  static const String _runKeyPath = r'Software\Microsoft\Windows\CurrentVersion\Run';
  static const String _runValueName = 'hyewon_list';

  bool get isSupported => Platform.isWindows;

  bool isStartWithWindowsEnabled() {
    if (!isSupported) return false;
    try {
      final RegistryKey key = Registry.openPath(RegistryHive.currentUser, path: _runKeyPath);
      final String? value = key.getStringValue(_runValueName);
      key.close();
      return value != null && value.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Adds/removes a Run-key registry value pointing at
  /// `Platform.resolvedExecutable` so Windows launches hyewon_list at login.
  void setStartWithWindows(bool enabled) {
    if (!isSupported) return;
    try {
      final RegistryKey key = Registry.openPath(
        RegistryHive.currentUser,
        path: _runKeyPath,
        desiredAccessRights: AccessRights.allAccess,
      );
      if (enabled) {
        // The `--autostart` flag lets main.dart tell "Windows just launched
        // me at login" apart from a normal manual double-click (see
        // main.dart's isAutostart check) — a fresh reboot can start this
        // Run-key launch before DWM/the graphics driver has finished
        // initializing, which a frameless fully-transparent window (see
        // WidgetScreen) is especially vulnerable to; a manual launch minutes
        // later never hits that race. Only the autostart path gets the
        // extra show()/focus() retry mitigation for exactly that reason —
        // applying it unconditionally on every launch previously caused a
        // regression on normal manual launches too.
        key.createValue(
          RegistryValue.string(
              _runValueName, '"${Platform.resolvedExecutable}" --autostart'),
        );
      } else {
        key.deleteValue(_runValueName);
      }
      key.close();
    } catch (_) {
      // See class doc comment — silently best-effort.
    }
  }
}

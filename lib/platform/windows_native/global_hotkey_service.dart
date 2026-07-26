import 'package:flutter/services.dart' show PhysicalKeyboardKey;
import 'package:hotkey_manager/hotkey_manager.dart';

import '../window/window_service.dart';

/// Registers a single system-wide hotkey (Ctrl+Alt+H) that toggles
/// click-through mode (see `WindowService.setIgnoreMouseEvents`) — lets the
/// user "pin" hyewon_list to the desktop and click through it, then get
/// their clicks back without having to find/focus the window first (which
/// isn't possible once it's click-through). Pure Dart via package
/// hotkey_manager, no `windows/runner/` C++ needed.
///
/// Best-effort: hotkey registration can fail if another app already claimed
/// the same combination — `init()` swallows that so it never blocks
/// startup; the click-through feature is just unavailable via hotkey that
/// session (nothing else in the app depends on it).
class GlobalHotkeyService {
  GlobalHotkeyService(this._windowService);

  final WindowService _windowService;
  bool _registered = false;

  static final HotKey _toggleClickThroughHotKey = HotKey(
    key: PhysicalKeyboardKey.keyH,
    modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
    scope: HotKeyScope.system,
  );

  Future<void> init() async {
    await hotKeyManager.unregisterAll();
    await hotKeyManager.register(
      _toggleClickThroughHotKey,
      keyDownHandler: (_) => _toggleClickThrough(),
    );
    _registered = true;
  }

  Future<void> _toggleClickThrough() =>
      _windowService.setIgnoreMouseEvents(!_windowService.isIgnoringMouseEvents);

  Future<void> dispose() async {
    if (_registered) {
      await hotKeyManager.unregisterAll();
    }
  }
}

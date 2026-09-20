import 'package:flutter/foundation.dart';

/// True on iPhone/iPad/Android. Uses [defaultTargetPlatform] (not
/// `dart:io`'s `Platform`) so it's safe on web and overridable in tests.
bool get isMobilePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// True only on the Windows desktop build — the one target that owns the
/// frameless widget window, tray icon, global hotkey, and registry
/// integration.
bool get isWindowsDesktop => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

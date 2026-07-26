import 'dart:async';
import 'dart:ui';

import 'window_service.dart';

/// TODO(web-platform): The browser has no equivalent of a frameless,
/// draggable, always-on-top desktop window — "widget mode" on web will
/// likely become a browser extension popup or a PWA in a small pinned
/// window instead. This stub exists purely so shared feature code compiles
/// against [WindowService] on web without runtime crashes; it reports a
/// fixed viewport-sized "window" and ignores all mutation calls.
class WebWindowService implements WindowService {
  Size _size = const Size(1280, 800);
  final Offset _position = Offset.zero;

  final StreamController<Size> _resizeController = StreamController<Size>.broadcast();
  final StreamController<Offset> _moveController = StreamController<Offset>.broadcast();

  @override
  Future<void> init({
    required Size initialSize,
    Offset? initialPosition,
    bool alwaysOnTop = false,
    bool showInTaskbar = true,
  }) async {
    _size = initialSize;
    // TODO(web-platform): hook into `window.innerWidth`/`innerHeight`
    // resize events (via `dart:html` or the `web` package) and push them
    // into `_resizeController` so ResizeAwareLayout still reflows correctly
    // in a browser tab.
  }

  @override
  Future<void> setSize(Size size) async => _size = size;

  @override
  Future<Size> getSize() async => _size;

  @override
  Future<void> setPosition(Offset position) async {}

  @override
  Future<Offset> getPosition() async => _position;

  @override
  Future<void> setAlwaysOnTop(bool isAlwaysOnTop) async {}

  @override
  Future<void> setSkipTaskbar(bool skip) async {}

  @override
  Future<void> setResizable(bool resizable) async {}

  @override
  Future<void> setMovable(bool movable) async {}

  bool _isIgnoringMouseEvents = false;

  @override
  bool get isIgnoringMouseEvents => _isIgnoringMouseEvents;

  @override
  Future<void> setIgnoreMouseEvents(bool ignore, {bool forward = false}) async {
    _isIgnoringMouseEvents = ignore;
  }

  @override
  Future<void> minimize() async {}

  @override
  Future<void> close() async {}

  bool _isVisible = true;

  @override
  Future<void> hide() async => _isVisible = false;

  @override
  Future<void> show() async => _isVisible = true;

  @override
  Future<bool> isVisible() async => _isVisible;

  @override
  Future<void> focus() async {}

  @override
  Stream<Size> get onResize => _resizeController.stream;

  @override
  Stream<Offset> get onMove => _moveController.stream;

  @override
  void dispose() {
    _resizeController.close();
    _moveController.close();
  }
}

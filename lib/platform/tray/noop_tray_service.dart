import 'tray_service.dart';

/// Mobile has no system tray — every call is a no-op so shared code
/// (e.g. RootShell-style tooltip updates) can still talk to [TrayService].
class NoopTrayService implements TrayService {
  @override
  Future<void> init() async {}

  @override
  Future<void> setToolTip(String tooltip) async {}

  @override
  Future<void> dispose() async {}
}

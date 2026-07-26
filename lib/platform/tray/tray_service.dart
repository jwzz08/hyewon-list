/// Minimal system-tray contract. Only "show/hide window" and "quit" are
/// implemented for MVP (section 4.4's "system tray menu if feasible").
///
/// TODO(windows-native): balloon notifications, custom per-state icons, and
/// richer context menus (e.g. "Quick add" directly from the tray) likely
/// need native Win32 tray APIs beyond what `tray_manager` exposes — see
/// ARCHITECTURE.md "Windows native TODOs".
abstract class TrayService {
  Future<void> init();

  /// Updates the hover tooltip text — RootShell keeps this reflecting live
  /// app state (e.g. overdue task count) so the tray icon is useful at a
  /// glance without opening the window, a lightweight stand-in for the
  /// "custom per-state icon" idea above (which would need new icon art this
  /// environment has no way to design/generate, not just code).
  Future<void> setToolTip(String tooltip);

  Future<void> dispose();
}

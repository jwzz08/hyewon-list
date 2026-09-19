import 'dart:io';

/// Lightweight, best-effort append-only activity log written to
/// `%LOCALAPPDATA%\hyewon_list\app.log`. Runs on *every* launch (not just
/// `--autostart` ones, unlike the log this replaced) so a "it ran but I
/// never saw it" report from any launch path — not only a reboot — can
/// actually be diagnosed instead of guessed at. Release builds have no
/// attached console, so this is the only way to see what happened during
/// startup at all; every invisible-window investigation this app has been
/// through hit that wall.
///
/// Every call site treats this as fire-and-forget for correctness (it's
/// only ever awaited to keep log lines in chronological order, never
/// because anything depends on it succeeding), and every failure here
/// (locked file, missing env var, no permissions) is swallowed so logging
/// itself can never affect whether the app actually starts.
abstract final class AppLog {
  static const int _maxBytes = 2 * 1024 * 1024; // 2 MB

  static Directory? _cachedDir;

  /// `%LOCALAPPDATA%\hyewon_list` — read directly as a plain environment
  /// variable rather than via `path_provider` (see database.dart's
  /// `_resolveLocalAppDataDir` doc comment: a synchronous, zero-I/O lookup
  /// that can't itself stall, which matters here since this may run during
  /// the exact early-boot GPU/driver race it exists to diagnose). Cached
  /// after the first successful resolution — it never changes mid-run.
  /// Exposed publicly so other code (the tray menu's "Open log folder" item)
  /// can point at the same place without duplicating this lookup.
  static Directory? get directory {
    if (_cachedDir != null) return _cachedDir;
    final String? localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData == null || localAppData.isEmpty) return null;
    _cachedDir = Directory('$localAppData\\hyewon_list');
    return _cachedDir;
  }

  static File? get _file {
    final Directory? dir = directory;
    return dir == null ? null : File('${dir.path}\\app.log');
  }

  /// Appends one timestamped line. Best-effort/non-fatal — see class doc.
  static Future<void> write(String message) async {
    try {
      final Directory? dir = directory;
      final File? file = _file;
      if (dir == null || file == null) return;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      // Simple size-based rotation: once the log passes _maxBytes, start
      // fresh rather than growing forever across weeks/months of every
      // launch appending a handful of lines.
      if (await file.exists() && (await file.length()) > _maxBytes) {
        await file.delete();
      }
      await file.writeAsString(
        '${DateTime.now().toIso8601String()}  $message\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Best-effort only — logging must never affect the app itself.
    }
  }
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart'; // ensures native sqlite3 is bundled

import 'tables/app_settings_table.dart';
import 'tables/calendar_events_table.dart';
import 'tables/categories_table.dart';
import 'tables/tags_table.dart';
import 'tables/tasks_table.dart';
import 'tables/theme_presets_table.dart';
import 'tables/widget_preferences_table.dart';

part 'database.g.dart';

/// The single Drift database for hyewon_list. Opened once (see
/// app/providers or main.dart) and injected everywhere via Riverpod.
///
/// IMPORTANT (setup step): this file requires generated code. After pulling
/// dependencies, run:
///   dart run build_runner build --delete-conflicting-outputs
/// to produce `database.g.dart`. See README.md.
///
/// TODO(security): plaintext on disk. Encryption-at-rest was attempted
/// (SQLite3MultipleCiphers via sqlite3 3.x + drift 2.32, see pubspec.yaml's
/// TODO(security) comment) and reverted — it broke `build_runner` on a real
/// machine (`'dart compile' does not support build hooks`). See
/// ARCHITECTURE.md "Windows native TODOs" for the classic
/// `sqlcipher_flutter_libs`-based alternative being evaluated next, which
/// doesn't depend on Dart's build-hooks mechanism.
@DriftDatabase(tables: [
  Tasks,
  CalendarEvents,
  Categories,
  Tags,
  WidgetPreferences,
  ThemePresets,
  AppSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests to inject an in-memory database.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // v1 -> v2: reminders/notifications (see ReminderScheduler) added
          // `reminderMinutesBefore` to both Tasks and CalendarEvents.
          //
          // Raw SQL (not `m.addColumn(tasks, tasks.reminderMinutesBefore)`)
          // deliberately — the typed API ties this migration's compile-time
          // correctness to database.g.dart always being freshly regenerated
          // in lockstep with tasks_table.dart/calendar_events_table.dart,
          // and a stale generated file produces a confusing
          // Column<int>/GeneratedColumn<Object> type error here instead of
          // a clear "getter not defined" one. Column names are Drift's
          // default snake_case conversion of the Dart field name.
          if (from < 2) {
            await customStatement('ALTER TABLE tasks ADD COLUMN reminder_minutes_before INTEGER;');
            await customStatement(
              'ALTER TABLE calendar_events ADD COLUMN reminder_minutes_before INTEGER;',
            );
          }
          // v2 -> v3: "Show in taskbar" toggle (WindowService.setSkipTaskbar)
          // added `showInTaskbar` to WidgetPreferences. SQLite has no real
          // boolean type — Drift stores bool as INTEGER 0/1, so the default
          // is `1` (true), matching WidgetPreference.showInTaskbar's default.
          if (from < 3) {
            await customStatement(
              'ALTER TABLE widget_preferences ADD COLUMN show_in_taskbar INTEGER NOT NULL DEFAULT 1;',
            );
          }
          // v3 -> v4: month-view text-size customization (Settings >
          // Calendar) added `monthItemTextScale` to AppSettingsTable.
          if (from < 4) {
            await customStatement(
              'ALTER TABLE app_settings_table ADD COLUMN month_item_text_scale REAL NOT NULL DEFAULT 1.3;',
            );
          }
          // TODO(schema): add further stepwise migrations here as
          // schemaVersion increases. Also bump AppSettings/Task/
          // CalendarEvent JSON export `schemaVersion` in
          // import_export_service.dart in lockstep.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final File dbFile = await _resolveDbFile();
    return NativeDatabase.createInBackground(dbFile);
  });
}

/// **Correction**: this used to call `getApplicationSupportDirectory()` and
/// (wrongly) claimed that resolved to AppData\**Local**. It actually
/// resolves to `%APPDATA%\<CompanyName>\<ProductName>` — AppData\**Roaming**
/// — which is itself a sync-prone location by Windows' own design (that's
/// the entire distinction between Local and Roaming: Roaming is meant to
/// follow the user across machines on a domain, via Enterprise State
/// Roaming, or via a broadened OneDrive backup scope). That's almost
/// certainly why the original Documents-folder bug (invisible window after
/// a reboot once real data existed) came back once enough new data had been
/// added again — it was never actually fixed, just moved to another
/// roam-by-design folder that hadn't accumulated enough "hot" data yet to
/// re-trigger the same stall.
///
/// `%LOCALAPPDATA%` (read directly as a plain environment variable — every
/// Windows process gets it in its environment block at creation, GUI apps
/// launched via the registry Run key included, so this is a synchronous,
/// zero-I/O lookup that can't itself stall) is the actual machine-local,
/// never-roamed folder: excluded from Windows roaming profiles, Enterprise
/// State Roaming, and OneDrive Known Folder Move by design, not just by
/// today's configuration.
Future<File> _resolveDbFile() async {
  final Directory supportDir = await _resolveLocalAppDataDir();
  final Directory dbFolder = Directory(p.join(supportDir.path, 'hyewon_list'));
  if (!await dbFolder.exists()) {
    await dbFolder.create(recursive: true);
  }
  final File newDbFile = File(p.join(dbFolder.path, 'hyewon_list.sqlite'));

  // One-time migration for an existing install: its data may still live at
  // one of two older locations — the AppData\Roaming path this file used
  // until the correction above, or (for anyone who never even got that far)
  // the original Documents-based path. Move whichever is found over so
  // nobody's existing tasks/events/settings appear to vanish. Best-effort:
  // any failure here just means starting from a fresh empty DB, same as a
  // brand-new install, rather than blocking startup.
  if (!await newDbFile.exists()) {
    for (final Future<File?> Function() locatePrevious in [
      _previousRoamingDbFile,
      _previousDocumentsDbFile,
    ]) {
      try {
        final File? oldDbFile = await locatePrevious();
        if (oldDbFile != null && await oldDbFile.exists()) {
          await oldDbFile.copy(newDbFile.path);
          break;
        }
      } catch (_) {
        // See doc comment above — non-fatal, try the next candidate.
      }
    }
  }

  return newDbFile;
}

Future<Directory> _resolveLocalAppDataDir() async {
  final String? localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData != null && localAppData.isNotEmpty) {
    return Directory(localAppData);
  }
  // Not Windows, or the env var is unexpectedly unset — fall back to the
  // old (Roaming) behavior rather than crashing startup outright.
  return getApplicationSupportDirectory();
}

Future<File?> _previousRoamingDbFile() async {
  final Directory oldSupportDir = await getApplicationSupportDirectory();
  return File(p.join(oldSupportDir.path, 'hyewon_list', 'hyewon_list.sqlite'));
}

Future<File?> _previousDocumentsDbFile() async {
  final Directory oldAppDir = await getApplicationDocumentsDirectory();
  return File(p.join(oldAppDir.path, 'hyewon_list', 'hyewon_list.sqlite'));
}

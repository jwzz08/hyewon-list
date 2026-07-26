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

/// AppData/Local (`getApplicationSupportDirectory` on Windows) rather than
/// the Documents folder the DB used to live in. Documents is a very common
/// OneDrive "Known Folder Move" sync target — once the DB file actually has
/// real content (not just a nearly-empty fresh file), opening it during a
/// very early auto-start-at-boot launch can race OneDrive still mounting/
/// hydrating that file, stalling the open for a long time or indefinitely.
/// That's exactly what caused hyewon_list to launch with no visible window
/// after a reboot once real tasks/events existed, and why deleting
/// `Documents\hyewon_list` "fixed" it (a fresh, non-stalled file). AppData/
/// Local isn't a Known Folder Move target by default, sidestepping the
/// whole class of problem rather than just working around one symptom.
Future<File> _resolveDbFile() async {
  final Directory supportDir = await getApplicationSupportDirectory();
  final Directory dbFolder = Directory(p.join(supportDir.path, 'hyewon_list'));
  if (!await dbFolder.exists()) {
    await dbFolder.create(recursive: true);
  }
  final File newDbFile = File(p.join(dbFolder.path, 'hyewon_list.sqlite'));

  // One-time migration for an existing install: its data still lives at the
  // old Documents-based path the very first time this runs post-update —
  // move it over so nobody's existing tasks/events/settings appear to
  // vanish. Best-effort: any failure here just means starting from a fresh
  // empty DB, same as a brand-new install, rather than blocking startup.
  if (!await newDbFile.exists()) {
    try {
      final Directory oldAppDir = await getApplicationDocumentsDirectory();
      final File oldDbFile = File(p.join(oldAppDir.path, 'hyewon_list', 'hyewon_list.sqlite'));
      if (await oldDbFile.exists()) {
        await oldDbFile.copy(newDbFile.path);
      }
    } catch (_) {
      // See doc comment above — non-fatal.
    }
  }

  return newDbFile;
}

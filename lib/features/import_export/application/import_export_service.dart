import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/calendar_event.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/priority.dart';
import '../../../domain/models/tag.dart';
import '../../../domain/models/task.dart';
import '../../../domain/models/theme_preset.dart';
import '../../../domain/repositories/app_settings_repository.dart';
import '../../../domain/repositories/calendar_event_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/repositories/theme_preset_repository.dart';

/// Bump whenever the JSON export shape changes, and keep
/// `AppDatabase.migration` (data/local/database/database.dart) in lockstep.
/// v2 added `tags` and `themePresets` — a v1 file (missing both keys) still
/// imports fine since those sections are read as empty-if-absent below.
const int kExportSchemaVersion = 2;

/// JSON export/import + CSV task export (spec section 12). Deliberately
/// excludes [WidgetPreference] — window geometry/opacity are device-local
/// and should never travel between machines via export/import.
class ImportExportService {
  ImportExportService({
    required TaskRepository taskRepository,
    required CalendarEventRepository calendarEventRepository,
    required CategoryRepository categoryRepository,
    required TagRepository tagRepository,
    required AppSettingsRepository appSettingsRepository,
    required ThemePresetRepository themePresetRepository,
  })  : _taskRepository = taskRepository,
        _calendarEventRepository = calendarEventRepository,
        _categoryRepository = categoryRepository,
        _tagRepository = tagRepository,
        _appSettingsRepository = appSettingsRepository,
        _themePresetRepository = themePresetRepository;

  final TaskRepository _taskRepository;
  final CalendarEventRepository _calendarEventRepository;
  final CategoryRepository _categoryRepository;
  final TagRepository _tagRepository;
  final AppSettingsRepository _appSettingsRepository;
  final ThemePresetRepository _themePresetRepository;

  Future<Map<String, dynamic>> buildExportPayload() async {
    final List<Task> tasks = await _taskRepository.watchAll().first;
    final List<CalendarEvent> events = await _calendarEventRepository.watchAll().first;
    final List<Category> categories = await _categoryRepository.watchAll().first;
    final List<Tag> tags = await _tagRepository.watchAll().first;
    final List<ThemePreset> themePresets = await _themePresetRepository.watchAll().first;
    final AppSettings settings = await _appSettingsRepository.get();

    return {
      'schemaVersion': kExportSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'themePresets': themePresets.map((p) => p.toJson()).toList(),
      'appSettings': settings.toJson(),
    };
  }

  /// Opens a native save-file dialog and writes the full JSON export.
  /// Returns the written file path, or null if the user cancelled.
  Future<String?> exportAllToJsonFile() async {
    final Map<String, dynamic> payload = await buildExportPayload();
    final String jsonStr = const JsonEncoder.withIndent('  ').convert(payload);

    final String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export hyewon_list data',
      fileName: 'hyewon_list_export_${DateTime.now().millisecondsSinceEpoch}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (path == null) return null;
    final File file = File(path);
    await file.writeAsString(jsonStr);
    return file.path;
  }

  /// Opens a native open-file dialog, validates `schemaVersion`, and
  /// imports (upserts by ID — rows with an existing ID are overwritten
  /// rather than duplicated, since [TaskRepository.create] etc. use
  /// insert-or-update semantics under the hood).
  Future<int> importFromJsonFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import hyewon_list data',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return 0;
    final File file = File(result.files.single.path!);
    final String content = await file.readAsString();
    return importFromJsonString(content);
  }

  Future<int> importFromJsonString(String content) async {
    final Map<String, dynamic> data = jsonDecode(content) as Map<String, dynamic>;
    final int? schemaVersion = data['schemaVersion'] as int?;
    if (schemaVersion == null || schemaVersion > kExportSchemaVersion) {
      throw SchemaVersionMismatchException(schemaVersion ?? -1, kExportSchemaVersion);
    }

    int importedCount = 0;

    for (final dynamic raw in (data['categories'] as List? ?? const [])) {
      await _categoryRepository.create(Category.fromJson(raw as Map<String, dynamic>));
      importedCount++;
    }
    for (final dynamic raw in (data['tasks'] as List? ?? const [])) {
      await _taskRepository.create(Task.fromJson(raw as Map<String, dynamic>));
      importedCount++;
    }
    for (final dynamic raw in (data['events'] as List? ?? const [])) {
      await _calendarEventRepository.create(CalendarEvent.fromJson(raw as Map<String, dynamic>));
      importedCount++;
    }
    for (final dynamic raw in (data['tags'] as List? ?? const [])) {
      // upsert (not findOrCreateByName) so imported tags keep their original
      // id/timestamps and re-link correctly with imported tasks'
      // `tagIds` (which reference the same ids from the export payload).
      await _tagRepository.upsert(Tag.fromJson(raw as Map<String, dynamic>));
      importedCount++;
    }
    for (final dynamic raw in (data['themePresets'] as List? ?? const [])) {
      await _themePresetRepository.create(ThemePreset.fromJson(raw as Map<String, dynamic>));
      importedCount++;
    }
    if (data['appSettings'] != null) {
      await _appSettingsRepository
          .save(AppSettings.fromJson(data['appSettings'] as Map<String, dynamic>));
    }

    return importedCount;
  }

  /// CSV fields per product spec §12: title, description, due date, due
  /// time, completed, priority, category, tags.
  Future<String> exportTasksToCsv() async {
    final List<Task> tasks = await _taskRepository.watchAll().first;
    final List<List<dynamic>> rows = [
      ['title', 'description', 'due_date', 'due_time', 'completed', 'priority', 'category', 'tags'],
      ...tasks.map((t) => [
            t.title,
            t.description ?? '',
            t.dueDate?.toIso8601String().split('T').first ?? '',
            t.dueTimeMinutes == null
                ? ''
                : '${(t.dueTimeMinutes! ~/ 60).toString().padLeft(2, '0')}:'
                    '${(t.dueTimeMinutes! % 60).toString().padLeft(2, '0')}',
            t.isCompleted.toString(),
            t.priority.value,
            t.categoryId ?? '',
            t.tagIds.join('|'),
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  Future<String?> exportTasksToCsvFile() async {
    final String csvStr = await exportTasksToCsv();
    final String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export tasks as CSV',
      fileName: 'hyewon_list_tasks_${DateTime.now().millisecondsSinceEpoch}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (path == null) return null;
    final File file = File(path);
    await file.writeAsString(csvStr);
    return file.path;
  }

  /// Column name aliases recognized in a CSV header row, keyed by this
  /// service's internal field name — lets [importTasksFromCsv] read files
  /// that weren't produced by [exportTasksToCsv] (different header wording,
  /// reordered/missing columns), not just round-trip this app's own export.
  /// Matching is case-insensitive and treats `_` the same as a space (see
  /// [_normalizeHeaderCell]).
  static const Map<String, List<String>> _csvHeaderAliases = {
    'title': ['title', 'name', 'task', 'task name'],
    'description': ['description', 'desc', 'notes', 'note', 'memo'],
    'due_date': ['due date', 'date', 'duedate'],
    'due_time': ['due time', 'time', 'duetime'],
    'completed': ['completed', 'done', 'status', 'is completed', 'complete'],
    'priority': ['priority', 'urgency'],
    'category': ['category', 'category id', 'list', 'project'],
    'tags': ['tags', 'tag', 'labels', 'label'],
  };

  /// Fixed column order — used only when [_detectColumnIndexes] can't find
  /// a recognizable header row, so a file with no header (including one
  /// this app itself wrote before this method learned to read headers)
  /// still imports exactly as before.
  static const Map<String, int> _legacyCsvColumns = {
    'title': 0,
    'description': 1,
    'due_date': 2,
    'due_time': 3,
    'completed': 4,
    'priority': 5,
    'category': 6,
    'tags': 7,
  };

  String _normalizeHeaderCell(String raw) =>
      raw.trim().toLowerCase().replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ');

  /// Returns a field-name → column-index map built from [headerRow], or
  /// `null` if it doesn't look like a header at all (no recognizable
  /// "title"-ish column) — in which case the caller should treat every row,
  /// including this one, as data and fall back to [_legacyCsvColumns].
  Map<String, int>? _detectColumnIndexes(List<dynamic> headerRow) {
    final List<String> normalized = headerRow.map((c) => _normalizeHeaderCell(c.toString())).toList();
    final Map<String, int> found = {};
    for (final MapEntry<String, List<String>> entry in _csvHeaderAliases.entries) {
      for (int i = 0; i < normalized.length; i++) {
        if (entry.value.contains(normalized[i])) {
          found[entry.key] = i;
          break;
        }
      }
    }
    return found.containsKey('title') ? found : null;
  }

  /// Tries ISO-8601 first (what [exportTasksToCsv] writes), then a handful
  /// of layouts common in spreadsheet exports from other apps: `M/D/YYYY`
  /// (US convention — the ambiguous ordering most tools default to),
  /// `YYYY/MM/DD`, and `Mon D, YYYY`/`Month D, YYYY`. Returns `null` (no
  /// due date) rather than throwing if nothing matches, so one malformed
  /// date cell never fails the whole row.
  DateTime? _parseFlexibleDate(String raw) {
    if (raw.isEmpty) return null;
    final DateTime? iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    final Match? slashOrDash = RegExp(r'^(\d{1,4})[/\-](\d{1,2})[/\-](\d{1,4})$').firstMatch(raw);
    if (slashOrDash != null) {
      try {
        final String first = slashOrDash.group(1)!;
        final int a = int.parse(first);
        final int b = int.parse(slashOrDash.group(2)!);
        final int c = int.parse(slashOrDash.group(3)!);
        if (first.length == 4) return DateTime(a, b, c); // YYYY/MM/DD
        final int year = c < 100 ? 2000 + c : c; // M/D/YY or M/D/YYYY
        return DateTime(year, a, b);
      } catch (_) {
        return null;
      }
    }

    const List<String> monthAbbrs = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
    ];
    final Match? monthDayYear = RegExp(r'^([A-Za-z]{3,})\s+(\d{1,2}),?\s+(\d{4})$').firstMatch(raw);
    if (monthDayYear != null) {
      final String monthWord = monthDayYear.group(1)!.toLowerCase();
      final int monthIndex =
          monthAbbrs.indexOf(monthWord.length >= 3 ? monthWord.substring(0, 3) : monthWord);
      if (monthIndex != -1) {
        try {
          return DateTime(
              int.parse(monthDayYear.group(3)!), monthIndex + 1, int.parse(monthDayYear.group(2)!));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  /// Accepts 24-hour `HH:mm` (what [exportTasksToCsv] writes) or 12-hour
  /// `h:mm AM/PM`.
  int? _parseFlexibleTime(String raw) {
    if (raw.isEmpty) return null;
    final Match? ampm = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(raw);
    if (ampm != null) {
      int hour = int.parse(ampm.group(1)!);
      final int minute = int.parse(ampm.group(2)!);
      if (hour < 1 || hour > 12 || minute > 59) return null;
      final bool isPm = ampm.group(3)!.toLowerCase() == 'pm';
      if (hour == 12) hour = 0;
      return (isPm ? hour + 12 : hour) * 60 + minute;
    }
    final Match? hhmm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (hhmm != null) {
      final int hour = int.parse(hhmm.group(1)!);
      final int minute = int.parse(hhmm.group(2)!);
      if (hour < 24 && minute < 60) return hour * 60 + minute;
    }
    return null;
  }

  /// Beyond the exact `"true"` [exportTasksToCsv] writes, also recognizes
  /// the handful of truthy spellings other to-do apps commonly export
  /// (`1`, `yes`, `y`, `x`, `done`, `complete(d)`).
  bool _parseFlexibleBool(String raw) {
    const Set<String> truthy = {'true', '1', 'yes', 'y', 'x', 'done', 'complete', 'completed'};
    return truthy.contains(raw.trim().toLowerCase());
  }

  /// Matches [raw] against an existing category's id first (round-trips
  /// this app's own export, which writes raw ids), then falls back to a
  /// case-insensitive name match (so a third-party CSV using category
  /// *names* also resolves correctly). Unrecognized text is dropped
  /// (uncategorized) rather than stored as a dangling id — categories
  /// aren't auto-created here since there'd be no sensible color to pick.
  String? _resolveCategoryId(String raw, List<Category> categories) {
    if (raw.isEmpty) return null;
    for (final Category c in categories) {
      if (c.id == raw) return c.id;
    }
    final String lower = raw.toLowerCase();
    for (final Category c in categories) {
      if (c.name.toLowerCase() == lower) return c.id;
    }
    return null;
  }

  /// Same id-first-then-name matching as [_resolveCategoryId], for tags —
  /// except a tag with no id/name match isn't dropped, it's *created*
  /// (`TagRepository.findOrCreateByName`), since a stray unrecognized tag
  /// name is far more likely a genuinely new tag (e.g. imported from
  /// another app) than a typo, unlike a category, which needs a color
  /// choice this importer has no basis for making. Splits on whichever of
  /// `|`/`;`/`,` actually appears in the cell — [exportTasksToCsv] always
  /// uses `|`, but a third-party file might use either of the others.
  Future<List<String>> _resolveTagIds(String raw, List<Tag> existingTags) async {
    if (raw.isEmpty) return const [];
    final String separator = raw.contains('|') ? '|' : (raw.contains(';') ? ';' : ',');
    final List<String> parts =
        raw.split(separator).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final List<String> ids = [];
    for (final String part in parts) {
      Tag? byId;
      for (final Tag t in existingTags) {
        if (t.id == part) {
          byId = t;
          break;
        }
      }
      if (byId != null) {
        ids.add(byId.id);
        continue;
      }
      final Tag created = await _tagRepository.findOrCreateByName(part);
      ids.add(created.id);
    }
    return ids;
  }

  /// Reads a CSV of tasks — [exportTasksToCsv]'s own layout round-trips
  /// exactly as before, but this now also tolerates real-world variation:
  /// a header row with reordered/renamed/missing columns (see
  /// [_csvHeaderAliases]), several non-ISO date/time formats, more truthy
  /// spellings for "completed", and category/tag *names* in addition to
  /// this app's internal ids (tags with no match are created rather than
  /// dropped — see [_resolveTagIds]). Each row always becomes a new task
  /// (a fresh id), even if re-importing a file exported from this same
  /// database, since CSV (unlike the JSON export) never carries the
  /// original task id.
  Future<int> importTasksFromCsv(String csvContent) async {
    final List<List<dynamic>> rows = const CsvToListConverter(eol: '\n').convert(csvContent);
    if (rows.isEmpty) return 0;

    final Map<String, int>? detected = rows.first.isEmpty ? null : _detectColumnIndexes(rows.first);
    final Map<String, int> columns = detected ?? _legacyCsvColumns;
    final Iterable<List<dynamic>> dataRows = detected != null ? rows.skip(1) : rows;

    final List<Category> categories = await _categoryRepository.watchAll().first;
    final List<Tag> existingTags = await _tagRepository.watchAll().first;

    int importedCount = 0;
    for (final List<dynamic> row in dataRows) {
      String cell(String field) {
        final int? i = columns[field];
        if (i == null || i >= row.length) return '';
        return row[i].toString();
      }
      final String title = cell('title').trim();
      if (title.isEmpty) continue;

      final String description = cell('description').trim();
      final DateTime? dueDate = _parseFlexibleDate(cell('due_date').trim());
      final int? dueTimeMinutes = _parseFlexibleTime(cell('due_time').trim());
      final bool completed = _parseFlexibleBool(cell('completed'));
      final String priorityStr = cell('priority').trim().toLowerCase();
      final String? categoryId = _resolveCategoryId(cell('category').trim(), categories);
      final List<String> tagIds = await _resolveTagIds(cell('tags').trim(), existingTags);

      final DateTime now = DateTime.now();
      final Task task = Task(
        id: IdGenerator.newId(),
        title: title,
        description: description.isEmpty ? null : description,
        isCompleted: completed,
        dueDate: dueDate,
        dueTimeMinutes: dueTimeMinutes,
        priority: TaskPriority.fromValue(priorityStr.isEmpty ? 'medium' : priorityStr),
        categoryId: categoryId,
        tagIds: tagIds,
        createdAt: now,
        updatedAt: now,
      );
      await _taskRepository.create(task);
      importedCount++;
    }
    return importedCount;
  }

  /// Opens a native open-file dialog and imports via [importTasksFromCsv].
  /// Returns the number of tasks imported, or 0 if the user cancelled.
  Future<int> importTasksFromCsvFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import tasks from CSV',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return 0;
    final File file = File(result.files.single.path!);
    final String content = await file.readAsString();
    return importTasksFromCsv(content);
  }
}

final Provider<ImportExportService> importExportServiceProvider = Provider<ImportExportService>(
  (ref) => ImportExportService(
    taskRepository: ref.watch(taskRepositoryProvider),
    calendarEventRepository: ref.watch(calendarEventRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    appSettingsRepository: ref.watch(appSettingsRepositoryProvider),
    themePresetRepository: ref.watch(themePresetRepositoryProvider),
  ),
);

import 'package:drift/drift.dart' show Value;

import '../../domain/models/widget_mode.dart';
import '../../domain/models/widget_preference.dart';
import '../../domain/repositories/widget_preference_repository.dart';
import '../local/dao/widget_preference_dao.dart';
import '../local/database/database.dart';

/// Named "Local..." (not "Drift...") to emphasize this repository's
/// contract: it is device-local ONLY and must never gain a Firebase-backed
/// sibling/decorator. See ARCHITECTURE.md "Sync boundaries".
class LocalWidgetPreferenceRepository implements WidgetPreferenceRepository {
  LocalWidgetPreferenceRepository(this._dao);

  final WidgetPreferenceDao _dao;

  @override
  Stream<WidgetPreference> watch() => _dao.watch().map((row) => _mapRow(row));

  @override
  Future<WidgetPreference> get() async => _mapRow(await _dao.getOnce());

  @override
  Future<void> save(WidgetPreference preference) => _dao.save(WidgetPreferencesCompanion(
        id: const Value(kDefaultWidgetPreferenceId),
        windowX: Value(preference.windowX),
        windowY: Value(preference.windowY),
        windowWidth: Value(preference.windowWidth),
        windowHeight: Value(preference.windowHeight),
        // "Window opacity" (real OS-level transparency) was removed as a
        // feature entirely (see WidgetPreference — the model no longer has
        // an `opacity` field). The DB column still exists with a `100`
        // default (see WidgetPreferences table) so it's simply never
        // written here anymore rather than requiring a schema migration to
        // drop it.
        backgroundOpacity: Value(preference.backgroundOpacity),
        cardOpacity: Value(preference.cardOpacity),
        isAlwaysOnTop: Value(preference.isAlwaysOnTop),
        isPositionLocked: Value(preference.isPositionLocked),
        isSizeLocked: Value(preference.isSizeLocked),
        showInTaskbar: Value(preference.showInTaskbar),
        widgetMode: Value(preference.widgetMode.value),
        themePresetId: Value(preference.themePresetId),
        updatedAt: Value(preference.updatedAt),
      ));

  WidgetPreference _mapRow(WidgetPreferenceRow? row) {
    if (row == null) {
      return WidgetPreference(updatedAt: DateTime.now());
    }
    return WidgetPreference(
      id: row.id,
      windowX: row.windowX,
      windowY: row.windowY,
      windowWidth: row.windowWidth,
      windowHeight: row.windowHeight,
      backgroundOpacity: row.backgroundOpacity,
      cardOpacity: row.cardOpacity,
      isAlwaysOnTop: row.isAlwaysOnTop,
      isPositionLocked: row.isPositionLocked,
      isSizeLocked: row.isSizeLocked,
      showInTaskbar: row.showInTaskbar,
      widgetMode: WidgetModePreference.fromValue(row.widgetMode),
      themePresetId: row.themePresetId,
      updatedAt: row.updatedAt,
    );
  }
}

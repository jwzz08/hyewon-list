import 'package:drift/drift.dart' show Value;

import '../../domain/models/theme_preset.dart';
import '../../domain/repositories/theme_preset_repository.dart';
import '../local/dao/theme_preset_dao.dart';
import '../local/database/database.dart';

class DriftThemePresetRepository implements ThemePresetRepository {
  DriftThemePresetRepository(this._dao);

  final ThemePresetDao _dao;

  @override
  Stream<List<ThemePreset>> watchAll() => _dao.watchAll().map((rows) => rows.map(_mapRow).toList());

  @override
  Future<ThemePreset?> getById(String id) async {
    final ThemePresetRow? row = await _dao.getById(id);
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> create(ThemePreset preset) => _dao.insertOrUpdate(_toCompanion(preset));

  @override
  Future<void> update(ThemePreset preset) => _dao.insertOrUpdate(_toCompanion(preset));

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  ThemePreset _mapRow(ThemePresetRow row) => ThemePreset(
        id: row.id,
        name: row.name,
        backgroundColor: row.backgroundColor,
        cardColor: row.cardColor,
        textColor: row.textColor,
        accentColor: row.accentColor,
        borderRadius: row.borderRadius,
        shadowIntensity: row.shadowIntensity,
        blurIntensity: row.blurIntensity,
        fontFamily: row.fontFamily,
        fontSize: row.fontSize,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  ThemePresetsCompanion _toCompanion(ThemePreset preset) => ThemePresetsCompanion(
        id: Value(preset.id),
        name: Value(preset.name),
        backgroundColor: Value(preset.backgroundColor),
        cardColor: Value(preset.cardColor),
        textColor: Value(preset.textColor),
        accentColor: Value(preset.accentColor),
        borderRadius: Value(preset.borderRadius),
        shadowIntensity: Value(preset.shadowIntensity),
        blurIntensity: Value(preset.blurIntensity),
        fontFamily: Value(preset.fontFamily),
        fontSize: Value(preset.fontSize),
        createdAt: Value(preset.createdAt),
        updatedAt: Value(preset.updatedAt),
      );
}

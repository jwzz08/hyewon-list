import '../models/theme_preset.dart';

abstract class ThemePresetRepository {
  Stream<List<ThemePreset>> watchAll();
  Future<ThemePreset?> getById(String id);
  Future<void> create(ThemePreset preset);
  Future<void> update(ThemePreset preset);
  Future<void> delete(String id);
}

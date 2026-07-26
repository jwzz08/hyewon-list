import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/theme_preset.dart';
import '../../../domain/repositories/theme_preset_repository.dart';
import 'settings_providers.dart';

final StreamProvider<List<ThemePreset>> allThemePresetsProvider =
    StreamProvider<List<ThemePreset>>((ref) => ref.watch(themePresetRepositoryProvider).watchAll());

/// The preset that drives the *entire app's* look right now — resolved
/// from `WidgetPreference.themePresetId` (set via "Apply to widget" on a
/// saved preset in Appearance settings). Falls back to
/// [ThemePreset.defaultPreset] (the original hardcoded `AppColors` values)
/// when no preset is selected, or if the selected one was since deleted.
///
/// Watched at the root of the widget tree (`HyewonListApp` in
/// `app/app.dart`), which calls `AppColors.applyPreset` and keys the whole
/// app subtree to `preset.id` so every screen — not just WidgetScreen's
/// glass frame — re-renders with the preset's colors. See
/// `core/constants/app_colors.dart`'s doc comment for the full mechanism.
final Provider<ThemePreset> activeThemePresetProvider = Provider<ThemePreset>((ref) {
  final String? selectedId = ref.watch(widgetPreferenceProvider).value?.themePresetId;
  final List<ThemePreset> presets = ref.watch(allThemePresetsProvider).value ?? const [];
  if (selectedId != null) {
    for (final ThemePreset p in presets) {
      if (p.id == selectedId) return p;
    }
  }
  return ThemePreset.defaultPreset(DateTime.now());
});

/// Thin facade over [ThemePresetRepository] for the appearance settings
/// screen, mirroring the `*Actions` pattern used elsewhere. Manages *saved
/// presets* (create/edit/duplicate/delete); which one is *active* is
/// tracked separately on `WidgetPreference.themePresetId` (see
/// [activeThemePresetProvider]).
///
/// Note: `borderRadius`/`fontSize` on a preset are still only consumed by
/// `ThemePreviewCard`'s small preview swatch — [activeThemePresetProvider]
/// currently only threads background/card/text/accent *colors* app-wide
/// (see `core/constants/app_colors.dart`); font/radius following the preset
/// everywhere is a smaller follow-up, not done in this pass.
class ThemePresetActions {
  ThemePresetActions(this._repository);

  final ThemePresetRepository _repository;

  Future<void> create(ThemePreset preset) => _repository.create(preset);

  Future<ThemePreset> createNew({
    required String name,
    required int backgroundColor,
    required int cardColor,
    required int textColor,
    required int accentColor,
    double borderRadius = 18,
    double fontSize = 13,
  }) async {
    final DateTime now = DateTime.now();
    final ThemePreset preset = ThemePreset(
      id: IdGenerator.newId(),
      name: name,
      backgroundColor: backgroundColor,
      cardColor: cardColor,
      textColor: textColor,
      accentColor: accentColor,
      borderRadius: borderRadius,
      fontSize: fontSize,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.create(preset);
    return preset;
  }

  Future<void> update(ThemePreset preset) =>
      _repository.update(preset.copyWith(updatedAt: DateTime.now()));

  Future<void> delete(String id) => _repository.delete(id);
}

final Provider<ThemePresetActions> themePresetActionsProvider = Provider<ThemePresetActions>(
  (ref) => ThemePresetActions(ref.watch(themePresetRepositoryProvider)),
);

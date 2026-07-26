import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/theme_preset.dart';
import '../../../../domain/models/widget_preference.dart';
import '../../../../shared/utils/undo_actions.dart';
import '../../../../shared/widgets/components/color_picker_dialog.dart';
import '../../../../shared/widgets/components/settings_section.dart';
import '../../../../shared/widgets/components/theme_preview_card.dart';
import '../../application/settings_providers.dart';
import '../../application/theme_preset_providers.dart';

/// Saved custom [ThemePreset]s are fully manageable here (create, edit,
/// delete) AND, via "Apply to widget" on each card, one can be picked as the
/// app's active color scheme (see activeThemePresetProvider in
/// theme_preset_providers.dart, watched at the root by `HyewonListApp` —
/// applying a preset re-colors the whole app, not just the desktop widget).
class AppearanceSettingsSection extends ConsumerWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ThemePreset> presets = ref.watch(allThemePresetsProvider).value ?? const [];
    final WidgetPreference? pref = ref.watch(widgetPreferenceProvider).value;
    final String? activePresetId = pref?.themePresetId;

    void applyToWidget(String? presetId) {
      if (pref == null) return;
      ref.read(settingsActionsProvider).saveWidgetPreference(pref.copyWith(themePresetId: presetId));
    }

    return SettingsSection(
      title: 'APPEARANCE',
      subtitle:
          'Current app colors (below) plus any saved custom presets you create. Tap "Apply to widget" on a preset to re-color the whole app.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ThemePreviewCard(opacity: 100),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Swatch(color: AppColors.accent, label: 'Accent'),
                  _Swatch(color: AppColors.bgNeutral, label: 'Background'),
                  _Swatch(color: AppColors.cardWhite, label: 'Card'),
                  _Swatch(color: AppColors.textHeading, label: 'Text'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Saved presets', style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DefaultPresetCard(isActive: activePresetId == null, onApply: () => applyToWidget(null)),
            for (final ThemePreset p in presets)
              _PresetCard(
                preset: p,
                isActive: p.id == activePresetId,
                onApply: () => applyToWidget(p.id),
              ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const _PresetEditorDialog(),
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('New preset'),
        ),
      ],
    );
  }
}

/// Represents "no preset selected" — the widget falls back to
/// [ThemePreset.defaultPreset], which matches the fixed `AppColors` tokens
/// used everywhere else in the app.
class _DefaultPresetCard extends StatelessWidget {
  const _DefaultPresetCard({required this.isActive, required this.onApply});

  final bool isActive;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    // Whole card is tappable (not just the small "Apply to widget" label
    // below) so it's easy to hit without hunting for the exact link text.
    return GestureDetector(
      onTap: onApply,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgNeutral,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
              color: isActive ? AppColors.accent : AppColors.borderLight, width: isActive ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Default', style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('hyewon_list built-in colors', style: AppTextStyles.meta(fontSize: 9)),
            const SizedBox(height: 8),
            _applyButton(isActive: isActive, onApply: onApply),
          ],
        ),
      ),
    );
  }
}

Widget _applyButton({required bool isActive, required VoidCallback onApply}) {
  if (isActive) {
    return Row(
      children: [
        Icon(Icons.check_circle, size: 13, color: AppColors.accent),
        const SizedBox(width: 4),
        Text('Active for widget',
            style: AppTextStyles.meta(fontSize: 9, color: AppColors.accentTextStrong)),
      ],
    );
  }
  return GestureDetector(
    onTap: onApply,
    child: Text(
      'Apply to widget',
      style: AppTextStyles.meta(fontSize: 9, color: AppColors.accent)
          .copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderLight),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.meta(fontSize: 9)),
      ],
    );
  }
}

class _PresetCard extends ConsumerWidget {
  const _PresetCard({required this.preset, required this.isActive, required this.onApply});

  final ThemePreset preset;
  final bool isActive;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Whole card applies the preset on tap (not just the small "Apply to
    // widget" label) — the nested edit/delete GestureDetectors below still
    // win the gesture arena for their own area, so this doesn't interfere
    // with those.
    return GestureDetector(
      onTap: onApply,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgNeutral,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
              color: isActive ? AppColors.accent : AppColors.borderLight, width: isActive ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _dot(preset.backgroundColor),
                _dot(preset.cardColor),
                _dot(preset.textColor),
                _dot(preset.accentColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              preset.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            _applyButton(isActive: isActive, onApply: onApply),
            const SizedBox(height: 6),
            Row(
              children: [
                GestureDetector(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => _PresetEditorDialog(existing: preset),
                  ),
                  child: Icon(Icons.edit_outlined, size: 14, color: AppColors.textFaint),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => deleteThemePresetWithUndo(context, ref, preset),
                  child: Icon(Icons.delete_outline, size: 14, color: AppColors.textFaint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(int color) => Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      );
}

const List<Color> _presetPalette = [
  Color(0xFFF3F5FB),
  Color(0xFFFBF4EB),
  Color(0xFFFFFFFF),
  Color(0xFF1B1E2E),
  Color(0xFF2B2D38),
  Color(0xFF8E6AC7),
  Color(0xFF398AD6),
  Color(0xFFCD76B1),
  Color(0xFF4CA871),
  Color(0xFFE15955),
  Color(0xFFDDB049),
];

class _PresetEditorDialog extends ConsumerStatefulWidget {
  const _PresetEditorDialog({this.existing});

  final ThemePreset? existing;

  @override
  ConsumerState<_PresetEditorDialog> createState() => _PresetEditorDialogState();
}

class _PresetEditorDialogState extends ConsumerState<_PresetEditorDialog> {
  late final TextEditingController _nameCtrl;
  late Color _background;
  late Color _card;
  late Color _text;
  late Color _accent;
  late double _borderRadius;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    final ThemePreset? e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _background = Color(e?.backgroundColor ?? AppColors.bgNeutral.value);
    _card = Color(e?.cardColor ?? AppColors.cardWhite.value);
    _text = Color(e?.textColor ?? AppColors.textHeading.value);
    _accent = Color(e?.accentColor ?? AppColors.accent.value);
    _borderRadius = e?.borderRadius ?? 18;
    _fontSize = e?.fontSize ?? 13;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existing != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEditing ? 'Edit preset' : 'New preset',
                    style: AppTextStyles.display(fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Preset name'),
                ),
                const SizedBox(height: 14),
                _colorPickerRow('Background', _background, (c) => setState(() => _background = c)),
                _colorPickerRow('Card', _card, (c) => setState(() => _card = c)),
                _colorPickerRow('Text', _text, (c) => setState(() => _text = c)),
                _colorPickerRow('Accent', _accent, (c) => setState(() => _accent = c)),
                const SizedBox(height: 10),
                Text('Corner radius: ${_borderRadius.round()}', style: AppTextStyles.meta()),
                Slider(
                  value: _borderRadius,
                  min: 0,
                  max: 32,
                  divisions: 32,
                  onChanged: (v) => setState(() => _borderRadius = v),
                ),
                Text('Font size: ${_fontSize.round()}', style: AppTextStyles.meta()),
                Slider(
                  value: _fontSize,
                  min: 10,
                  max: 18,
                  divisions: 8,
                  onChanged: (v) => setState(() => _fontSize = v),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorPickerRow(String label, Color selected, ValueChanged<Color> onPick) {
    // True once the selected color has been set to something outside the
    // fixed 11-swatch palette (via "Custom…" below) — shown as its own
    // highlighted swatch so picking a custom color doesn't just silently
    // deselect every visible option.
    final bool isCustom = !_presetPalette.any((c) => c.value == selected.value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyles.sectionLabel()),
              const SizedBox(width: 6),
              Text(
                '#${selected.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                style: AppTextStyles.meta(fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final Color c in _presetPalette)
                GestureDetector(
                  onTap: () => onPick(c),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected.value == c.value ? AppColors.textBody : AppColors.borderLight,
                        width: selected.value == c.value ? 2 : 1,
                      ),
                    ),
                    child: selected.value == c.value ? const _SwatchCheckmark() : null,
                  ),
                ),
              if (isCustom)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textBody, width: 2),
                  ),
                  child: const _SwatchCheckmark(),
                ),
              GestureDetector(
                onTap: () async {
                  final Color? picked =
                      await showColorPickerDialog(context, initialColor: selected);
                  if (picked != null) onPick(picked);
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  child: Icon(Icons.add, size: 13, color: AppColors.textFaint),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final String name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final ThemePresetActions actions = ref.read(themePresetActionsProvider);
    if (widget.existing != null) {
      await actions.update(widget.existing!.copyWith(
        name: name,
        backgroundColor: _background.value,
        cardColor: _card.value,
        textColor: _text.value,
        accentColor: _accent.value,
        borderRadius: _borderRadius,
        fontSize: _fontSize,
      ));
    } else {
      final ThemePreset created = await actions.createNew(
        name: name,
        backgroundColor: _background.value,
        cardColor: _card.value,
        textColor: _text.value,
        accentColor: _accent.value,
        borderRadius: _borderRadius,
        fontSize: _fontSize,
      );
      // A brand-new preset is auto-applied to the widget right away —
      // otherwise it just sits in the list looking identical to "nothing
      // happened" until the user separately finds "Apply to widget".
      final WidgetPreference? pref = ref.read(widgetPreferenceProvider).value;
      if (pref != null) {
        await ref
            .read(settingsActionsProvider)
            .saveWidgetPreference(pref.copyWith(themePresetId: created.id));
      }
    }
    if (mounted) Navigator.of(context).pop();
  }
}

/// Selection indicator for a color swatch circle, drawn *on top of* the
/// swatch instead of as a border around it — a solid-color border (this used
/// to be `AppColors.textBody`, a near-black) becomes invisible the moment the
/// user picks a color that's itself black/near-black, which read as "did my
/// tap even register?". A checkmark rendered in white with a dark outline
/// shadow has both a light and a dark component, so at least one of the two
/// always contrasts against whatever fill color sits underneath it.
class _SwatchCheckmark extends StatelessWidget {
  const _SwatchCheckmark();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.check,
        size: 13,
        color: Colors.white,
        shadows: [
          Shadow(color: Colors.black87, blurRadius: 3),
          Shadow(color: Colors.black87, offset: Offset(0.6, 0.6)),
        ],
      ),
    );
  }
}

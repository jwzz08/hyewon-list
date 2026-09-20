import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/theme_preset.dart';
import '../../../../domain/models/widget_preference.dart';
import '../../../../shared/utils/undo_actions.dart';
import '../../../../shared/widgets/components/color_picker_dialog.dart';
import '../../../settings/application/settings_providers.dart';
import '../../../settings/application/theme_preset_providers.dart';
import '../mobile_common.dart';
import 'settings_widgets.dart';

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

/// Settings > Appearance: theme presets as a tappable list (tap = apply),
/// with edit/delete in a per-row menu and a bottom-sheet preset editor.
class MobileAppearancePage extends ConsumerWidget {
  const MobileAppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ThemePreset> presets = ref.watch(allThemePresetsProvider).value ?? const [];
    final WidgetPreference? pref = ref.watch(widgetPreferenceProvider).value;
    final String? activeId = pref?.themePresetId;

    void apply(String? presetId) {
      if (pref == null) return;
      ref.read(settingsActionsProvider).saveWidgetPreference(pref.copyWith(themePresetId: presetId));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Swatch(color: AppColors.accent, label: 'Accent'),
              _Swatch(color: AppColors.bgNeutral, label: 'Background'),
              _Swatch(color: AppColors.cardWhite, label: 'Card'),
              _Swatch(color: AppColors.textHeading, label: 'Text'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SettingsGroup(
          title: 'Presets',
          footer: 'Tap a preset to re-color the whole app.',
          children: [
            _PresetRow(
              name: 'Default',
              subtitle: 'Built-in colors',
              colors: const [0xFFF3F5FB, 0xFFFFFFFF, 0xFF1B1E2E, 0xFF8E6AC7],
              active: activeId == null,
              onTap: () => apply(null),
            ),
            for (final ThemePreset p in presets)
              _PresetRow(
                name: p.name,
                colors: [p.backgroundColor, p.cardColor, p.textColor, p.accentColor],
                active: p.id == activeId,
                onTap: () => apply(p.id),
                menu: PopupMenuButton<String>(
                  tooltip: 'Preset options',
                  icon: Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
                  onSelected: (v) {
                    if (v == 'edit') {
                      showPresetEditor(context, existing: p);
                    } else {
                      deleteThemePresetWithUndo(context, ref, p);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
          ],
        ),
        BigButton(
          label: 'New preset',
          icon: Icons.add_rounded,
          filled: false,
          onPressed: () => showPresetEditor(context),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderMedium),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.meta(fontSize: 12)),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.name,
    this.subtitle,
    required this.colors,
    required this.active,
    required this.onTap,
    this.menu,
  });

  final String name;
  final String? subtitle;
  final List<int> colors;
  final bool active;
  final VoidCallback onTap;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: menu == null ? 16 : 4, top: 8, bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 30,
                child: Stack(
                  children: [
                    for (int i = 0; i < colors.length; i++)
                      Positioned(
                        left: i * 12.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Color(colors[i]),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 2)],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.body(fontSize: 16, weight: FontWeight.w700)),
                    if (subtitle != null) Text(subtitle!, style: AppTextStyles.meta(fontSize: 12.5)),
                  ],
                ),
              ),
              if (active) Icon(Icons.check_circle_rounded, color: AppColors.accent),
              if (menu != null) menu!,
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showPresetEditor(BuildContext context, {ThemePreset? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.cardWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PresetEditorSheet(existing: existing),
  );
}

class _PresetEditorSheet extends ConsumerStatefulWidget {
  const _PresetEditorSheet({this.existing});

  final ThemePreset? existing;

  @override
  ConsumerState<_PresetEditorSheet> createState() => _PresetEditorSheetState();
}

class _PresetEditorSheetState extends ConsumerState<_PresetEditorSheet> {
  late final TextEditingController _name;
  late Color _background;
  late Color _card;
  late Color _text;
  late Color _accent;
  late double _radius;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    final ThemePreset? e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _background = Color(e?.backgroundColor ?? AppColors.bgNeutral.value);
    _card = Color(e?.cardColor ?? AppColors.cardWhite.value);
    _text = Color(e?.textColor ?? AppColors.textHeading.value);
    _accent = Color(e?.accentColor ?? AppColors.accent.value);
    _radius = e?.borderRadius ?? 18;
    _fontSize = e?.fontSize ?? 13;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Same save behavior as the desktop editor: update in place, or create and
  /// immediately apply the new preset.
  Future<void> _save() async {
    final String name = _name.text.trim();
    if (name.isEmpty) return;
    final ThemePresetActions actions = ref.read(themePresetActionsProvider);
    if (widget.existing != null) {
      await actions.update(widget.existing!.copyWith(
        name: name,
        backgroundColor: _background.value,
        cardColor: _card.value,
        textColor: _text.value,
        accentColor: _accent.value,
        borderRadius: _radius,
        fontSize: _fontSize,
      ));
    } else {
      final ThemePreset created = await actions.createNew(
        name: name,
        backgroundColor: _background.value,
        cardColor: _card.value,
        textColor: _text.value,
        accentColor: _accent.value,
        borderRadius: _radius,
        fontSize: _fontSize,
      );
      final WidgetPreference? pref = ref.read(widgetPreferenceProvider).value;
      if (pref != null) {
        await ref
            .read(settingsActionsProvider)
            .saveWidgetPreference(pref.copyWith(themePresetId: created.id));
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget _colorRow(String label, Color selected, ValueChanged<Color> onPick) {
    final bool custom = !_presetPalette.any((c) => c.value == selected.value);
    Widget dot(Color c, {bool checked = false, VoidCallback? onTap}) => GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: checked ? AppColors.textBody : AppColors.borderMedium,
                width: checked ? 2.5 : 1,
              ),
            ),
            child: checked
                ? Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: c.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                  )
                : null,
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label.toUpperCase(), style: AppTextStyles.sectionLabel()),
              const SizedBox(width: 8),
              Text(
                '#${selected.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                style: AppTextStyles.meta(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final Color c in _presetPalette)
                dot(c, checked: selected.value == c.value, onTap: () => onPick(c)),
              if (custom) dot(selected, checked: true),
              GestureDetector(
                onTap: () async {
                  final Color? picked = await showColorPickerDialog(context, initialColor: selected);
                  if (picked != null) onPick(picked);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  child: Icon(Icons.add_rounded, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'New preset' : 'Edit preset',
                style: AppTextStyles.display(fontSize: 22)),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: widget.existing == null,
              style: AppTextStyles.body(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Preset name',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            _colorRow('Background', _background, (c) => setState(() => _background = c)),
            _colorRow('Card', _card, (c) => setState(() => _card = c)),
            _colorRow('Text', _text, (c) => setState(() => _text = c)),
            _colorRow('Accent', _accent, (c) => setState(() => _accent = c)),
            Text('Corner radius · ${_radius.round()}', style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w700)),
            Slider(
              value: _radius,
              min: 0,
              max: 32,
              divisions: 32,
              onChanged: (v) => setState(() => _radius = v),
            ),
            Text('Font size · ${_fontSize.round()}', style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w700)),
            Slider(
              value: _fontSize,
              min: 10,
              max: 18,
              divisions: 8,
              onChanged: (v) => setState(() => _fontSize = v),
            ),
            const SizedBox(height: 12),
            BigButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Full-spectrum color picker (hex entry + Hue/Saturation/Brightness
/// sliders) for anywhere a fixed swatch palette (see
/// AppearanceSettingsSection's theme preset editor) isn't expressive enough
/// and the user wants an exact, arbitrary color.
///
/// Deliberately built from plain Flutter widgets (`HSVColor`,
/// `TextEditingController`, `Slider`) instead of pulling in a color-picker
/// package — a new dependency here would need the same kind of version-
/// conflict vetting `win32_registry`/`file_picker` already needed (see
/// pubspec.yaml's notes on that), and isn't worth it for something this
/// small to build directly.
Future<Color?> showColorPickerDialog(BuildContext context, {required Color initialColor}) {
  return showDialog<Color>(
    context: context,
    builder: (_) => _ColorPickerDialog(initialColor: initialColor),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv;
  late final TextEditingController _hexCtrl;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
    _hexCtrl = TextEditingController(text: _hexOf(_hsv.toColor()));
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  static String _hexOf(Color c) =>
      c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

  void _updateFromHsv(HSVColor next) {
    setState(() {
      _hsv = next;
      final String hex = _hexOf(next.toColor());
      // Avoid clobbering mid-edit cursor position/selection when the
      // change originated from the hex field itself.
      if (_hexCtrl.text.toUpperCase() != hex) {
        _hexCtrl.value = TextEditingValue(text: hex);
      }
    });
  }

  void _updateFromHex(String value) {
    final String cleaned = value.replaceAll('#', '').trim();
    if (cleaned.length != 6) return;
    final int? parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null) return;
    setState(() => _hsv = HSVColor.fromColor(Color(0xFF000000 | parsed)));
  }

  @override
  Widget build(BuildContext context) {
    final Color current = _hsv.toColor();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Custom color', style: AppTextStyles.display(fontSize: 16)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: current,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _hexCtrl,
                      maxLength: 6,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]'))],
                      decoration: const InputDecoration(prefixText: '#', counterText: ''),
                      onChanged: _updateFromHex,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _slider('Hue', _hsv.hue, 0, 360, (v) => _updateFromHsv(_hsv.withHue(v))),
              _slider(
                  'Saturation', _hsv.saturation, 0, 1, (v) => _updateFromHsv(_hsv.withSaturation(v))),
              _slider('Brightness', _hsv.value, 0, 1, (v) => _updateFromHsv(_hsv.withValue(v))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(current),
                    child: const Text('Use color'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.meta()),
        SizedBox(
          height: 28,
          child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

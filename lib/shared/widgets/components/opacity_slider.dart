import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';

/// Shared 0-100% slider control used for the background/card opacity
/// settings (real OS-level "Window opacity" was removed entirely — see
/// OpacitySettingsSection's doc comment).
class OpacitySlider extends StatelessWidget {
  const OpacitySlider({super.key, required this.value, required this.onChanged, this.label});

  /// 0-100
  final double value;
  final ValueChanged<double> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w700)),
          const SizedBox(height: 6),
        ],
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.clamp(0, 100),
                min: 0,
                max: 100,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 46,
              child: Text(
                '${value.round()}%',
                textAlign: TextAlign.right,
                style: AppTextStyles.body(weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

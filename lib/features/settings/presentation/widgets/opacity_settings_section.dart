import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/widget_preference.dart';
import '../../../../shared/widgets/components/opacity_slider.dart';
import '../../../../shared/widgets/components/settings_section.dart';
import '../../../../shared/widgets/components/theme_preview_card.dart';
import '../../application/settings_providers.dart';

/// "Window opacity" (real OS-level window transparency, via
/// `WindowService.setOpacity`) was removed entirely — a flat OS alpha fades
/// everything uniformly including text/icons, which made the widget hard to
/// read at any but the highest values. "Background opacity" is the one kept:
/// applied at the content level only (WidgetScreen's glass container
/// background), it keeps text readable via an automatic scrim even when the
/// background is made very transparent — that's also what the live preview
/// card below reflects.
class OpacitySettingsSection extends ConsumerWidget {
  const OpacitySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetPreference? pref = ref.watch(widgetPreferenceProvider).value;
    final SettingsActions actions = ref.watch(settingsActionsProvider);
    if (pref == null) return const SizedBox.shrink();

    return SettingsSection(
      title: 'WIDGET OPACITY',
      subtitle:
          'Background opacity fades the widget\'s background tint only — text stays readable via an automatic scrim.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThemePreviewCard(opacity: pref.backgroundOpacity),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OpacitySlider(
                    label: 'Background opacity',
                    value: pref.backgroundOpacity,
                    onChanged: (v) =>
                        actions.saveWidgetPreference(pref.copyWith(backgroundOpacity: v)),
                  ),
                  const SizedBox(height: 10),
                  OpacitySlider(
                    label: 'Card opacity',
                    value: pref.cardOpacity,
                    onChanged: (v) => actions.saveWidgetPreference(pref.copyWith(cardOpacity: v)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

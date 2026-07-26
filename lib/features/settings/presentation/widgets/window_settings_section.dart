import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/widget_preference.dart';
import '../../../../platform/window/window_service.dart';
import '../../../../shared/widgets/components/settings_section.dart';
import '../../application/settings_providers.dart';

class WindowSettingsSection extends ConsumerWidget {
  const WindowSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetPreference? pref = ref.watch(widgetPreferenceProvider).value;
    final SettingsActions actions = ref.watch(settingsActionsProvider);
    final WindowService windowService = ref.watch(windowServiceProvider);
    if (pref == null) return const SizedBox.shrink();

    return SettingsSection(
      title: 'WINDOW',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Always on top', style: AppTextStyles.body(fontSize: 13)),
          value: pref.isAlwaysOnTop,
          onChanged: (v) {
            actions.saveWidgetPreference(pref.copyWith(isAlwaysOnTop: v));
            windowService.setAlwaysOnTop(v);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Lock position', style: AppTextStyles.body(fontSize: 13)),
          value: pref.isPositionLocked,
          onChanged: (v) {
            actions.saveWidgetPreference(pref.copyWith(isPositionLocked: v));
            windowService.setMovable(!v);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Lock size', style: AppTextStyles.body(fontSize: 13)),
          value: pref.isSizeLocked,
          onChanged: (v) {
            actions.saveWidgetPreference(pref.copyWith(isSizeLocked: v));
            windowService.setResizable(!v);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Show in taskbar', style: AppTextStyles.body(fontSize: 13)),
          subtitle: Text(
            'Turn off to hide from the taskbar/Alt+Tab — reachable via the tray icon only.',
            style: AppTextStyles.meta(fontSize: 10.5),
          ),
          value: pref.showInTaskbar,
          onChanged: (v) {
            actions.saveWidgetPreference(pref.copyWith(showInTaskbar: v));
            windowService.setSkipTaskbar(!v);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Current size: ${pref.windowWidth.round()} × ${pref.windowHeight.round()} px',
          style: AppTextStyles.meta(),
        ),
        // "Start with Windows" is already implemented in the tray menu (see
        // WindowsNativeService/WindowsTrayService) rather than duplicated
        // here. Remaining native items (real Mica/Acrylic blur, deep tray
        // balloon notifications) need native windows/runner/ C++ work — see
        // ARCHITECTURE.md "Windows native TODOs".
      ],
    );
  }
}

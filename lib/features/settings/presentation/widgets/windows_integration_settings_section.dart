import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../platform/windows_native/windows_native_service.dart';
import '../../../../shared/widgets/components/settings_section.dart';

/// "Start with Windows" (registry Run key) + a note about the global
/// click-through hotkey — both implemented via pure-Dart Win32 FFI (see
/// lib/platform/windows_native/), no `windows/runner/` C++ changes. Both
/// are best-effort; see those files' doc comments for caveats.
class WindowsIntegrationSettingsSection extends ConsumerStatefulWidget {
  const WindowsIntegrationSettingsSection({super.key});

  @override
  ConsumerState<WindowsIntegrationSettingsSection> createState() =>
      _WindowsIntegrationSettingsSectionState();
}

class _WindowsIntegrationSettingsSectionState
    extends ConsumerState<WindowsIntegrationSettingsSection> {
  @override
  Widget build(BuildContext context) {
    final WindowsNativeService native = ref.watch(windowsNativeServiceProvider);
    if (!native.isSupported) return const SizedBox.shrink();

    return SettingsSection(
      title: 'WINDOWS INTEGRATION',
      subtitle: 'Best-effort OS extras — implemented via Win32 FFI, no native build step.',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text('Start with Windows', style: AppTextStyles.body(fontSize: 12.5)),
          value: native.isStartWithWindowsEnabled(),
          onChanged: (v) => setState(() => native.setStartWithWindows(v)),
        ),
        const SizedBox(height: 6),
        Text(
          'Ctrl+Alt+H toggles click-through anywhere in Windows (mouse clicks '
          'pass through hyewon_list to whatever is behind it — press again, '
          'or use the tray icon menu, to get clicks back).',
          style: AppTextStyles.meta(fontSize: 10.5),
        ),
      ],
    );
  }
}

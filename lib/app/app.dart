import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../domain/models/theme_preset.dart';
import '../features/settings/application/theme_preset_providers.dart';
import '../features/mobile/presentation/mobile_shell.dart';
import '../platform/platform_info.dart';
import 'root_shell.dart';
import 'theme.dart';

/// Root widget. A [ConsumerWidget] (not [StatelessWidget]) specifically so
/// it can watch `activeThemePresetProvider` and make the *whole app* — not
/// just WidgetScreen's glass frame — follow the active [ThemePreset]. See
/// `core/constants/app_colors.dart`'s doc comment for the full mechanism;
/// the two things that happen here are:
///  1. `AppColors.applyPreset(preset)` updates the shared color getters
///     every other file reads as plain `AppColors.xxx`.
///  2. `RootShell` gets a `ValueKey(preset.id)`, which forces Flutter to
///     tear down and rebuild the *entire* subtree from scratch on a preset
///     change — necessary because changing a plain static field doesn't by
///     itself make any already-built widget re-run its `build()` method.
class HyewonListApp extends ConsumerWidget {
  const HyewonListApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemePreset activePreset = ref.watch(activeThemePresetProvider);
    AppColors.applyPreset(activePreset);

    return MaterialApp(
      title: 'hyewon_list',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: isMobilePlatform
          ? MobileShell(key: ValueKey('mobile_shell_${activePreset.id}'))
          : RootShell(key: ValueKey('root_shell_${activePreset.id}')),
    );
  }
}

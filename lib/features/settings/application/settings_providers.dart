import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/widget_preference.dart';
import '../../../domain/repositories/app_settings_repository.dart';
import '../../../domain/repositories/widget_preference_repository.dart';

final StreamProvider<AppSettings> appSettingsProvider =
    StreamProvider<AppSettings>((ref) => ref.watch(appSettingsRepositoryProvider).watch());

/// Convenience derived provider so calendar/planner code doesn't need to
/// unwrap [appSettingsProvider]'s AsyncValue just to read one int.
final Provider<int> startDayOfWeekProvider =
    Provider<int>((ref) => ref.watch(appSettingsProvider).value?.startDayOfWeek ?? 1);

/// Device-local — see ARCHITECTURE.md "Sync boundaries".
final StreamProvider<WidgetPreference> widgetPreferenceProvider = StreamProvider<WidgetPreference>(
  (ref) => ref.watch(widgetPreferenceRepositoryProvider).watch(),
);

class SettingsActions {
  SettingsActions(this._appSettingsRepository, this._widgetPreferenceRepository);

  final AppSettingsRepository _appSettingsRepository;
  final WidgetPreferenceRepository _widgetPreferenceRepository;

  Future<void> saveAppSettings(AppSettings settings) =>
      _appSettingsRepository.save(settings.copyWith(updatedAt: DateTime.now()));

  Future<void> saveWidgetPreference(WidgetPreference preference) =>
      _widgetPreferenceRepository.save(preference.copyWith(updatedAt: DateTime.now()));
}

final Provider<SettingsActions> settingsActionsProvider = Provider<SettingsActions>(
  (ref) => SettingsActions(
    ref.watch(appSettingsRepositoryProvider),
    ref.watch(widgetPreferenceRepositoryProvider),
  ),
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/app_settings.dart';
import '../../../../shared/widgets/components/chip_selector.dart';
import '../../../../shared/widgets/components/settings_section.dart';
import '../../application/settings_providers.dart';

/// Every toggle here is backed by real data — see holiday_service.dart
/// (Korean/Canada fixed-date + lunar KR holidays) and
/// solar_term_service.dart (24 solar terms, computed astronomically).
class CalendarSettingsSection extends ConsumerWidget {
  const CalendarSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings? settings = ref.watch(appSettingsProvider).value;
    final SettingsActions actions = ref.watch(settingsActionsProvider);
    if (settings == null) return const SizedBox.shrink();

    return SettingsSection(
      title: 'CALENDAR',
      children: [
        Row(
          children: [
            Expanded(child: Text('Start day of week', style: AppTextStyles.body(fontSize: 13))),
            ChipSelector<int>(
              options: const [1, 7],
              labelBuilder: (v) => v == 1 ? 'Monday' : 'Sunday',
              value: settings.startDayOfWeek,
              onChanged: (v) => actions.saveAppSettings(settings.copyWith(startDayOfWeek: v)),
            ),
          ],
        ),
        const Divider(height: 28),
        _toggle(
          'Show completed tasks on calendar',
          settings.showCompletedTasksOnCalendar,
          (v) => actions.saveAppSettings(settings.copyWith(showCompletedTasksOnCalendar: v)),
        ),
        _toggle(
          'Show overdue tasks',
          settings.showOverdueTasksOnCalendar,
          (v) => actions.saveAppSettings(settings.copyWith(showOverdueTasksOnCalendar: v)),
        ),
        const Divider(height: 28),
        Row(
          children: [
            Expanded(child: Text('Month view text size', style: AppTextStyles.body(fontSize: 13))),
            Text('${(settings.monthItemTextScale * 100).round()}%', style: AppTextStyles.meta()),
          ],
        ),
        Slider(
          value: settings.monthItemTextScale,
          min: 0.8,
          max: 1.8,
          divisions: 20,
          label: '${(settings.monthItemTextScale * 100).round()}%',
          onChanged: (v) => actions.saveAppSettings(settings.copyWith(monthItemTextScale: v)),
        ),
        const Divider(height: 28),
        Text('HOLIDAYS', style: AppTextStyles.sectionLabel()),
        const SizedBox(height: 8),
        _toggle(
          'Show Korean holidays',
          settings.showKoreanHolidays,
          (v) => actions.saveAppSettings(settings.copyWith(showKoreanHolidays: v)),
        ),
        _toggle(
          'Show Canada/Vancouver holidays',
          settings.showCanadaHolidays,
          (v) => actions.saveAppSettings(settings.copyWith(showCanadaHolidays: v)),
        ),
        _toggle(
          'Show lunar calendar (Seollal, Chuseok, Buddha\'s Birthday)',
          settings.showLunarCalendar,
          (v) => actions.saveAppSettings(settings.copyWith(showLunarCalendar: v)),
        ),
        const SizedBox(height: 4),
        Text(
          'Lunar holiday dates are covered for 2020-2040.',
          style: AppTextStyles.meta(fontSize: 10.5),
        ),
        const SizedBox(height: 6),
        _toggle(
          'Show 24 solar terms (24절기)',
          settings.showSolarTerms,
          (v) => actions.saveAppSettings(settings.copyWith(showSolarTerms: v)),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: AppTextStyles.body(fontSize: 12.5)),
      value: value,
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/app_settings.dart';
import '../../../settings/application/settings_providers.dart';
import 'settings_widgets.dart';

/// Settings > Calendar, laid out as iOS-style grouped rows.
class MobileCalendarSettingsPage extends ConsumerWidget {
  const MobileCalendarSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings? s = ref.watch(appSettingsProvider).value;
    final SettingsActions actions = ref.watch(settingsActionsProvider);
    if (s == null) return const SizedBox.shrink();
    void save(AppSettings next) => actions.saveAppSettings(next);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroup(
          title: 'Week starts on',
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedTabs<int>(
                options: const {1: 'Monday', 7: 'Sunday'},
                value: s.startDayOfWeek,
                onChanged: (v) => save(s.copyWith(startDayOfWeek: v)),
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Show on calendar',
          children: [
            SettingsSwitchRow(
              label: 'Completed tasks',
              value: s.showCompletedTasksOnCalendar,
              onChanged: (v) => save(s.copyWith(showCompletedTasksOnCalendar: v)),
            ),
            SettingsSwitchRow(
              label: 'Overdue tasks',
              value: s.showOverdueTasksOnCalendar,
              onChanged: (v) => save(s.copyWith(showOverdueTasksOnCalendar: v)),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Month view text size',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('A', style: AppTextStyles.body(fontSize: 13, color: AppColors.textSecondary)),
                      Expanded(
                        child: Slider(
                          value: s.monthItemTextScale,
                          min: 0.8,
                          max: 1.8,
                          divisions: 20,
                          onChanged: (v) => save(s.copyWith(monthItemTextScale: v)),
                        ),
                      ),
                      Text('A', style: AppTextStyles.body(fontSize: 22, color: AppColors.textSecondary)),
                    ],
                  ),
                  Text(
                    '${(s.monthItemTextScale * 100).round()}%',
                    style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Holidays & seasons',
          footer: 'Shown as small labels in the month grid, separate from your own events.',
          children: [
            SettingsSwitchRow(
              label: 'Korean holidays',
              subtitle: 'Public holidays in Korea',
              value: s.showKoreanHolidays,
              onChanged: (v) => save(s.copyWith(showKoreanHolidays: v)),
            ),
            SettingsSwitchRow(
              label: 'Canada / Vancouver holidays',
              subtitle: 'Statutory holidays',
              value: s.showCanadaHolidays,
              onChanged: (v) => save(s.copyWith(showCanadaHolidays: v)),
            ),
            SettingsSwitchRow(
              label: 'Lunar holidays',
              subtitle: "Seollal, Chuseok, Buddha's Birthday · 2020–2040",
              value: s.showLunarCalendar,
              onChanged: (v) => save(s.copyWith(showLunarCalendar: v)),
            ),
            SettingsSwitchRow(
              label: 'Solar terms (24절기)',
              subtitle: 'The 24 seasonal markers',
              value: s.showSolarTerms,
              onChanged: (v) => save(s.copyWith(showSolarTerms: v)),
            ),
          ],
        ),
      ],
    );
  }
}

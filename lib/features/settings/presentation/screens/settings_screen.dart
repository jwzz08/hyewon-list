import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/appearance_settings_section.dart';
import '../widgets/calendar_settings_section.dart';
import '../widgets/categories_tags_settings_section.dart';
import '../widgets/data_settings_section.dart';
import '../widgets/opacity_settings_section.dart';
import '../widgets/window_settings_section.dart';
import '../widgets/windows_integration_settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgNeutral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text('Settings', style: AppTextStyles.display()),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OpacitySettingsSection(),
                      WindowSettingsSection(),
                      WindowsIntegrationSettingsSection(),
                      AppearanceSettingsSection(),
                      CategoriesTagsSettingsSection(),
                      CalendarSettingsSection(),
                      DataSettingsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

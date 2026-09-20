import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../settings/presentation/widgets/appearance_settings_section.dart';
import '../../settings/presentation/widgets/calendar_settings_section.dart';
import '../../settings/presentation/widgets/categories_tags_settings_section.dart';
import '../../settings/presentation/widgets/data_settings_section.dart';
import 'mobile_common.dart';

/// "Settings" tab: a grouped list that drills into the existing (shared)
/// settings sections. Desktop-only sections (opacity, window, Windows
/// integration) are intentionally not included.
class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({super.key});

  void _open(BuildContext context, String title, Widget body) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _SettingsPage(title: title, child: body)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
            child: Text('Settings', style: AppTextStyles.display(fontSize: 32)),
          ),
          MobileCard(
            child: Column(
              children: [
                _Row(
                  icon: Icons.person_outline_rounded,
                  label: 'Account',
                  onTap: () => _open(
                    context,
                    'Account',
                    const DataSettingsSection(part: DataSettingsPart.account),
                  ),
                ),
                _divider(),
                _Row(
                  icon: Icons.cloud_sync_outlined,
                  label: 'Cloud sync',
                  onTap: () => _open(
                    context,
                    'Cloud sync',
                    const DataSettingsSection(part: DataSettingsPart.sync),
                  ),
                ),
                _divider(),
                _Row(
                  icon: Icons.save_alt_rounded,
                  label: 'Backup (JSON)',
                  onTap: () => _open(
                    context,
                    'Backup (JSON)',
                    const DataSettingsSection(part: DataSettingsPart.backup),
                  ),
                ),
                _divider(),
                _Row(
                  icon: Icons.table_chart_outlined,
                  label: 'Tasks (CSV)',
                  onTap: () => _open(
                    context,
                    'Tasks (CSV)',
                    const DataSettingsSection(part: DataSettingsPart.csv),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MobileCard(
            child: Column(
              children: [
                _Row(
                  icon: Icons.palette_outlined,
                  label: 'Appearance',
                  onTap: () => _open(context, 'Appearance', const AppearanceSettingsSection()),
                ),
                _divider(),
                _Row(
                  icon: Icons.calendar_month_outlined,
                  label: 'Calendar',
                  onTap: () => _open(context, 'Calendar', const CalendarSettingsSection()),
                ),
                _divider(),
                _Row(
                  icon: Icons.label_outline_rounded,
                  label: 'Categories',
                  onTap: () => _open(context, 'Categories', const CategoriesTagsSettingsSection()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 56, color: AppColors.borderLight);
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.accentTextStrong),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.body(fontSize: 15, weight: FontWeight.w700)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.bgNeutral,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textHeading,
        title: Text(title, style: AppTextStyles.display(fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/models/widget_mode.dart';

/// Icon sidebar shown once the window is wide enough (see
/// AppBreakpoints.plannerMin) to fit navigation chrome alongside content.
class NavRail extends StatelessWidget {
  const NavRail({super.key, required this.selected, required this.onSelect});

  final AppScreen selected;
  final ValueChanged<AppScreen> onSelect;

  static const List<(AppScreen, IconData, String)> _items = [
    (AppScreen.widget, Icons.widgets_outlined, 'Widget'),
    (AppScreen.planner, Icons.view_week_outlined, 'Planner'),
    (AppScreen.month, Icons.calendar_month_outlined, 'Month'),
    (AppScreen.search, Icons.search, 'Search'),
    (AppScreen.settings, Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: AppColors.cardWhite,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Animated memoji logo (assets/img/hyewon-logo.gif), clipped into
          // a small circular avatar to fit the 76px-wide rail — replaces the
          // old plain-text "DL" wordmark placeholder. Image.asset decodes
          // and auto-plays animated GIFs natively, no extra package needed.
          ClipOval(
            child: Image.asset(
              'assets/img/hyewon-logo.gif',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          for (final (AppScreen screen, IconData icon, String label) in _items)
            _NavRailItem(
              icon: icon,
              label: label,
              selected: selected == screen,
              onTap: () => onSelect(screen),
            ),
        ],
      ),
    );
  }
}

class _NavRailItem extends StatelessWidget {
  const _NavRailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentTint : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? AppColors.accent : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.meta(
                  fontSize: 9,
                  color: selected ? AppColors.accent : AppColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

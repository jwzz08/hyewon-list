import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.tint,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Optional tint background (used for the "Size continuum" info card in
  /// the mockup, which sits on a pale purple background).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tint ?? AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: tint == null ? Border.all(color: AppColors.borderLight) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionLabel()),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextStyles.meta()),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

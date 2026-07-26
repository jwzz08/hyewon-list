import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Live miniature preview of the widget's glass effect at the current
/// opacity — used in Settings so the opacity slider has instant visual
/// feedback (matches the mockup's "Widget opacity" card exactly).
class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({super.key, required this.opacity});

  /// 0-100
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final double alpha = (opacity / 100).clamp(0.0, 1.0) * 0.9;
    return Container(
      height: 90,
      width: 150,
      padding: const EdgeInsets.all(10),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.widgetWallpaperGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.white.withOpacity(alpha),
            child: Text(
              'Today · 3 left',
              style: AppTextStyles.body(fontSize: 11, weight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

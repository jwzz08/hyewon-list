import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Donut-shaped progress indicator (SVG ring in the mockup; here built from
/// two stacked [CircularProgressIndicator]s so it needs no custom painter).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 44,
    this.strokeWidth = 5,
    this.centerLabel,
  });

  /// 0.0 - 1.0
  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? centerLabel;

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.borderLight),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          if (centerLabel != null) centerLabel!,
        ],
      ),
    );
  }
}

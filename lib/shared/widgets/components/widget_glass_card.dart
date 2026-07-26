import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';

/// A translucent "card" wrapper used *only* inside the desktop widget's own
/// content views (WidgetCompactView/WidgetExpandedView) to visually
/// separate individual rows (tasks, the next-event line) from the outer
/// glass frame. Its opacity is driven by `WidgetPreference.cardOpacity`
/// ("Card opacity" in Settings > Widget opacity) — independent of the
/// frame's own "Background opacity" (see WidgetScreen's _GlassFrame).
///
/// Deliberately NOT used by [TaskRow]/[EventCard] themselves — those are
/// shared with the full planner/search screens, which must stay opaque and
/// unaffected by widget-only opacity settings. This wraps them only at the
/// call sites inside widget_mode/presentation/widgets/.
class WidgetGlassCard extends StatelessWidget {
  const WidgetGlassCard({
    super.key,
    required this.opacity,
    required this.child,
    this.margin,
  });

  /// 0-100 — see `WidgetPreference.cardOpacity`.
  final double opacity;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    // Capped below full white (0.55 max) so even at 100% card opacity the
    // outer glass frame's own tint/blur still shows through a little —
    // matches the layered-glass look of the rest of widget mode instead of
    // becoming a flat opaque white card.
    final double alpha = (opacity / 100).clamp(0.0, 1.0) * 0.55;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(alpha),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: child,
    );
  }
}

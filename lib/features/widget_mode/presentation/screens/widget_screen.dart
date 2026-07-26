import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../app/providers.dart';
import '../../../../domain/models/theme_preset.dart';
import '../../../settings/application/settings_providers.dart';
import '../../../settings/application/theme_preset_providers.dart';
import '../../application/widget_mode_providers.dart';
import '../widgets/widget_compact_view.dart';
import '../widgets/widget_expanded_view.dart';

/// The frameless, transparent desktop widget — hyewon_list's centerpiece.
/// Fills the entire (transparent) OS window; WidgetScreen never shows window
/// chrome (no titlebar), matching `DayLayer Design.html`'s "Widget — Small &
/// Resizable" section: content reflows through 4 fluid tiers purely based on
/// width, and the frame morphs into a pill shape below 300px.
///
/// There are exactly three ways this window's size ever changes, by design:
/// 1. The small chromeless "memo" widget (this screen, shown directly by
///    RootShell below AppBreakpoints.plannerMin) — sized wherever it was
///    last left (see WidgetPreference), no drag-resize.
/// 2. [_ExpandButton], shown only in that small/memo state — one tap jumps
///    straight to [menuBarModeSize], crossing plannerMin so RootShell swaps
///    in the full nav-chrome shell.
/// 3. Free OS-native edge-drag resize (see DragToResizeArea in
///    root_shell.dart), available only once the nav-chrome shell is
///    showing — dragging back down below plannerMin returns to state 1 at
///    whatever width the user stopped at.
///
/// An earlier version let the user freely drag a corner handle here too,
/// and before that cycled through 4 preset tier sizes via this same button
/// — both were dropped in favor of this simpler 3-state model. [showExpandButton]
/// is `false` when RootShell renders this screen embedded as the "Widget" tab
/// inside the nav-chrome shell (see `_buildScreen`), since state 2/3 already
/// cover getting in and out of that size range and a jump-to-self button
/// there would be meaningless.
class WidgetScreen extends ConsumerWidget {
  const WidgetScreen({super.key, this.showExpandButton = true});

  final bool showExpandButton;

  // Pinned at the old mini/compact boundary (300px wide) so the window
  // physically can't shrink into the removed single-line "mini" tier's
  // dead zone anymore — see WidgetTierBreakpoints' doc comment.
  static const Size minSize = Size(300, 220);
  static const Size maxSize = Size(760, 600);

  /// Target for [_ExpandButton] — comfortably past AppBreakpoints.plannerMin
  /// so the nav-chrome shell reliably shows, with enough room for the nav
  /// rail plus planner/month content to not feel cramped on first arrival.
  static const Size menuBarModeSize = Size(1200, 800);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetTier tier = ref.watch(widgetTierProvider);
    // "Window opacity" (real OS-level window transparency) was removed
    // entirely — this content-level frame only ever reads "Background
    // opacity", which is what it always visually represented anyway.
    final double backgroundOpacity = ref.watch(widgetPreferenceProvider).value?.backgroundOpacity ?? 100;
    final ThemePreset activePreset = ref.watch(activeThemePresetProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: _GlassFrame(
              opacity: backgroundOpacity,
              backgroundColor: Color(activePreset.backgroundColor),
              child: _buildContent(tier),
            ),
          ),
          // Invisible top-edge strip — the only way to move this window.
          // There's no titlebar here (WidgetScreen is fully chromeless), and
          // wrapping the *whole* frame in a drag region would fight with
          // ListView scrolling inside the compact/expanded tiers (both are
          // pan gestures competing for the same pointer), so this mirrors
          // CustomWindowTitleBar's approach of a slim dedicated drag strip
          // instead — just transparent here since the widget has no visible
          // titlebar to put it in. `DragToMoveArea` (same window_manager
          // widget the real titlebar uses) already no-ops correctly when
          // Settings > Window > "Lock position" has called
          // `WindowService.setMovable(false)`, so this doesn't need its own
          // locked/unlocked branch.
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 18,
            child: DragToMoveArea(child: SizedBox.expand()),
          ),
          if (showExpandButton) const Positioned(right: 8, top: 8, child: _ExpandButton()),
        ],
      ),
    );
  }

  Widget _buildContent(WidgetTier tier) {
    switch (tier) {
      case WidgetTier.compact:
        return const WidgetCompactView();
      case WidgetTier.expanded:
        return const WidgetExpandedView(showWeekBar: false);
      case WidgetTier.expandedWithWeekBar:
        return const WidgetExpandedView(showWeekBar: true);
    }
  }
}

class _GlassFrame extends StatelessWidget {
  const _GlassFrame({
    required this.opacity,
    required this.backgroundColor,
    required this.child,
  });

  /// "Background opacity" — the glass frame's own tint alpha (0-100).
  final double opacity;

  /// The active Appearance preset's background color (see
  /// activeThemePresetProvider) — previously hardcoded to white regardless
  /// of what was configured in Settings > Appearance.
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMini = constraints.maxWidth < 300;
      final double radius = isMini && constraints.maxHeight.isFinite
          ? constraints.maxHeight / 2
          : 26;

      // Mirrors the mockup's frameAlpha/frameScrim formulas: glass alpha
      // scales with the opacity slider, plus an automatic readability
      // scrim below 45% opacity so text never becomes illegible even when
      // the widget is made very transparent (spec 4.5).
      final double frameAlpha = (opacity / 100).clamp(0.0, 1.0) * 0.9;
      final double scrim = (45 - opacity).clamp(0, 45) / 45 * 0.3;
      const double blurSigma = 24;

      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity((frameAlpha + scrim).clamp(0.0, 1.0)),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withOpacity(0.6)),
              boxShadow: const [
                BoxShadow(color: Color(0x80081020), blurRadius: 64, offset: Offset(0, 26)),
              ],
            ),
            child: child,
          ),
        ),
      );
    });
  }
}

/// One tap jumps straight from the small memo widget to
/// [WidgetScreen.menuBarModeSize] (see the class doc there for the full
/// 3-state model). A single [WindowService.setSize] call per tap is
/// inherently smooth — no per-frame native round-trips to coalesce, no
/// mid-drag disposed-`ref` race to guard against. Persisting the new size
/// to [WidgetPreference] is already handled by RootShell's `onResize`
/// listener (see `_scheduleGeometryPersist` in root_shell.dart), which
/// fires for *any* resize regardless of source, so this button doesn't
/// need to duplicate that.
class _ExpandButton extends ConsumerWidget {
  const _ExpandButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Unlabeled by design (the widget has no room for text chrome), which
    // read as "what is this circle?" with no way to find out short of
    // clicking it — a hover Tooltip answers that without adding any visible
    // chrome to the frame itself. The visible black circular backdrop that
    // used to sit behind the icon at rest was removed per feedback — just
    // the icon now, with only a subtle ripple on actual interaction (the
    // transparent Material below still gives InkWell a valid ink surface to
    // splash onto without painting anything when idle).
    return Tooltip(
      message: 'Expand to full window',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          // RootShell's chromeless-vs-nav-chrome decision is driven by
          // MediaQuery (the real Flutter viewport size), not
          // currentWindowSizeProvider, so there's nothing to optimistically
          // update here — the nav-chrome shell appears as soon as the OS
          // actually finishes resizing and Flutter's next frame reports the
          // new viewport, which for a single setSize call is effectively
          // instant.
          onTap: () {
            // Remember the widget's size right before jumping to the big
            // nav-chrome window so the reverse "shrink back" button (see
            // _ShrinkToWidgetButton in custom_window_title_bar.dart) can
            // restore exactly this, instead of some arbitrary fixed size.
            ref.read(lastWidgetSizeProvider.notifier).state =
                ref.read(currentWindowSizeProvider);
            ref.read(windowServiceProvider).setSize(WidgetScreen.menuBarModeSize);
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            // White + a dark shadow (rather than plain white, which relied
            // on the now-removed black circle for contrast) keeps this
            // readable over any glass-frame background color/theme preset —
            // same trick as the preset color-swatch checkmark.
            child: Icon(
              Icons.open_in_full,
              size: 14,
              color: Colors.white.withOpacity(0.9),
              shadows: const [
                Shadow(color: Colors.black54, blurRadius: 3),
                Shadow(color: Colors.black54, offset: Offset(0.5, 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

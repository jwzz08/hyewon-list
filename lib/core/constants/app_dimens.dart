/// Spacing, radius and responsive-breakpoint tokens shared across the app.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double screenPadding = 40;
}

abstract final class AppRadii {
  static const double xs = 4;
  static const double sm = 7;
  static const double md = 9;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 20;
  static const double card = 18;
  static const double pill = 999;
}

/// Width breakpoints for the hyewon_list window.
///
/// The desktop *widget* itself has its own fluid continuum (see
/// [WidgetTierBreakpoints]) that is a subset of the "Widget" range below —
/// these top-level breakpoints decide which top-level *screen/mode* the
/// root shell shows.
abstract final class AppBreakpoints {
  /// Below this: only the chromeless widget is shown (no nav chrome fits).
  static const double widgetOnlyMax = 760;

  /// 760–1200: Planner tier — nav rail + weekly planner as default screen.
  static const double plannerMin = 760;

  /// >= 1200: Full calendar tier — plenty of room for the monthly grid +
  /// a detail side panel.
  static const double fullCalendarMin = 1200;
}

/// Fluid width tiers for the desktop widget's own internal responsive layout
/// (see WidgetScreen). These mirror the DayLayer Design.html mockup exactly.
///
/// The single-line "mini" tier (< 300px, date + remaining count + next
/// event text only, no list) was removed — shrinking the window that far
/// hid the actual task list, which read as "everything disappeared" rather
/// than a useful compact mode. [WidgetScreen.minSize] is now pinned at 300
/// (the old mini/compact boundary) so the window physically can't shrink
/// into that dead zone anymore; `compact` is the smallest tier there is.
abstract final class WidgetTierBreakpoints {
  static const double compactMax = 480;
  static const double expandedMax = 640; // above this: expanded + week bar
}

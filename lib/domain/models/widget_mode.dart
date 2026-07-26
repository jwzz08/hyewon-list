/// The user's *preferred/last* widget mode, persisted in [WidgetPreference].
///
/// This is distinct from the *live* responsive tier computed from the actual
/// window width at any given moment (see
/// features/widget_mode/application/widget_mode_providers.dart) — the widget
/// always reflows to fit its current size, but we remember which mode the
/// user last intentionally resized to, so relaunching the app can restore it.
enum WidgetModePreference {
  minimal('minimal'),
  compact('compact'),
  expanded('expanded'),
  planner('planner'),
  fullCalendar('full_calendar');

  const WidgetModePreference(this.value);
  final String value;

  static WidgetModePreference fromValue(String value) =>
      WidgetModePreference.values.firstWhere(
        (m) => m.value == value,
        orElse: () => WidgetModePreference.expanded,
      );
}

/// Which top-level screen the root shell is displaying when the window is
/// wide enough to show navigation chrome.
enum AppScreen {
  widget,
  planner,
  month,
  search,
  settings,
}

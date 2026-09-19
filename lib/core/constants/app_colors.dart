import 'package:flutter/material.dart';

import '../../domain/models/theme_preset.dart';

/// Design tokens extracted from `DayLayer Design.html`.
///
/// Color families:
///  - Neutral (cool blue-gray, hue ~275): body text, borders, app chrome.
///  - Warm neutral (hue ~75): planner/task-list/settings backgrounds.
///  - Accent (purple, hue ~300): the single brand/primary color.
///  - Category colors: Work (blue), Study (purple), Personal (pink), Home (green).
///  - Priority colors: High (red), Medium (amber), Low (green).
///
/// **Theming**: [accent]/[textHeading]/[textBody]/[textSecondary]/
/// [textFaint]/[borderLight]/[borderMedium]/[bgNeutral]/[cardWhite]/
/// [todayTint]/[dragOverTint] (plus the `accent*` family) are *not* plain
/// constants — they're getters backed by [applyPreset], so the whole app
/// (not just WidgetScreen) follows the active [ThemePreset]. See
/// [applyPreset]'s doc comment for exactly how that works and why every
/// call site here still reads as a simple `AppColors.xxx` property access.
/// Category/priority colors stay fixed regardless of preset — they're
/// semantic (red = high priority), not decorative.
abstract final class AppColors {
  // ==========================================================================
  // Themeable tokens — see `applyPreset` below.
  // ==========================================================================

  static Color _accent = _defaultAccent;
  static Color _text = _defaultText;
  static Color _background = _defaultBackground;
  static Color _card = _defaultCard;

  /// True once a *real* (non-default) [ThemePreset] has been applied. While
  /// false, every derived getter below returns the exact original
  /// hand-tuned hex constant (not a formula-derived approximation) so
  /// nobody who never touches Appearance settings sees any visual drift
  /// from before this file supported theming at all.
  static bool _isCustomPreset = false;

  static const Color _defaultAccent = Color(0xFF8E6AC7);
  static const Color _defaultText = Color(0xFF1B1E2E);
  static const Color _defaultBackground = Color(0xFFF3F5FB);
  static const Color _defaultCard = Color(0xFFFFFFFF);

  /// Applies [preset]'s 4 base colors app-wide (background/card/text/accent)
  /// and every derived shade (tints, borders, dark/light variants) computed
  /// from them. Called every time `HyewonListApp` (`app/app.dart`) rebuilds
  /// in response to `activeThemePresetProvider` changing — that same rebuild
  /// also re-keys `RootShell` to `preset.id`, which forces every widget in
  /// the tree to actually rebuild and re-read these getters, since plain
  /// static fields aren't part of Flutter's own dependency/rebuild graph.
  ///
  /// [preset] with id `'default'` (see `ThemePreset.defaultPreset`) restores
  /// the exact original constants instead of running the derivation
  /// formulas below, so the no-preset-selected experience never drifts.
  static void applyPreset(ThemePreset preset) {
    _isCustomPreset = preset.id != 'default';
    _accent = Color(preset.accentColor);
    _text = Color(preset.textColor);
    _background = Color(preset.backgroundColor);
    _card = Color(preset.cardColor);
  }

  static Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  // --- Brand / accent ---
  static Color get accent => _accent;
  static Color get accentIcon =>
      _isCustomPreset ? _mix(_accent, Colors.black, 0.10) : const Color(0xFF7F5BB6);
  static Color get accentDark =>
      _isCustomPreset ? _mix(_accent, Colors.black, 0.35) : const Color(0xFF623E96);
  static Color get accentOnDark =>
      _isCustomPreset ? _mix(_accent, Colors.white, 0.30) : const Color(0xFFB7A0E4);
  static Color get accentTintLight =>
      _isCustomPreset ? _mix(_accent, Colors.white, 0.87) : const Color(0xFFEBE4FA);
  static Color get accentTintLighter =>
      _isCustomPreset ? _mix(_accent, Colors.white, 0.92) : const Color(0xFFF4EFFF);
  static Color get accentTintLightest =>
      _isCustomPreset ? _mix(_accent, Colors.white, 0.95) : const Color(0xFFF7F3FF);
  static Color get accentTint =>
      _isCustomPreset ? _mix(_accent, Colors.white, 0.90) : const Color(0xFFF0ECFA);
  static Color get accentTextLabel =>
      _isCustomPreset ? _mix(_accent, Colors.black, 0.40) : const Color(0xFF5E4784);
  static Color get accentTextStrong =>
      _isCustomPreset ? _mix(_accent, Colors.black, 0.58) : const Color(0xFF432B66);
  static Color get accentBorder =>
      _isCustomPreset ? _mix(_accent, Colors.white, 0.68) : const Color(0xFFD1C8E5);

  // --- Category colors (fixed — semantic, not decorative) ---
  static const Color categoryWork = Color(0xFF398AD6);
  static const Color categoryWorkTint = Color(0xFFEBF3FC);

  /// Deliberately aliases [accent] (always has, even before theming existed)
  /// — the "Study" category is the one category that intentionally matches
  /// the brand/accent color.
  static Color get categoryStudy => accent;
  static Color get categoryStudyTint => accentTint;
  static const Color categoryPersonal = Color(0xFFCD76B1);
  static const Color categoryPersonalTint = Color(0xFFF9EEF5);
  static const Color categoryHome = Color(0xFF4CA871);
  static const Color categoryHomeTint = Color(0xFFE5F3E9);

  // --- Priority colors (fixed — semantic, not decorative) ---
  static const Color priorityHigh = Color(0xFFE15955);
  static const Color priorityHighTint = Color(0xFFFFEDEB);
  static const Color priorityHighText = Color(0xFFB94642);
  static const Color priorityMedium = Color(0xFFDDB049);
  static const Color priorityMediumTint = Color(0xFFFBF1DC);
  static const Color priorityMediumText = Color(0xFF8C6C1F);
  static const Color priorityLow = Color(0xFF4CA871);
  static const Color priorityLowTint = Color(0xFFE5F3E9);

  /// Offered in the Add/Edit event dialog's color picker — lets an event's
  /// month-view chip/bar color be chosen per-event, independent of its
  /// category. The first four reuse the category colors (so "matches its
  /// category" is still one tap away); the rest fill out the palette.
  ///
  /// **Correction**: this used to list both [categoryHome] and [priorityLow]
  /// — both `0xFF4CA871`, the exact same green. Two swatches sharing one
  /// value meant `_colorOverride == c.value` in AddItemDialog's color picker
  /// matched both at once, so tapping either one always visually selected
  /// two swatches together. Swapped the duplicate for a distinct olive/lime
  /// tone so every swatch here is a unique, single-selectable color.
  static List<Color> get eventColorPalette => [
        categoryWork,
        categoryStudy,
        categoryPersonal,
        categoryHome,
        priorityHigh,
        priorityMedium,
        const Color(0xFF8FA83D),
        const Color(0xFF3D9DBF),
        const Color(0xFFBF6A3D),
        const Color(0xFF6A6ABF),
      ];

  // --- Neutral text scale ---
  static Color get textHeading => _text;
  static Color get textBody =>
      _isCustomPreset ? _mix(_text, _background, 0.08) : const Color(0xFF2B2D38);
  static Color get textSecondary =>
      _isCustomPreset ? _mix(_text, _background, 0.45) : const Color(0xFF656875);
  static Color get textFaint =>
      _isCustomPreset ? _mix(_text, _background, 0.68) : const Color(0xFF9A9EAB);
  static Color get borderLight =>
      _isCustomPreset ? _mix(_text, _background, 0.85) : const Color(0xFFE3E4EA);
  static Color get borderMedium =>
      _isCustomPreset ? _mix(_text, _background, 0.65) : const Color(0xFFB3B7C5);

  // --- Backgrounds ---
  static Color get bgNeutral => _background;

  /// Warm-toned background zones (planner/task-list) flatten to the same
  /// preset background when a custom preset is active — the preset only
  /// exposes one "background" color, so there's no separate warm variant to
  /// derive without inventing a second color the user never chose.
  static Color get bgWarm => _isCustomPreset ? _background : const Color(0xFFFBF4EB);
  static Color get borderWarm => _isCustomPreset ? borderLight : const Color(0xFFE6E0D9);
  static Color get cardWhite => _card;
  static Color get monthOverflowBg =>
      _isCustomPreset ? _mix(_background, _text, 0.03) : const Color(0xFFF7F8FB);
  static const Color monthOverflowText = Color(0xFFC7C9D3);

  // --- Widget (desktop glass) — decorative preview only, not preset-driven ---
  static const List<Color> widgetWallpaperGradient = [
    Color(0xFF101A2C),
    Color(0xFF1C2F4E),
    Color(0xFF31517F),
    Color(0xFF5C7FAC),
  ];
  static const Color widgetGlow = Color(0xFFA890D4);
  static const Color widgetDarkPanel = Color(0x8C10182A); // rgba(16,24,42,0.55)

  // --- Calendar states ---
  static Color get todayTint =>
      _isCustomPreset ? _mix(_accent, _background, 0.85) : const Color(0xFFF2EBFC);
  static Color get dragOverTint =>
      _isCustomPreset ? _mix(_accent, _background, 0.88) : const Color(0xFFEBE4FA);

  /// A selected/focused *non-today* day's background (see WeeklyDayColumn) —
  /// deliberately mixed from `_text`/`_background` (neutral gray family)
  /// rather than `_accent`/`_background` (today's purple family, same as
  /// [todayTint]) so the two states stay visually distinguishable even under
  /// a custom preset, where both would otherwise derive from the same accent
  /// color and look nearly identical. Previously this reused
  /// [accentTintLighter], which read as "the same purple" as [todayTint].
  static Color get selectedDayTint =>
      _isCustomPreset ? _mix(_text, _background, 0.90) : const Color(0xFFEAF1FB);

  /// Priority -> color helpers.
  static Color forPriorityLevel(String priority) {
    switch (priority) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
      default:
        return priorityLow;
    }
  }

  static Color tintForPriorityLevel(String priority) {
    switch (priority) {
      case 'high':
        return priorityHighTint;
      case 'medium':
        return priorityMediumTint;
      case 'low':
      default:
        return priorityLowTint;
    }
  }
}

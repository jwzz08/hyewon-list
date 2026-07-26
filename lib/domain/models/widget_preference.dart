import 'widget_mode.dart';

/// Device-local window/widget state. **Never syncs to Firebase** — every
/// device (desktop, future iOS/web) keeps its own window geometry/opacity.
/// See ARCHITECTURE.md "Sync boundaries".
class WidgetPreference {
  const WidgetPreference({
    this.id = 'default',
    this.windowX,
    this.windowY,
    this.windowWidth = 360,
    this.windowHeight = 480,
    this.backgroundOpacity = 100,
    this.cardOpacity = 100,
    this.isAlwaysOnTop = false,
    this.isPositionLocked = false,
    this.isSizeLocked = false,
    this.showInTaskbar = true,
    this.widgetMode = WidgetModePreference.expanded,
    this.themePresetId,
    required this.updatedAt,
  });

  final String id;
  final double? windowX;
  final double? windowY;
  final double windowWidth;
  final double windowHeight;

  /// 0-100, background layer opacity (independent slider per spec §4.5).
  /// Applied at the content level only (WidgetScreen's glass frame
  /// background tint) so text stays readable via an automatic scrim even
  /// when this is turned down low — see OpacitySettingsSection.
  final double backgroundOpacity;

  /// 0-100, card/content opacity. Applied to individual row "cards" inside
  /// the widget's compact/expanded content views (see WidgetGlassCard) —
  /// distinct from the outer frame's own [backgroundOpacity].
  final double cardOpacity;

  final bool isAlwaysOnTop;
  final bool isPositionLocked;
  final bool isSizeLocked;

  /// Whether the window has a taskbar entry/Alt+Tab presence (Windows) —
  /// see WindowService.setSkipTaskbar. Defaults to true (normal window
  /// behavior); turning it off hides the window from the taskbar so it's
  /// only reachable via the tray icon.
  final bool showInTaskbar;
  final WidgetModePreference widgetMode;
  final String? themePresetId;
  final DateTime updatedAt;

  WidgetPreference copyWith({
    Object? windowX = _sentinel,
    Object? windowY = _sentinel,
    double? windowWidth,
    double? windowHeight,
    double? backgroundOpacity,
    double? cardOpacity,
    bool? isAlwaysOnTop,
    bool? isPositionLocked,
    bool? isSizeLocked,
    bool? showInTaskbar,
    WidgetModePreference? widgetMode,
    Object? themePresetId = _sentinel,
    DateTime? updatedAt,
  }) {
    return WidgetPreference(
      id: id,
      windowX: windowX == _sentinel ? this.windowX : windowX as double?,
      windowY: windowY == _sentinel ? this.windowY : windowY as double?,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      isAlwaysOnTop: isAlwaysOnTop ?? this.isAlwaysOnTop,
      isPositionLocked: isPositionLocked ?? this.isPositionLocked,
      isSizeLocked: isSizeLocked ?? this.isSizeLocked,
      showInTaskbar: showInTaskbar ?? this.showInTaskbar,
      widgetMode: widgetMode ?? this.widgetMode,
      themePresetId: themePresetId == _sentinel ? this.themePresetId : themePresetId as String?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'windowX': windowX,
        'windowY': windowY,
        'windowWidth': windowWidth,
        'windowHeight': windowHeight,
        'backgroundOpacity': backgroundOpacity,
        'cardOpacity': cardOpacity,
        'isAlwaysOnTop': isAlwaysOnTop,
        'isPositionLocked': isPositionLocked,
        'isSizeLocked': isSizeLocked,
        'showInTaskbar': showInTaskbar,
        'widgetMode': widgetMode.value,
        'themePresetId': themePresetId,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WidgetPreference.fromJson(Map<String, dynamic> json) => WidgetPreference(
        id: json['id'] as String? ?? 'default',
        windowX: (json['windowX'] as num?)?.toDouble(),
        windowY: (json['windowY'] as num?)?.toDouble(),
        windowWidth: (json['windowWidth'] as num?)?.toDouble() ?? 360,
        windowHeight: (json['windowHeight'] as num?)?.toDouble() ?? 480,
        backgroundOpacity: (json['backgroundOpacity'] as num?)?.toDouble() ?? 100,
        cardOpacity: (json['cardOpacity'] as num?)?.toDouble() ?? 100,
        isAlwaysOnTop: json['isAlwaysOnTop'] as bool? ?? false,
        isPositionLocked: json['isPositionLocked'] as bool? ?? false,
        isSizeLocked: json['isSizeLocked'] as bool? ?? false,
        showInTaskbar: json['showInTaskbar'] as bool? ?? true,
        widgetMode: WidgetModePreference.fromValue(json['widgetMode'] as String? ?? 'expanded'),
        themePresetId: json['themePresetId'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

const Object _sentinel = Object();

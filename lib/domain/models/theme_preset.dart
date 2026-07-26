/// A user-savable appearance preset. Local-only for MVP; syncable later
/// (see ARCHITECTURE.md).
class ThemePreset {
  const ThemePreset({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.accentColor,
    this.borderRadius = 18,
    this.shadowIntensity = 0.5,
    this.blurIntensity = 0.5,
    this.fontFamily = 'Nunito',
    this.fontSize = 13,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int backgroundColor;
  final int cardColor;
  final int textColor;
  final int accentColor;
  final double borderRadius;

  /// 0.0-1.0
  final double shadowIntensity;

  /// 0.0-1.0
  final double blurIntensity;
  final String fontFamily;
  final double fontSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  ThemePreset copyWith({
    String? name,
    int? backgroundColor,
    int? cardColor,
    int? textColor,
    int? accentColor,
    double? borderRadius,
    double? shadowIntensity,
    double? blurIntensity,
    String? fontFamily,
    double? fontSize,
    DateTime? updatedAt,
  }) =>
      ThemePreset(
        id: id,
        name: name ?? this.name,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        cardColor: cardColor ?? this.cardColor,
        textColor: textColor ?? this.textColor,
        accentColor: accentColor ?? this.accentColor,
        borderRadius: borderRadius ?? this.borderRadius,
        shadowIntensity: shadowIntensity ?? this.shadowIntensity,
        blurIntensity: blurIntensity ?? this.blurIntensity,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'backgroundColor': backgroundColor,
        'cardColor': cardColor,
        'textColor': textColor,
        'accentColor': accentColor,
        'borderRadius': borderRadius,
        'shadowIntensity': shadowIntensity,
        'blurIntensity': blurIntensity,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ThemePreset.fromJson(Map<String, dynamic> json) => ThemePreset(
        id: json['id'] as String,
        name: json['name'] as String,
        backgroundColor: json['backgroundColor'] as int,
        cardColor: json['cardColor'] as int,
        textColor: json['textColor'] as int,
        accentColor: json['accentColor'] as int,
        borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 18,
        shadowIntensity: (json['shadowIntensity'] as num?)?.toDouble() ?? 0.5,
        blurIntensity: (json['blurIntensity'] as num?)?.toDouble() ?? 0.5,
        fontFamily: json['fontFamily'] as String? ?? 'Nunito',
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 13,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  static ThemePreset defaultPreset(DateTime now) => ThemePreset(
        id: 'default',
        name: 'hyewon_list Default',
        backgroundColor: 0xFFF3F5FB,
        cardColor: 0xFFFFFFFF,
        textColor: 0xFF1B1E2E,
        accentColor: 0xFF8E6AC7,
        createdAt: now,
        updatedAt: now,
      );
}

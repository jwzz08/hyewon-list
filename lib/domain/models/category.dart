class Category {
  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;

  /// ARGB int color.
  final int color;

  /// Icon identifier (e.g. a Material icon codepoint name) — kept as a
  /// string so it survives JSON export/import without pulling in Flutter.
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category copyWith({
    String? name,
    int? color,
    Object? icon = _sentinel,
    int? sortOrder,
    DateTime? updatedAt,
  }) =>
      Category(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
        icon: icon == _sentinel ? this.icon : icon as String?,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'icon': icon,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as int,
        icon: json['icon'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

const Object _sentinel = Object();

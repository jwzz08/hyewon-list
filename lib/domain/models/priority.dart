/// Task urgency. Deliberately separate from [EventCategoryColor] — the
/// mockup uses two unrelated color systems (priority = urgency, category =
/// life-area), and mixing them was explicitly called out as a mistake to
/// avoid.
enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high');

  const TaskPriority(this.value);
  final String value;

  static TaskPriority fromValue(String value) => TaskPriority.values.firstWhere(
        (p) => p.value == value,
        orElse: () => TaskPriority.medium,
      );
}

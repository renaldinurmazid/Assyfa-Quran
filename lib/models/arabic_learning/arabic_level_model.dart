class ArabicLevel {
  final int id;
  final String name;
  final String description;
  final int order;
  final String color;
  final String? icon;
  final String difficulty;
  final int totalLessons;
  final int completedLessons;
  final int progressPct;
  final String status;
  final bool isLocked;

  ArabicLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.color,
    this.icon,
    required this.difficulty,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPct,
    required this.status,
    required this.isLocked,
  });

  factory ArabicLevel.fromJson(Map<String, dynamic> json) {
    return ArabicLevel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      color: json['color'] ?? '#6C5CE7',
      icon: json['icon'],
      difficulty: json['difficulty'] ?? 'beginner',
      totalLessons: json['total_lessons'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      progressPct: json['progress_pct'] ?? 0,
      status: json['status'] ?? 'not_started',
      isLocked: json['is_locked'] ?? false,
    );
  }
}

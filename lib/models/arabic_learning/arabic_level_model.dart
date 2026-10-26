/// Roadmap: Phase > Theme > Level, mirroring the admin curriculum hierarchy.
class ArabicRoadmap {
  final ArabicStats stats;
  final List<ArabicPhase> phases;

  ArabicRoadmap({required this.stats, required this.phases});

  factory ArabicRoadmap.fromJson(Map<String, dynamic> json) {
    return ArabicRoadmap(
      stats: ArabicStats.fromJson(json['stats'] ?? const {}),
      phases: (json['data'] as List? ?? [])
          .map((e) => ArabicPhase.fromJson(e))
          .toList(),
    );
  }
}

class ArabicStats {
  final int totalXp;
  final int totalLessons;
  final int completedLessons;
  final int? nextLessonId;

  ArabicStats({
    required this.totalXp,
    required this.totalLessons,
    required this.completedLessons,
    this.nextLessonId,
  });

  factory ArabicStats.fromJson(Map<String, dynamic> json) {
    return ArabicStats(
      totalXp: json['total_xp'] ?? 0,
      totalLessons: json['total_lessons'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      nextLessonId: json['next_lesson_id'],
    );
  }
}

class ArabicPhase {
  final int id;
  final String title;
  final String? subtitle;
  final List<ArabicTheme> themes;

  ArabicPhase({
    required this.id,
    required this.title,
    this.subtitle,
    required this.themes,
  });

  factory ArabicPhase.fromJson(Map<String, dynamic> json) {
    return ArabicPhase(
      id: json['id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      themes: (json['themes'] as List? ?? [])
          .map((e) => ArabicTheme.fromJson(e))
          .toList(),
    );
  }
}

class ArabicTheme {
  final int id;
  final String title;
  final String? goal;
  final String color;
  final String? icon;
  final int totalLessons;
  final int completedLessons;
  final int progressPct;
  final bool isLocked;
  final List<ArabicLevel> levels;

  ArabicTheme({
    required this.id,
    required this.title,
    this.goal,
    required this.color,
    this.icon,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPct,
    required this.isLocked,
    required this.levels,
  });

  factory ArabicTheme.fromJson(Map<String, dynamic> json) {
    return ArabicTheme(
      id: json['id'],
      title: json['title'] ?? '',
      goal: json['goal'],
      color: json['color'] ?? '#6C5CE7',
      icon: json['icon'],
      totalLessons: json['total_lessons'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      progressPct: json['progress_pct'] ?? 0,
      isLocked: json['is_locked'] ?? false,
      levels: (json['levels'] as List? ?? [])
          .map((e) => ArabicLevel.fromJson(e))
          .toList(),
    );
  }
}

class ArabicLevel {
  final int id;
  final String name;
  final String description;
  final String color;
  final String? icon;
  final int totalLessons;
  final int completedLessons;
  final int progressPct;
  final String status; // not_started | in_progress | completed
  final bool isLocked;

  ArabicLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.icon,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPct,
    required this.status,
    required this.isLocked,
  });

  bool get isCompleted => status == 'completed';

  factory ArabicLevel.fromJson(Map<String, dynamic> json) {
    return ArabicLevel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '#6C5CE7',
      icon: json['icon'],
      totalLessons: json['total_lessons'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      progressPct: json['progress_pct'] ?? 0,
      status: json['status'] ?? 'not_started',
      isLocked: json['is_locked'] ?? false,
    );
  }
}

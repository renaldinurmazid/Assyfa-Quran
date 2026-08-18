class ArabicLesson {
  final int id;
  final int levelId;
  final String title;
  final String description;
  final int order;
  final int totalQuizzes;
  final bool isCompleted;
  final String status;
  final int score;

  ArabicLesson({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.order,
    required this.totalQuizzes,
    required this.isCompleted,
    required this.status,
    required this.score,
  });

  factory ArabicLesson.fromJson(Map<String, dynamic> json) {
    return ArabicLesson(
      id: json['id'],
      levelId: json['level_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      status: json['status'] ?? 'not_started',
      score: json['score'] ?? 0,
    );
  }
}

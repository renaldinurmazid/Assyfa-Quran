class MemorizationLevel {
  final int id;
  final String title;
  final String description;
  final int order;
  final String image;
  final String backgroundColor;
  final int points;
  final String category;
  final int occurrences;
  final String understandingPercentage;
  final bool isCompleted;
  final double progressPercentage;
  final int completedQuestionsCount;
  final int totalQuestionsCount;

  MemorizationLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.image,
    required this.backgroundColor,
    required this.points,
    required this.category,
    required this.occurrences,
    required this.understandingPercentage,
    required this.isCompleted,
    required this.progressPercentage,
    required this.completedQuestionsCount,
    required this.totalQuestionsCount,
  });

  factory MemorizationLevel.fromJson(Map<String, dynamic> json) {
    return MemorizationLevel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      order: json['order'],
      image: json['image_path'],
      backgroundColor: json['background_color'],
      points: json['points'],
      category: json['category'],
      occurrences: json['occurrences'],
      understandingPercentage: json['understanding_percentage'].toString(),
      isCompleted: json['is_completed'],
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      completedQuestionsCount: json['completed_questions_count'],
      totalQuestionsCount: json['total_questions_count'],
    );
  }
}

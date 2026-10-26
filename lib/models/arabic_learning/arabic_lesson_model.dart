class ArabicLesson {
  final int id;
  final int levelId;
  final String title;
  final String description;
  final String kind; // lesson | review
  final int order;
  final int durationMinutes;
  final int maxXp;
  final int totalQuizzes;
  final bool isCompleted;
  final bool isLocked;
  final String status; // not_started | in_progress | completed
  final int score;
  final int attempts;

  ArabicLesson({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.kind,
    required this.order,
    required this.durationMinutes,
    required this.maxXp,
    required this.totalQuizzes,
    required this.isCompleted,
    required this.isLocked,
    required this.status,
    required this.score,
    required this.attempts,
  });

  bool get isReviewLesson => kind == 'review';

  factory ArabicLesson.fromJson(Map<String, dynamic> json) {
    return ArabicLesson(
      id: json['id'],
      levelId: json['level_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      kind: json['kind'] ?? 'lesson',
      order: json['order'] ?? 0,
      durationMinutes: json['duration_minutes'] ?? 0,
      maxXp: json['max_xp'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      isLocked: json['is_locked'] ?? false,
      status: json['status'] ?? 'not_started',
      score: json['score'] ?? 0,
      attempts: json['attempts'] ?? 0,
    );
  }
}

/// Response of `levels/{id}/lessons`: the level header plus its lessons.
class ArabicLevelLessons {
  final int levelId;
  final String name;
  final String description;
  final String color;
  final String? themeTitle;
  final List<ArabicLesson> lessons;

  ArabicLevelLessons({
    required this.levelId,
    required this.name,
    required this.description,
    required this.color,
    this.themeTitle,
    required this.lessons,
  });

  factory ArabicLevelLessons.fromJson(Map<String, dynamic> json) {
    final level = json['level'] ?? const {};
    return ArabicLevelLessons(
      levelId: level['id'] ?? 0,
      name: level['name'] ?? '',
      description: level['description'] ?? '',
      color: level['color'] ?? '#6C5CE7',
      themeTitle: level['theme'],
      lessons: (json['lessons'] as List? ?? [])
          .map((e) => ArabicLesson.fromJson(e))
          .toList(),
    );
  }
}

class ArabicLessonXp {
  final int lesson;
  final int quiz;
  final int perfectBonus;
  final int review;

  ArabicLessonXp({
    required this.lesson,
    required this.quiz,
    required this.perfectBonus,
    required this.review,
  });

  factory ArabicLessonXp.fromJson(Map<String, dynamic> json) {
    return ArabicLessonXp(
      lesson: json['lesson'] ?? 0,
      quiz: json['quiz'] ?? 0,
      perfectBonus: json['perfect_bonus'] ?? 0,
      review: json['review'] ?? 0,
    );
  }
}

/// Response of `lessons/{id}`: lesson info, objectives and the material blocks.
class ArabicLessonDetail {
  final ArabicLesson lesson;
  final String levelName;
  final String color;
  final String themeTitle;
  final String? target;
  final List<String> objectives;
  final String? motivationMessage;
  final int passScore;
  final ArabicLessonXp xp;
  final int practiceCount;
  final int mainCount;
  final int needReviewCount;
  final List<ArabicContent> contents;

  ArabicLessonDetail({
    required this.lesson,
    required this.levelName,
    required this.color,
    required this.themeTitle,
    this.target,
    required this.objectives,
    this.motivationMessage,
    required this.passScore,
    required this.xp,
    required this.practiceCount,
    required this.mainCount,
    required this.needReviewCount,
    required this.contents,
  });

  factory ArabicLessonDetail.fromJson(Map<String, dynamic> json) {
    final l = json['lesson'] as Map<String, dynamic>;
    return ArabicLessonDetail(
      lesson: ArabicLesson.fromJson(l),
      levelName: l['level']?['name'] ?? '',
      color: l['level']?['color'] ?? '#6C5CE7',
      themeTitle: l['theme']?['title'] ?? '',
      target: l['target'],
      objectives: (l['objectives'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      motivationMessage: l['motivation_message'],
      passScore: l['pass_score'] ?? 70,
      xp: ArabicLessonXp.fromJson(l['xp'] ?? const {}),
      practiceCount: l['practice_count'] ?? 0,
      mainCount: l['main_count'] ?? 0,
      needReviewCount: l['need_review_count'] ?? 0,
      contents: (json['contents'] as List? ?? [])
          .map((e) => ArabicContent.fromJson(e))
          .toList(),
    );
  }
}

/// One material block of a lesson: vocab_card | verse | text | insight.
class ArabicContent {
  final int id;
  final String type;
  final String? title;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? reference;
  final String? body;
  final String? image;
  final String? audio;

  ArabicContent({
    required this.id,
    required this.type,
    this.title,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.reference,
    this.body,
    this.image,
    this.audio,
  });

  factory ArabicContent.fromJson(Map<String, dynamic> json) {
    return ArabicContent(
      id: json['id'],
      type: json['type'] ?? 'text',
      title: json['title'],
      arabicText: json['arabic_text'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      reference: json['reference'],
      body: json['body'],
      image: json['image'],
      audio: json['audio'],
    );
  }
}

/// Question types supported by the admin question builder.
class ArabicQuizType {
  static const multipleChoice = 'multiple_choice';
  static const multipleSelect = 'multiple_select';
  static const trueFalse = 'true_false';
  static const shortAnswer = 'short_answer';
  static const matching = 'matching';
  static const ordering = 'ordering';
  static const fillBlank = 'fill_blank';
}

/// A choice, an ordering item or one side of a matching pair.
class ArabicOption {
  final String id;
  final String? text;
  final String? image;

  ArabicOption({required this.id, this.text, this.image});

  factory ArabicOption.fromJson(Map<String, dynamic> json) {
    return ArabicOption(
      id: json['id'].toString(),
      text: json['text'],
      image: json['image'],
    );
  }
}

/// A question as served by the API: the answer is never included.
class ArabicQuiz {
  final int id;
  final int lessonId;
  final String stage; // practice | main
  final String type;
  final String question;
  final String? arabicText;
  final String? image;
  final String? audio;
  final int points;
  final int? timeLimit; // seconds
  final List<ArabicOption> options;

  /// matching only: left items stay in order, right items arrive shuffled.
  final List<ArabicOption> left;
  final List<ArabicOption> right;

  ArabicQuiz({
    required this.id,
    required this.lessonId,
    required this.stage,
    required this.type,
    required this.question,
    this.arabicText,
    this.image,
    this.audio,
    required this.points,
    this.timeLimit,
    required this.options,
    required this.left,
    required this.right,
  });

  static List<ArabicOption> _options(dynamic raw) =>
      (raw as List? ?? []).map((e) => ArabicOption.fromJson(e)).toList();

  factory ArabicQuiz.fromJson(Map<String, dynamic> json) {
    return ArabicQuiz(
      id: json['id'],
      lessonId: json['lesson_id'] ?? 0,
      stage: json['stage'] ?? 'main',
      type: json['type'] ?? ArabicQuizType.multipleChoice,
      question: json['question'] ?? '',
      arabicText: json['arabic_text'],
      image: json['image'],
      audio: json['audio'],
      points: json['points'] ?? 0,
      timeLimit: json['time_limit'],
      options: _options(json['options']),
      left: _options(json['left']),
      right: _options(json['right']),
    );
  }
}

/// Feedback for a single question (`quizzes/{id}/check` or a row of the submit result).
class ArabicAnswerResult {
  final int quizId;
  final bool isCorrect;

  /// Same shape as the answer the user submits for that question type.
  final dynamic correctAnswer;
  final String? explanation;

  ArabicAnswerResult({
    required this.quizId,
    required this.isCorrect,
    required this.correctAnswer,
    this.explanation,
  });

  factory ArabicAnswerResult.fromJson(Map<String, dynamic> json) {
    return ArabicAnswerResult(
      quizId: json['quiz_id'],
      isCorrect: json['is_correct'] ?? false,
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
    );
  }
}

/// Response of `lessons/{id}/submit`.
class ArabicSubmitResult {
  final String mode;
  final int score;
  final int bestScore;
  final int passScore;
  final bool passed;
  final int total;
  final int correctCount;
  final int wrongCount;
  final bool reviewRequired;
  final bool completed;
  final bool justCompleted;
  final bool levelCompleted;
  final int xpAwarded;
  final int totalXp;
  final String? motivationMessage;
  final int? nextLessonId;

  ArabicSubmitResult({
    required this.mode,
    required this.score,
    required this.bestScore,
    required this.passScore,
    required this.passed,
    required this.total,
    required this.correctCount,
    required this.wrongCount,
    required this.reviewRequired,
    required this.completed,
    required this.justCompleted,
    required this.levelCompleted,
    required this.xpAwarded,
    required this.totalXp,
    this.motivationMessage,
    this.nextLessonId,
  });

  factory ArabicSubmitResult.fromJson(Map<String, dynamic> json) {
    return ArabicSubmitResult(
      mode: json['mode'] ?? 'main',
      score: json['score'] ?? 0,
      bestScore: json['best_score'] ?? 0,
      passScore: json['pass_score'] ?? 70,
      passed: json['passed'] ?? false,
      total: json['total'] ?? 0,
      correctCount: json['correct_count'] ?? 0,
      wrongCount: json['wrong_count'] ?? 0,
      reviewRequired: json['review_required'] ?? false,
      completed: json['completed'] ?? false,
      justCompleted: json['just_completed'] ?? false,
      levelCompleted: json['level_completed'] ?? false,
      xpAwarded: json['xp_awarded'] ?? 0,
      totalXp: json['total_xp'] ?? 0,
      motivationMessage: json['motivation_message'],
      nextLessonId: json['next_lesson_id'],
    );
  }
}

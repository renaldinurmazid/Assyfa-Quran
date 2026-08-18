class ArabicVocabulary {
  final String arabicWord;
  final String transliteration;
  final String translationId;
  final String? translationEn;

  ArabicVocabulary({
    required this.arabicWord,
    required this.transliteration,
    required this.translationId,
    this.translationEn,
  });

  factory ArabicVocabulary.fromJson(Map<String, dynamic> json) {
    return ArabicVocabulary(
      arabicWord: json['arabic_word'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translationId: json['translation_id'] ?? '',
      translationEn: json['translation_en'],
    );
  }
}

class ArabicExample {
  final String arabicText;
  final String translationId;
  final int surahNumber;
  final int ayahNumber;

  ArabicExample({
    required this.arabicText,
    required this.translationId,
    required this.surahNumber,
    required this.ayahNumber,
  });

  factory ArabicExample.fromJson(Map<String, dynamic> json) {
    return ArabicExample(
      arabicText: json['arabic_text'] ?? '',
      translationId: json['translation_id'] ?? '',
      surahNumber: json['surah_number'] ?? 0,
      ayahNumber: json['ayah_number'] ?? 0,
    );
  }
}

class ArabicQuiz {
  final int id;
  final int lessonId;
  final String question;
  final String type; // 'multiple_choice', 'matching', 'fill_blank'
  final List<String> options;
  final String correctAnswer;
  final int xpReward;
  final ArabicVocabulary? vocabulary;
  final ArabicExample? example;

  ArabicQuiz({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.xpReward,
    this.vocabulary,
    this.example,
  });

  factory ArabicQuiz.fromJson(Map<String, dynamic> json) {
    return ArabicQuiz(
      id: json['id'],
      lessonId: json['lesson_id'],
      question: json['question'] ?? '',
      type: json['type'] ?? 'multiple_choice',
      options: json['options'] != null ? List<String>.from(json['options']) : [],
      correctAnswer: json['correct_answer'] ?? '',
      xpReward: json['xp_reward'] ?? 10,
      vocabulary: json['vocabulary'] != null ? ArabicVocabulary.fromJson(json['vocabulary']) : null,
      example: json['example'] != null ? ArabicExample.fromJson(json['example']) : null,
    );
  }
}

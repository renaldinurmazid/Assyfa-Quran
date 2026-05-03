class MemorizationWord {
  final int id;
  final int levelId;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String? exampleAyah;
  final String? exampleTranslation;
  final int occurrenceCount;
  final String? audioPath;

  MemorizationWord({
    required this.id,
    required this.levelId,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.exampleAyah,
    this.exampleTranslation,
    required this.occurrenceCount,
    this.audioPath,
  });

  factory MemorizationWord.fromJson(Map<String, dynamic> json) {
    return MemorizationWord(
      id: json['id'],
      levelId: json['level_id'],
      arabicText: json['arabic_text'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translation: json['translation'] ?? '',
      exampleAyah: json['example_ayah'],
      exampleTranslation: json['example_translation'],
      occurrenceCount: json['occurrence_count'] ?? 0,
      audioPath: json['audio_path'],
    );
  }
}

class MemorizationOption {
  final int id;
  final int questionId;
  final String optionText;
  final String? matchingText;
  final bool isCorrect;

  MemorizationOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    this.matchingText,
    required this.isCorrect,
  });

  factory MemorizationOption.fromJson(Map<String, dynamic> json) {
    return MemorizationOption(
      id: json['id'],
      questionId: json['question_id'],
      optionText: json['option_text'] ?? '',
      matchingText: json['matching_text'],
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class MemorizationQuestion {
  final int id;
  final int levelId;
  final int? wordId;
  final String type; // 'info', 'word-translation', 'word-scramble', 'matching'
  final String title;
  final String content;
  final String? arabic;
  final String? reference;
  final List<String>? scrambledWords;
  final List<String>? correctSequence;
  final String? explanation;
  final String? highlightedWord;
  final String? correctTranslation;
  final String? questionText;
  final List<MemorizationOption> options;
  final MemorizationWord? word;

  MemorizationQuestion({
    required this.id,
    required this.levelId,
    this.wordId,
    required this.type,
    required this.title,
    required this.content,
    this.arabic,
    this.reference,
    this.scrambledWords,
    this.correctSequence,
    this.explanation,
    this.highlightedWord,
    this.correctTranslation,
    this.questionText,
    required this.options,
    this.word,
  });

  factory MemorizationQuestion.fromJson(Map<String, dynamic> json) {
    return MemorizationQuestion(
      id: json['id'],
      levelId: json['level_id'],
      wordId: json['word_id'],
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      arabic: json['arabic'],
      reference: json['reference'],
      scrambledWords: json['scrambled_words'] != null
          ? List<String>.from(json['scrambled_words'])
          : null,
      correctSequence: json['correct_sequence'] != null
          ? List<String>.from(json['correct_sequence'])
          : null,
      explanation: json['explanation'],
      highlightedWord: json['highlighted_word'],
      correctTranslation: json['correct_translation'],
      questionText: json['question_text'],
      options: json['options'] != null
          ? (json['options'] as List)
              .map((e) => MemorizationOption.fromJson(e))
              .toList()
          : [],
      word: json['word'] != null
          ? MemorizationWord.fromJson(json['word'])
          : null,
    );
  }
}

class MemorizationLevelDetail {
  final int id;
  final String title;
  final String description;
  final int order;
  final String imagePath;
  final String backgroundColor;
  final int points;
  final String category;
  final int occurrences;
  final String understandingPercentage;
  final List<MemorizationWord> words;
  final List<MemorizationQuestion> questions;

  MemorizationLevelDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.imagePath,
    required this.backgroundColor,
    required this.points,
    required this.category,
    required this.occurrences,
    required this.understandingPercentage,
    required this.words,
    required this.questions,
  });

  factory MemorizationLevelDetail.fromJson(Map<String, dynamic> json) {
    return MemorizationLevelDetail(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      imagePath: json['image_path'] ?? '',
      backgroundColor: json['background_color'] ?? '#20C997',
      points: json['points'] ?? 0,
      category: json['category'] ?? '',
      occurrences: json['occurrences'] ?? 0,
      understandingPercentage: (json['understanding_percentage'] ?? '0').toString(),
      words: json['words'] != null
          ? (json['words'] as List)
              .map((e) => MemorizationWord.fromJson(e))
              .toList()
          : [],
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((e) => MemorizationQuestion.fromJson(e))
              .toList()
          : [],
    );
  }
}

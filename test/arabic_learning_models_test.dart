import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/models/arabic_learning/arabic_leaderboard_model.dart';
import 'package:quran_app/models/arabic_learning/arabic_lesson_model.dart';
import 'package:quran_app/models/arabic_learning/arabic_level_model.dart';
import 'package:quran_app/models/arabic_learning/arabic_quiz_model.dart';

/// The fixtures are real responses of `/api/arabic-learning/*`
/// (aip-quran `ArabicLearningController`), so these tests guard the app/API contract.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/arabic/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('roadmap parses phases, themes, levels and stats', () {
    final roadmap = ArabicRoadmap.fromJson(fixture('roadmap'));

    expect(roadmap.stats.totalLessons, 1);
    expect(roadmap.stats.nextLessonId, isNotNull);
    final theme = roadmap.phases.single.themes.single;
    expect(theme.title, 'Huruf');
    expect(theme.levels.single.name, 'Level 1');
    expect(theme.levels.single.isLocked, false);
    expect(theme.levels.single.status, 'not_started');
  });

  test('level lessons parse the level header and lesson flags', () {
    final data = ArabicLevelLessons.fromJson(fixture('level_lessons'));

    expect(data.name, 'Level 1');
    expect(data.color, '#3B82F6');
    expect(data.lessons.single.durationMinutes, 10);
    expect(data.lessons.single.totalQuizzes, 8);
    expect(data.lessons.single.isLocked, false);
  });

  test('lesson detail parses objectives, xp and material blocks', () {
    final detail = ArabicLessonDetail.fromJson(fixture('lesson'));

    expect(detail.objectives, ['Kenal kata', 'Baca kata']);
    expect(detail.target, 'Hafal 5 kata');
    expect(detail.color, '#3B82F6');
    expect(detail.mainCount, 7);
    expect(detail.practiceCount, 1);
    expect(detail.contents.map((c) => c.type), ['vocab_card', 'insight']);
    expect(detail.contents.first.arabicText, isNotEmpty);
    expect(detail.contents.last.body, 'Tips');
  });

  test('quizzes parse every question type without an answer field', () {
    final quizzes = (fixture('quizzes')['quizzes'] as List)
        .map((e) => ArabicQuiz.fromJson(e))
        .toList();

    expect(quizzes.map((q) => q.type), [
      ArabicQuizType.multipleChoice,
      ArabicQuizType.multipleSelect,
      ArabicQuizType.trueFalse,
      ArabicQuizType.shortAnswer,
      ArabicQuizType.matching,
      ArabicQuizType.ordering,
      ArabicQuizType.fillBlank,
    ]);

    final matching = quizzes[4];
    // Pair ids arrive as integers; the app works with strings throughout.
    expect(matching.left.map((o) => o.id), ['1', '2']);
    expect(matching.right.map((o) => o.id).toSet(), {'1', '2'});
    expect(quizzes[2].options.map((o) => o.id), ['true', 'false']);
    expect(quizzes[6].timeLimit, 30);
    expect(quizzes[6].arabicText, contains('___'));
  });

  test('check and submit results parse', () {
    final check = ArabicAnswerResult.fromJson(fixture('check'));
    expect(check.isCorrect, false);
    expect(check.correctAnswer, 'a');
    expect(check.explanation, 'Karena A');

    final submit = ArabicSubmitResult.fromJson(fixture('submit'));
    expect(submit.mode, 'main');
    expect(submit.total, 7);
    expect(submit.correctCount, 1);
    expect(submit.reviewRequired, true);
    expect(submit.passed, false);
    expect(submit.xpAwarded, 10);
  });

  test('leaderboard parses ranked entries, paging meta and my rank', () {
    final page = ArabicLeaderboardPage.fromJson(fixture('leaderboard'));

    expect(page.entries.first.rank, 1);
    expect(page.entries.first.name, 'Aisyah');
    expect(page.entries.last.profilePicture, isNull);
    expect(page.currentPage, 1);
    expect(page.lastPage, 2);
    expect(page.total, 31);
    expect(page.myStat?.rank, 2);
    expect(page.myStat?.totalXp, 200);
  });

  test('leaderboard without xp yields a null rank', () {
    final page = ArabicLeaderboardPage.fromJson({
      'data': [],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
      'my_stat': {'rank': null, 'user_id': 1, 'name': 'X', 'total_xp': 0},
    });

    expect(page.entries, isEmpty);
    expect(page.myStat?.rank, isNull);
  });
}

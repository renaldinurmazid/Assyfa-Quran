import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/arabic_learning/arabic_quiz_model.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_sfx.dart';
import 'package:quran_app/widgets/app_toast.dart';

/// Which set of questions a quiz session plays.
enum ArabicQuizMode {
  /// Quick practice: instant feedback, nothing is saved.
  practice,

  /// Main quiz: graded and saved by the server on submit.
  main,

  /// Re-asks the main questions the user last got wrong.
  review;

  /// Value sent to the submit endpoint (practice is never submitted).
  String get apiValue => this == review ? 'review' : 'main';
}

/// Plays one quiz session of a lesson.
///
/// Every question is checked against the server for instant feedback. Answers
/// of the main/review sessions are collected and submitted once at the end, the
/// server re-grades them and is the only source of progress and XP.
class ArabicQuizController extends GetxController {
  ArabicQuizController({required this.lessonId, required ArabicQuizMode mode})
    : mode = mode.obs;

  final int lessonId;
  final Rx<ArabicQuizMode> mode;

  final isLoading = true.obs;
  final isChecking = false.obs;
  final isSubmitting = false.obs;

  final lessonTitle = ''.obs;
  final lessonColor = '#6C5CE7'.obs;
  final passScore = 70.obs;

  final quizzes = <ArabicQuiz>[].obs;
  final index = 0.obs;

  /// Answers by quiz id, in the shape the API expects (see ArabicQuizType).
  final answers = <int, dynamic>{}.obs;
  final results = <int, ArabicAnswerResult>{}.obs;

  /// Set once a practice run has gone through every question.
  final practiceFinished = false.obs;
  final submitResult = Rxn<ArabicSubmitResult>();

  final secondsLeft = 0.obs;
  Timer? _timer;

  ArabicQuiz? get current =>
      index.value < quizzes.length ? quizzes[index.value] : null;

  ArabicAnswerResult? get currentResult {
    final quiz = current;
    return quiz == null ? null : results[quiz.id];
  }

  bool get isLast => index.value >= quizzes.length - 1;
  int get correctCount => results.values.where((r) => r.isCorrect).length;
  bool get isFinished => practiceFinished.value || submitResult.value != null;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    _reset();
    try {
      final response = mode.value == ArabicQuizMode.review
          ? await Request().get(Url.arabicReview(lessonId))
          : await Request().get(
              Url.arabicQuizzes(lessonId),
              queryParameters: {'stage': mode.value.name},
            );

      final lesson = response.data['lesson'] ?? const {};
      lessonTitle.value = lesson['title'] ?? '';
      lessonColor.value = lesson['color'] ?? '#6C5CE7';
      passScore.value = lesson['pass_score'] ?? 70;
      quizzes.value = (response.data['quizzes'] as List? ?? [])
          .map((e) => ArabicQuiz.fromJson(e))
          .toList();

      // The shuffled order is the starting answer of an ordering question.
      for (final quiz in quizzes) {
        if (quiz.type == ArabicQuizType.ordering) {
          answers[quiz.id] = quiz.options.map((o) => o.id).toList();
        }
      }
      _startTimer();
    } on DioException catch (e) {
      AppToast.error(
        title: 'Gagal',
        message: ArabicQuranController.errorMessage(
          e,
          'Gagal memuat pertanyaan.',
        ),
      );
      // A locked or unpublished lesson has nothing to play.
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        Get.back();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _reset() {
    _timer?.cancel();
    quizzes.clear();
    answers.clear();
    results.clear();
    index.value = 0;
    practiceFinished.value = false;
    submitResult.value = null;
  }

  // ─── Answering ───────────────────────────────────────────────────────────

  void setAnswer(ArabicQuiz quiz, dynamic value) {
    if (results.containsKey(quiz.id)) return; // locked after checking
    answers[quiz.id] = value;
  }

  bool hasAnswer(ArabicQuiz quiz) {
    final answer = answers[quiz.id];
    switch (quiz.type) {
      case ArabicQuizType.multipleSelect:
        return answer is List && answer.isNotEmpty;
      case ArabicQuizType.shortAnswer:
        return answer is String && answer.trim().isNotEmpty;
      case ArabicQuizType.matching:
        return answer is Map && answer.length >= quiz.left.length;
      case ArabicQuizType.ordering:
        return answer is List && answer.isNotEmpty;
      default:
        return answer != null;
    }
  }

  /// Asks the server whether the current answer is right. [timedOut] checks
  /// whatever is filled in so far, even nothing.
  Future<void> check({bool timedOut = false}) async {
    final quiz = current;
    if (quiz == null || results.containsKey(quiz.id) || isChecking.value) {
      return;
    }
    if (!timedOut && !hasAnswer(quiz)) return;

    _timer?.cancel();
    isChecking.value = true;
    try {
      final response = await Request().post(
        Url.arabicCheck(quiz.id),
        data: {'answer': answers[quiz.id]},
      );
      final result = ArabicAnswerResult.fromJson({
        'quiz_id': quiz.id,
        ...Map<String, dynamic>.from(response.data),
      });
      results[quiz.id] = result;
      ArabicSfx.answer(isCorrect: result.isCorrect);
    } on DioException catch (e) {
      AppToast.error(
        title: 'Gagal',
        message: ArabicQuranController.errorMessage(
          e,
          'Gagal memeriksa jawaban.',
        ),
      );
      if (!timedOut) _startTimer(resume: true);
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> next() async {
    if (current == null || currentResult == null) return;
    if (!isLast) {
      index.value++;
      _startTimer();
    } else if (mode.value == ArabicQuizMode.practice) {
      practiceFinished.value = true;
    } else {
      await submit();
    }
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      final response = await Request().post(
        Url.arabicSubmit(lessonId),
        data: {
          'mode': mode.value.apiValue,
          'answers': [
            for (final quiz in quizzes)
              {'quiz_id': quiz.id, 'answer': answers[quiz.id]},
          ],
        },
      );
      final result = ArabicSubmitResult.fromJson(response.data);
      submitResult.value = result;
      if (result.levelCompleted) ArabicSfx.celebrateLevel();
      if (Get.isRegistered<ArabicQuranController>()) {
        ArabicQuranController.to.refreshProgress();
      }
    } on DioException catch (e) {
      AppToast.error(
        title: 'Gagal',
        message: ArabicQuranController.errorMessage(
          e,
          'Gagal menyimpan hasil. Coba lagi.',
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Starts a fresh session in [newMode], e.g. review after a main quiz with
  /// mistakes or a retry of the main quiz.
  Future<void> start(ArabicQuizMode newMode) async {
    mode.value = newMode;
    await load();
  }

  // ─── Timer ───────────────────────────────────────────────────────────────

  void _startTimer({bool resume = false}) {
    _timer?.cancel();
    final limit = current?.timeLimit;
    if (limit == null || limit <= 0) {
      secondsLeft.value = 0;
      return;
    }
    if (!resume || secondsLeft.value <= 0) secondsLeft.value = limit;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft.value > 0) secondsLeft.value--;
      if (secondsLeft.value <= 0) {
        timer.cancel();
        check(timedOut: true);
      }
    });
  }
}

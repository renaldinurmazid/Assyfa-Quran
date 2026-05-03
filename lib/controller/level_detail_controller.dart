import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/memorization_controller.dart';
import 'package:quran_app/models/memorization_detail_model.dart';
import 'package:quran_app/models/memorization_level_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class LevelDetailController extends GetxController {
  final isLoading = true.obs;
  final levelDetail = Rxn<MemorizationLevelDetail>();

  // Step navigation
  final currentStep = 0.obs;
  final totalSteps = 0.obs;

  // Answer state
  final selectedOptionId = Rxn<int>();
  final isAnswered = false.obs;
  final isCorrect = false.obs;

  // Word-scramble state
  final arrangedWords = <String>[].obs;
  final availableWords = <String>[].obs;
  final isScrambleChecked = false.obs;
  final isScrambleCorrect = false.obs;

  // Matching state
  final selectedArabic = Rxn<String>();
  final matchedPairs = <String, String>{}.obs;
  final incorrectMatch = Rxn<String>();
  final isMatchingComplete = false.obs;
  final shuffledTranslations = <String>[].obs;

  // Score tracking
  final correctAnswers = 0.obs;
  final totalAnswerable = 0.obs;

  MemorizationQuestion? get currentQuestion {
    final detail = levelDetail.value;
    if (detail == null || detail.questions.isEmpty) return null;
    if (currentStep.value >= detail.questions.length) return null;
    return detail.questions[currentStep.value];
  }

  double get progressValue {
    if (totalSteps.value == 0) return 0;
    return (currentStep.value + 1) / totalSteps.value;
  }

  @override
  void onInit() {
    super.onInit();
    final MemorizationLevel? level = Get.arguments;
    if (level != null) {
      fetchLevelDetail(level.id);
    }
  }

  Future<void> fetchLevelDetail(int levelId) async {
    isLoading.value = true;
    try {
      final response = await Request().get(
        Url.memorizationLevelDetail(levelId),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        levelDetail.value = MemorizationLevelDetail.fromJson(data);
        totalSteps.value = levelDetail.value!.questions.length;

        // Count answerable questions
        totalAnswerable.value = levelDetail.value!.questions
            .where((q) => q.type != 'info')
            .length;

        // Initialize first question
        _initCurrentQuestion();
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat detail level',
        );
      }
    } catch (e) {
      debugPrint('Error fetching level detail: $e');
      AppToast.error(message: 'Terjadi kesalahan saat memuat level');
    } finally {
      isLoading.value = false;
    }
  }

  void nextStep() {
    if (currentStep.value < totalSteps.value - 1) {
      currentStep.value++;
      _resetAnswerState();
      _initCurrentQuestion();
    } else {
      // Level completed!
      _showCompletionDialog();
    }
  }

  void _resetAnswerState() {
    selectedOptionId.value = null;
    isAnswered.value = false;
    isCorrect.value = false;
    arrangedWords.clear();
    availableWords.clear();
    isScrambleChecked.value = false;
    isScrambleCorrect.value = false;
    selectedArabic.value = null;
    matchedPairs.clear();
    incorrectMatch.value = null;
    isMatchingComplete.value = false;
    shuffledTranslations.clear();
  }

  void _initCurrentQuestion() {
    final q = currentQuestion;
    if (q == null) return;

    if (q.type == 'word-scramble' && q.scrambledWords != null) {
      availableWords.assignAll(q.scrambledWords!);
    }

    if (q.type == 'matching' && q.options.isNotEmpty) {
      final translations = q.options
          .map((o) => o.matchingText ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
      translations.shuffle();
      shuffledTranslations.assignAll(translations);
    }
  }

  // Called when screen first shows a question
  void initQuestionIfNeeded() {
    _initCurrentQuestion();
  }

  // === Mark question as complete via API ===
  Future<void> _markQuestionComplete(int questionId) async {
    try {
      final response = await Request().post(
        Url.memorizationQuestionComplete(questionId),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[LevelDetail] Question $questionId marked complete');
      }
    } catch (e) {
      debugPrint('[LevelDetail] Failed to mark question $questionId complete: $e');
    }
  }

  // === Word-Translation ===
  void selectOption(int optionId) {
    if (isAnswered.value) return;
    selectedOptionId.value = optionId;
  }

  void checkAnswer() {
    final q = currentQuestion;
    if (q == null || selectedOptionId.value == null) return;

    isAnswered.value = true;
    final selectedOpt = q.options.firstWhere(
      (o) => o.id == selectedOptionId.value,
    );
    isCorrect.value = selectedOpt.isCorrect;
    if (isCorrect.value) {
      correctAnswers.value++;
      _markQuestionComplete(q.id);
    }
  }

  // === Word-Scramble ===
  void addWordToArrangement(String word) {
    if (isScrambleChecked.value) return;
    availableWords.remove(word);
    arrangedWords.add(word);
  }

  void removeWordFromArrangement(int index) {
    if (isScrambleChecked.value) return;
    final word = arrangedWords.removeAt(index);
    availableWords.add(word);
  }

  void checkScramble() {
    final q = currentQuestion;
    if (q == null || q.correctSequence == null) return;
    if (arrangedWords.length != q.correctSequence!.length) return;

    isScrambleChecked.value = true;
    bool correct = true;
    for (int i = 0; i < arrangedWords.length; i++) {
      if (arrangedWords[i] != q.correctSequence![i]) {
        correct = false;
        break;
      }
    }
    isScrambleCorrect.value = correct;
    if (correct) {
      correctAnswers.value++;
      _markQuestionComplete(q.id);
    }
  }

  void resetScramble() {
    final q = currentQuestion;
    if (q == null || q.scrambledWords == null) return;
    arrangedWords.clear();
    availableWords.assignAll(q.scrambledWords!);
    isScrambleChecked.value = false;
    isScrambleCorrect.value = false;
  }

  // === Matching ===
  void selectArabicWord(String arabic) {
    if (matchedPairs.containsKey(arabic)) return;
    selectedArabic.value = arabic;
    incorrectMatch.value = null;
  }

  void selectTranslation(String translation) {
    if (selectedArabic.value == null) return;
    if (matchedPairs.containsValue(translation)) return;

    final q = currentQuestion;
    if (q == null) return;

    // Find if this is a correct match
    final matchOption = q.options.firstWhereOrNull(
      (o) =>
          o.optionText == selectedArabic.value && o.matchingText == translation,
    );

    if (matchOption != null) {
      matchedPairs[selectedArabic.value!] = translation;
      selectedArabic.value = null;
      incorrectMatch.value = null;

      // Check if all matched
      if (matchedPairs.length == q.options.length) {
        isMatchingComplete.value = true;
        correctAnswers.value++;
        _markQuestionComplete(q.id);
      }
    } else {
      // Wrong match — brief feedback
      incorrectMatch.value = translation;
      Future.delayed(const Duration(milliseconds: 600), () {
        incorrectMatch.value = null;
      });
    }
  }

  // === Info step — also mark as complete ===
  void completeInfoStep() {
    final q = currentQuestion;
    if (q != null) {
      _markQuestionComplete(q.id);
    }
    nextStep();
  }

  void _showCompletionDialog() {
    // Refresh the levels list & stats
    if (Get.isRegistered<MemorizationController>()) {
      Get.find<MemorizationController>().fetchLevels();
      Get.find<MemorizationController>().fetchStats();
    }

    Get.back();
    AppToast.success(
      message: 'Level selesai! $correctAnswers/$totalAnswerable jawaban benar.',
      title: 'Selamat! 🎉',
    );
  }
}

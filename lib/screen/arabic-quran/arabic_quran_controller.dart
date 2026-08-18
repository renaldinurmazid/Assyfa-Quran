import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/arabic_learning/arabic_level_model.dart';
import 'package:quran_app/models/arabic_learning/arabic_lesson_model.dart';
import 'package:quran_app/models/arabic_learning/arabic_quiz_model.dart';

class ArabicQuranController extends GetxController {
  static ArabicQuranController get to => Get.find<ArabicQuranController>();

  var isLoadingLevels = false.obs;
  var levels = <ArabicLevel>[].obs;

  var isLoadingLessons = false.obs;
  var currentLevelId = 0.obs;
  var currentLevel = Rxn<ArabicLevel>();
  var lessons = <ArabicLesson>[].obs;

  var isLoadingQuizzes = false.obs;
  var currentLessonId = 0.obs;
  var currentLesson = Rxn<ArabicLesson>();
  var quizzes = <ArabicQuiz>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLevels();
  }

  Future<void> fetchLevels() async {
    isLoadingLevels.value = true;
    try {
      final response = await Request().get(Url.arabicLevels);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        levels.value = data.map((json) => ArabicLevel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Gagal memuat level bahasa Arab');
    } finally {
      isLoadingLevels.value = false;
    }
  }

  Future<void> fetchLessons(int levelId) async {
    isLoadingLessons.value = true;
    currentLevelId.value = levelId;
    currentLevel.value = levels.firstWhereOrNull((l) => l.id == levelId);

    try {
      final response = await Request().get(Url.arabicLessons(levelId));
      if (response.statusCode == 200) {
        final List<dynamic> lessonsData = response.data['lessons'] ?? [];
        lessons.value = lessonsData
            .map((json) => ArabicLesson.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Gagal memuat pelajaran');
    } finally {
      isLoadingLessons.value = false;
    }
  }

  Future<void> fetchQuizzes(int lessonId) async {
    isLoadingQuizzes.value = true;
    currentLessonId.value = lessonId;
    currentLesson.value = lessons.firstWhereOrNull((l) => l.id == lessonId);

    try {
      final response = await Request().get(Url.arabicQuizzes(lessonId));
      if (response.statusCode == 200) {
        final List<dynamic> quizzesData = response.data['quizzes'] ?? [];
        quizzes.value = quizzesData
            .map((json) => ArabicQuiz.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Gagal memuat pertanyaan');
    } finally {
      isLoadingQuizzes.value = false;
    }
  }

  Future<bool> completeLesson(int lessonId, int score) async {
    try {
      final response = await Request().post(
        Url.arabicCompleteLesson(lessonId),
        data: {'score': score, 'xp_earned': score},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh levels and lessons to update progress
        fetchLevels();
        if (currentLevelId.value != 0) {
          fetchLessons(currentLevelId.value);
        }
        return true;
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan progres pembelajaran');
    }
    return false;
  }
}

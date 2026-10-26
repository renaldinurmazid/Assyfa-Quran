import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/arabic_learning/arabic_lesson_model.dart';
import 'package:quran_app/models/arabic_learning/arabic_level_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

/// Browsing side of the Arabic course: roadmap -> level lessons -> lesson detail.
/// Quizzes live in [ArabicQuizController].
class ArabicQuranController extends GetxController {
  static ArabicQuranController get to => Get.find<ArabicQuranController>();

  final isLoadingRoadmap = false.obs;
  final roadmapFailed = false.obs;
  final stats = Rxn<ArabicStats>();
  final phases = <ArabicPhase>[].obs;

  final isLoadingLessons = false.obs;
  final levelLessons = Rxn<ArabicLevelLessons>();

  final isLoadingDetail = false.obs;
  final lessonDetail = Rxn<ArabicLessonDetail>();

  @override
  void onInit() {
    super.onInit();
    fetchRoadmap();
  }

  /// Message from the API (`message`) when present, otherwise [fallback].
  static String errorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'];
    return fallback;
  }

  Future<void> fetchRoadmap() async {
    isLoadingRoadmap.value = true;
    roadmapFailed.value = false;
    try {
      final response = await Request().get(Url.arabicRoadmap);
      final roadmap = ArabicRoadmap.fromJson(response.data);
      stats.value = roadmap.stats;
      phases.value = roadmap.phases;
    } on DioException catch (e) {
      roadmapFailed.value = phases.isEmpty;
      AppToast.error(
        title: 'Gagal',
        message: errorMessage(e, 'Gagal memuat materi bahasa Arab.'),
      );
    } finally {
      isLoadingRoadmap.value = false;
    }
  }

  Future<void> fetchLessons(int levelId) async {
    // A different level must not flash the previous level's lessons.
    if (levelLessons.value?.levelId != levelId) levelLessons.value = null;
    isLoadingLessons.value = true;
    try {
      final response = await Request().get(Url.arabicLessons(levelId));
      levelLessons.value = ArabicLevelLessons.fromJson(response.data);
    } on DioException catch (e) {
      AppToast.error(
        title: 'Gagal',
        message: errorMessage(e, 'Gagal memuat pelajaran.'),
      );
    } finally {
      isLoadingLessons.value = false;
    }
  }

  Future<void> fetchLessonDetail(int lessonId) async {
    if (lessonDetail.value?.lesson.id != lessonId) lessonDetail.value = null;
    isLoadingDetail.value = true;
    try {
      final response = await Request().get(Url.arabicLesson(lessonId));
      lessonDetail.value = ArabicLessonDetail.fromJson(response.data);
    } on DioException catch (e) {
      AppToast.error(
        title: 'Gagal',
        message: errorMessage(e, 'Gagal memuat pelajaran.'),
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Called after a quiz finished so every screen below it shows fresh progress.
  Future<void> refreshProgress() async {
    final levelId = levelLessons.value?.levelId;
    final lessonId = lessonDetail.value?.lesson.id;
    await Future.wait([
      fetchRoadmap(),
      if (levelId != null) fetchLessons(levelId),
      if (lessonId != null) fetchLessonDetail(lessonId),
    ]);
  }
}

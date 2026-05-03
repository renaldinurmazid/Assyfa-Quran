import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/memorization_level_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class MemorizationController extends GetxController {
  final isLoadingLevels = false.obs;
  final levels = <MemorizationLevel>[].obs;

  // Stats
  final isLoadingStats = false.obs;
  final totalWordsMastered = 0.obs;
  final totalPoints = 0.obs;
  final rank = 0.obs;
  final highestLevelTitle = 'Belum memulai'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLevels();
    fetchStats();
  }

  Future<void> fetchLevels() async {
    isLoadingLevels.value = true;
    try {
      final response = await Request().get(Url.memorizationLevels);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        levels.assignAll(
          data.map((e) => MemorizationLevel.fromJson(e)).toList(),
        );
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat level',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat memuat level');
    } finally {
      isLoadingLevels.value = false;
    }
  }

  Future<void> fetchStats() async {
    isLoadingStats.value = true;
    try {
      final response = await Request().get(Url.memorizationStats);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        totalWordsMastered.value = data['total_words_mastered'] ?? 0;
        totalPoints.value = data['total_points'] ?? 0;
        rank.value = data['rank'] ?? 0;
        highestLevelTitle.value = data['highest_level']?['title'] ?? 'Belum ada';
      }
    } catch (e) {
      debugPrint('[MemorizationController] Error fetching stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }
}

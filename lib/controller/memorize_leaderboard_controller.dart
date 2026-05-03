import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/memorization_leaderboard_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class MemorizeLeaderboardController extends GetxController {
  final isLoading = false.obs;
  final leaderboardData = Rxn<MemorizeLeaderboard>();

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    isLoading.value = true;
    try {
      final response = await Request().get(Url.memorizationLeaderboard);
      if (response.statusCode == 200 && response.data['data'] != null) {
        leaderboardData.value = MemorizeLeaderboard.fromJson(response.data['data']);
      } else if (response.statusCode == 200) {
        // Handle case where status is 200 but data is null
        debugPrint('[MemorizeLeaderboardController] Response data is null');
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat peringkat',
        );
      }
    } catch (e) {
      debugPrint('[MemorizeLeaderboardController] Error: $e');
      AppToast.error(message: 'Terjadi kesalahan jaringan');
    } finally {
      isLoading.value = false;
    }
  }
}

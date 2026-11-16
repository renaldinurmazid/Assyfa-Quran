import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/widgets/app_toast.dart';

class LeaderboardController extends GetxController {
  final isLoading = false.obs;
  final filterIndex = 0.obs; // 0: Weekly, 1: Monthly

  final topUsers = <Map<String, dynamic>>[].obs;
  final otherUsers = <Map<String, dynamic>>[].obs;
  final myStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    isLoading.value = true;
    try {
      final type = filterIndex.value == 0 ? 'weekly' : 'monthly';
      final response = await Request().get('${Url.leaderboard}?filter=$type');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return;
        }

        final List leaderboardData = data['leaderboard'] ?? [];
        final Map<String, dynamic>? myData = data['my_stats'];

        // Sort by rank
        leaderboardData.sort(
          (a, b) => (a['rank'] as int).compareTo(b['rank'] as int),
        );

        // Split into top 3 and others
        if (leaderboardData.isNotEmpty) {
          if (leaderboardData.length >= 3) {
            topUsers.assignAll(
              leaderboardData
                  .take(3)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
            otherUsers.assignAll(
              leaderboardData
                  .skip(3)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          } else {
            topUsers.assignAll(
              leaderboardData.map((e) => Map<String, dynamic>.from(e)).toList(),
            );
            otherUsers.clear();
          }
        } else {
          topUsers.clear();
          otherUsers.clear();
        }

        if (myData != null) {
          myStats.assignAll(myData);
        } else {
          myStats.clear();
        }
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat data',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan koneksi');
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(int index) {
    if (filterIndex.value != index) {
      filterIndex.value = index;
      fetchLeaderboard();
    }
  }
}

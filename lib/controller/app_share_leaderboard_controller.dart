import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/leaderboard/app_share_leaderboard_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class AppShareLeaderboardController extends GetxController {
  final isLoading = false.obs;
  final filterIndex = 0.obs; // 0: Weekly, 1: Monthly
  final leaderboard = <LeaderboardEntry>[].obs;
  final myStats = Rxn<LeaderboardEntry>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final type = filterIndex.value == 0
          ? 'weekly'
          : filterIndex.value == 1
          ? 'monthly'
          : '';
      final response = await Request().get(
        '${Url.appShareLeaderboard}?filter=$type',
      );

      if (response.statusCode == 200) {
        final data = Data.fromJson(response.data['data']);
        leaderboard.assignAll(data.leaderboard);
        myStats.value = data.myStats;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat mengambil data');
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

  List<LeaderboardEntry> get topUsers => leaderboard.take(3).toList();
  List<LeaderboardEntry> get otherUsers => leaderboard.skip(3).toList();
}

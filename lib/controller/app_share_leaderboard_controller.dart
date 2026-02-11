import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/leaderboard/app_share_leaderboard_model.dart';

class AppShareLeaderboardController extends GetxController {
  final isLoading = false.obs;
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

      final response = await Request().get(Url.appShareLeaderboard);

      if (response.statusCode == 200) {
        final data = Data.fromJson(response.data['data']);
        leaderboard.assignAll(data.leaderboard);
        myStats.value = data.myStats;
      } else {
        errorMessage.value = 'Gagal memuat data peringkat';
      }
    } catch (e) {
      print("Error fetching app share leaderboard: $e");
      errorMessage.value = 'Terjadi kesalahan koneksi';
    } finally {
      isLoading.value = false;
    }
  }

  List<LeaderboardEntry> get topUsers => leaderboard.take(3).toList();
  List<LeaderboardEntry> get otherUsers => leaderboard.skip(3).toList();
}

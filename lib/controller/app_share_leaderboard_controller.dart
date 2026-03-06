import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/leaderboard/app_share_leaderboard_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

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
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat mengambil data');
    } finally {
      isLoading.value = false;
    }
  }

  List<LeaderboardEntry> get topUsers => leaderboard.take(3).toList();
  List<LeaderboardEntry> get otherUsers => leaderboard.skip(3).toList();
}

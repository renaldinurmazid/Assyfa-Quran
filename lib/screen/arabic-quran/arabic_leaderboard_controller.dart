import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/arabic_learning/arabic_leaderboard_model.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/widgets/app_toast.dart';

/// XP ranking of every learner, loaded page by page.
class ArabicLeaderboardController extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final failed = false.obs;
  final entries = <ArabicLeaderboardEntry>[].obs;
  final myStat = Rxn<ArabicLeaderboardEntry>();
  final total = 0.obs;

  int _page = 0;
  int _lastPage = 1;

  bool get hasMore => _page < _lastPage;

  @override
  void onInit() {
    super.onInit();
    refreshBoard();
  }

  Future<void> refreshBoard() async {
    isLoading.value = true;
    failed.value = false;
    try {
      final result = await _fetch(1);
      entries.assignAll(result.entries);
      myStat.value = result.myStat;
      total.value = result.total;
      _page = result.currentPage;
      _lastPage = result.lastPage;
    } on DioException catch (e) {
      failed.value = entries.isEmpty;
      AppToast.error(
        title: 'Gagal',
        message: ArabicQuranController.errorMessage(
          e,
          'Gagal memuat leaderboard.',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    try {
      final result = await _fetch(_page + 1);
      entries.addAll(result.entries);
      _page = result.currentPage;
      _lastPage = result.lastPage;
    } on DioException catch (e) {
      AppToast.error(
        title: 'Gagal',
        message: ArabicQuranController.errorMessage(
          e,
          'Gagal memuat peringkat berikutnya.',
        ),
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<ArabicLeaderboardPage> _fetch(int page) async {
    final response = await Request().get(
      Url.arabicLeaderboard,
      queryParameters: {'page': page},
    );
    return ArabicLeaderboardPage.fromJson(response.data);
  }
}

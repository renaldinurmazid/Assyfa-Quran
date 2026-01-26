import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/donation_history_model.dart';

class InfaqActivityController extends GetxController {
  var isLoading = true.obs;
  var donations = <DonationHistoryItem>[].obs;
  var currentPage = 1.obs;
  var hasNextPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDonationHistory();
  }

  Future<void> fetchDonationHistory({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        donations.clear();
      }

      isLoading.value = true;
      final response = await Request().get(
        '${Url.donations}?page=${currentPage.value}',
      );

      if (response.statusCode == 200) {
        final model = DonationHistoryModel.fromJson(response.data);
        donations.addAll(model.data.data);
        hasNextPage.value = model.data.nextPageUrl != null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat infaq: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (hasNextPage.value && !isLoading.value) {
      currentPage.value++;
      fetchDonationHistory();
    }
  }
}

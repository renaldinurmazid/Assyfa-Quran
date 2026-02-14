import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/campaign_donatur_model.dart';

class CharityDonaturController extends GetxController {
  final int campaignId = Get.arguments;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var donaturList = <DonaturItem>[].obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var total = 0.obs;
  var hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDonaturList();
  }

  Future<void> fetchDonaturList({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMore.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
        currentPage.value++;
      } else {
        isLoading.value = true;
        currentPage.value = 1;
        donaturList.clear();
        hasMore.value = true;
      }

      final response = await Request().get(
        '${Url.campaigns}/$campaignId/donors',
        queryParameters: {'page': currentPage.value},
      );

      if (response.statusCode == 200) {
        final model = CampaignDonaturModel.fromJson(response.data);
        donaturList.addAll(model.data.data);
        lastPage.value = model.data.lastPage;
        total.value = model.data.total;
        hasMore.value = currentPage.value < lastPage.value;
      } else {
        Get.snackbar('Error', 'Gagal memuat data donatur');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchDonaturList();
  }
}

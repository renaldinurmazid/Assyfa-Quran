import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/donation_history_model.dart';
import 'package:quran_app/models/mosque_donation_history_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class InfaqActivityController extends GetxController {
  var isLoading = true.obs;
  var selectedTab = 0.obs; // 0: Infaq, 1: Infaq Masjid

  // Infaq
  var donations = <DonationHistoryItem>[].obs;
  var currentPage = 1.obs;
  var hasNextPage = false.obs;

  // Infaq Masjid
  var mosqueDonations = <MosqueDonationHistoryItem>[].obs;
  var mosqueCurrentPage = 1.obs;
  var mosqueHasNextPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDonationHistory();
    fetchMosqueDonationHistory();
  }

  void changeTab(int index) {
    selectedTab.value = index;
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
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMosqueDonationHistory({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        mosqueCurrentPage.value = 1;
        mosqueDonations.clear();
      }

      isLoading.value = true;
      final response = await Request().get(
        '${Url.mosqueCharityPayment}?page=${mosqueCurrentPage.value}',
      );

      if (response.statusCode == 200) {
        final model = MosqueDonationHistoryModel.fromJson(response.data);
        mosqueDonations.addAll(model.data.data);
        mosqueHasNextPage.value = model.data.nextPageUrl != null;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (selectedTab.value == 0) {
      if (hasNextPage.value && !isLoading.value) {
        currentPage.value++;
        fetchDonationHistory();
      }
    } else {
      if (mosqueHasNextPage.value && !isLoading.value) {
        mosqueCurrentPage.value++;
        fetchMosqueDonationHistory();
      }
    }
  }
}

import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/donation_detail_model.dart';

class InfaqActivityDetailController extends GetxController {
  final int donationId;
  InfaqActivityDetailController({required this.donationId});

  var isLoading = true.obs;
  var donationDetail = Rxn<DonationDetailItem>();

  @override
  void onInit() {
    super.onInit();
    fetchDonationDetail();
  }

  Future<void> fetchDonationDetail() async {
    try {
      isLoading.value = true;
      final response = await Request().get('${Url.donations}/$donationId');

      if (response.statusCode == 200) {
        final model = DonationDetailModel.fromJson(response.data);
        donationDetail.value = model.data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail infaq: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

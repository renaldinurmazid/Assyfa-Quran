import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/mosque_donation_detail_model.dart';

class MosqueInfaqActivityDetailController extends GetxController {
  final int donationId;
  var isLoading = true.obs;
  var donationDetail = Rxn<MosqueDonationDetailItem>();

  MosqueInfaqActivityDetailController({required this.donationId});

  @override
  void onInit() {
    super.onInit();
    fetchDonationDetail();
  }

  Future<void> fetchDonationDetail() async {
    try {
      isLoading.value = true;
      final response = await Request().get(
        '${Url.mosqueCharityPayment}/$donationId',
      );

      if (response.statusCode == 200) {
        final model = MosqueDonationDetailModel.fromJson(response.data);
        donationDetail.value = model.data;
      }
    } catch (e) {
      print('Error fetching mosque donation detail: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

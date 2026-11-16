import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/mosque_donation_detail_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

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
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}

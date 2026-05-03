import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/campaign_detail_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CharityShowController extends GetxController {
  final int campaignId = Get.arguments['id'];
  var isLoading = true.obs;
  var campaign = Rxn<CampaignData>();
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaignDetail();
  }

  Future<void> fetchCampaignDetail() async {
    try {
      isLoading.value = true;
      final response = await Request().get('${Url.campaigns}/$campaignId');

      if (response.statusCode == 200) {
        final detailModel = CampaignDetailModel.fromJson(response.data);
        campaign.value = detailModel.data;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}

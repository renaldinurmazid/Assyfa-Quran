import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/campaign_detail_model.dart';

class CharityShowController extends GetxController {
  final int campaignId = Get.arguments['id'];
  var isLoading = true.obs;
  var campaign = Rxn<CampaignData>();

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
        Get.snackbar('Error', 'Failed to load campaign details');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

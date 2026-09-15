import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/campaign_detail_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CharityShowController extends GetxController {
  final int? id;
  CharityShowController({this.id});

  late int campaignId;
  var isLoading = true.obs;
  var campaign = Rxn<CampaignData>();
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initCampaignId();
    if (campaignId > 0) {
      fetchCampaignDetail();
    } else {
      isLoading.value = false;
    }
  }

  void _initCampaignId() {
    if (id != null && id! > 0) {
      campaignId = id!;
      return;
    }

    try {
      final dynamic args = Get.arguments;
      if (args is int) {
        campaignId = args;
      } else if (args is Map) {
        final dynamic rawId = args['id'] ?? args['campaignId'] ?? args['campaign_id'];
        if (rawId is int) {
          campaignId = rawId;
        } else if (rawId is String) {
          campaignId = int.tryParse(rawId) ?? 0;
        } else {
          campaignId = 0;
        }
      } else if (args is CampaignData) {
        campaignId = args.id;
        campaign.value = args;
      } else if (args is String) {
        campaignId = int.tryParse(args) ?? 0;
      } else if (Get.parameters.containsKey('id')) {
        campaignId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
      } else {
        campaignId = 0;
      }
    } catch (_) {
      campaignId = 0;
    }
  }

  Future<void> fetchCampaignDetail() async {
    if (campaignId <= 0) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final response = await Request().get('${Url.campaigns}/$campaignId');

      if (response.statusCode == 200) {
        final detailModel = CampaignDetailModel.fromJson(response.data);
        campaign.value = detailModel.data;
      } else {
        AppToast.error(message: response.data['message'] ?? 'Gagal memuat detail infaq');
      }
    } catch (e) {
      debugPrint('Error fetching campaign detail: $e');
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}

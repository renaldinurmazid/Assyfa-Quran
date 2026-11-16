import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/campaign_detail_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CalculatorZakatController extends GetxController {
  final isLoading = false.obs;

  Future<CampaignData?> getCampaignDetail(String slug) async {
    isLoading.value = true;
    try {
      final response = await Request().get('${Url.campaigns}/$slug');
      if (response.statusCode == 200) {
        final model = CampaignDetailModel.fromJson(response.data);
        return model.data;
      } else {
        AppToast.error(message: 'Gagal memuat data kampanye zakat');
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          AppToast.warning(message: data['message']);
          return null;
        }
      }
      AppToast.error(message: 'Terjadi kesalahan koneksi');
      return null;
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan tidak terduga');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}

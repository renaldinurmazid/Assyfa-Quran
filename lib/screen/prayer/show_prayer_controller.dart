import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class ShowPrayerController extends GetxController {
  final prayer = Rxn<PrayerItem>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final prayerId = Get.arguments as int?;
    if (prayerId != null) {
      fetchPrayerDetail(prayerId);
    }
  }

  Future<void> fetchPrayerDetail(int id) async {
    isLoading.value = true;
    try {
      final response = await Request().get(
        Url.prayerDetail(id),
        useToken: true,
      );
      if (response.statusCode == 200) {
        final prayerDetailResponse = PrayerDetailResponse.fromJson(
          response.data,
        );
        prayer.value = prayerDetailResponse.data;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat mengambil doa.');
    } finally {
      isLoading.value = false;
    }
  }
}

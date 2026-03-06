import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/mosque_charity_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class MosqueCharityShowController extends GetxController {
  final dynamic argument = Get.arguments;
  late final int mosqueId;

  var isLoading = true.obs;
  var mosque = Rxn<MosqueCharityData>();
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Support both passing ID directly or passing the full data object
    if (argument is int) {
      mosqueId = argument;
    } else if (argument is MosqueCharityData) {
      mosqueId = argument.id;
      // Optionally pre-populate if data is available
      mosque.value = argument;
    } else if (argument is Map && argument.containsKey('id')) {
      mosqueId = argument['id'];
    } else {
      mosqueId = 0;
    }

    fetchMosqueDetail();
  }

  Future<void> fetchMosqueDetail() async {
    if (mosqueId == 0) return;

    try {
      isLoading.value = true;
      final response = await Request().get('${Url.mosqueCharity}/$mosqueId');

      if (response.statusCode == 200) {
        // Assuming the structure is { "status": "success", "data": { ... } }
        mosque.value = MosqueCharityData.fromJson(response.data['data']);
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat detail masjid',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

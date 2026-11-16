import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/mosque_charity_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class MosqueCharityController extends GetxController {
  var mosqueCharityList = <MosqueCharityData>[].obs;
  var filteredMosqueList = <MosqueCharityData>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMosqueCharityList();
  }

  void searchMosque(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredMosqueList.assignAll(mosqueCharityList);
    } else {
      filteredMosqueList.assignAll(
        mosqueCharityList.where(
          (mosque) =>
              mosque.name.toLowerCase().contains(query.toLowerCase()) ||
              mosque.address.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  Future<void> fetchMosqueCharityList() async {
    try {
      isLoading.value = true;
      final response = await Request().get(
        '${Url.baseUrl}${Url.mosqueCharity}',
      );
      if (response.statusCode == 200) {
        final data = MosqueCharity.fromJson(response.data);
        mosqueCharityList.value = data.data;
        filteredMosqueList.assignAll(data.data);
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan koneksi');
    } finally {
      isLoading.value = false;
    }
  }
}

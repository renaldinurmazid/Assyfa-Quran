import 'package:get/get.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/mosque_charity_model.dart';
import 'package:http/http.dart' as http;

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
      final response = await http.get(
        Uri.parse('${Url.baseUrl}${Url.mosqueCharity}'),
      );
      if (response.statusCode == 200) {
        final data = mosqueCharityFromJson(response.body);
        mosqueCharityList.value = data.data;
        filteredMosqueList.assignAll(data.data);
      } else {
        Get.snackbar('Error', 'Failed to load mosque charity list');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

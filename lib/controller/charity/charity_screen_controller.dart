import 'package:get/get.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/charity_model.dart';
import 'package:http/http.dart' as http;

class CharityScreenController extends GetxController {
  var charityList = <Datum>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCharityList();
  }

  Future<void> fetchCharityList() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('${Url.baseUrl}${Url.campaigns}'),
      );
      if (response.statusCode == 200) {
        final data = charityFromJson(response.body);
        charityList.value = data.data;
      } else {
        Get.snackbar('Error', 'Failed to load charity list');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

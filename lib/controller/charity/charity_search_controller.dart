import 'package:get/get.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/charity_model.dart';
import 'package:http/http.dart' as http;

class CharitySearchController extends GetxController {
  var searchResults = <Datum>[].obs;
  var isLoading = false.obs;
  var query = ''.obs;

  void searchCharity(String q) async {
    if (q.isEmpty) {
      searchResults.clear();
      return;
    }

    query.value = q;
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('${Url.baseUrl}${Url.campaigns}?search=$q'),
      );
      if (response.statusCode == 200) {
        final data = charityFromJson(response.body);
        searchResults.value = data.data;
      } else {
        searchResults.clear();
      }
    } catch (e) {
      print("Search Error: $e");
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

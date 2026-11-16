import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/models/quran_list_model.dart';

class QuranListScreenController extends GetxController {
  final searchController = TextEditingController();
  final isLoading = false.obs;

  final quranList = <Datum>[].obs;

  @override
  void onInit() {
    super.onInit();
    getQuranList();
  }

  void onSearch(String query) async {
    final filteredList = quranList
        .where(
          (element) =>
              element.namaLatin.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    if (query.isEmpty) {
      await getQuranList();
    } else {
      quranList.value = filteredList;
    }
  }

  Future<void> getQuranList() async {
    isLoading.value = true;
    final response = await http.get(
      Uri.parse('https://equran.id/api/v2/surat'),
    );
    if (response.statusCode == 200) {
      final data = quranListModelFromJson(response.body);
      quranList.value = data.data;
    } else {
      Get.snackbar('Error', 'Failed to load quran list');
    }
    isLoading.value = false;
  }
}

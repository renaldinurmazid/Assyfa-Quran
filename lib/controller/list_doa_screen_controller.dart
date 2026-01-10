import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran_app/models/doa_model.dart';

class ListDoaScreenController extends GetxController {
  final data = <DoaModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoaData();
  }

  Future<void> loadDoaData() async {
    try {
      isLoading.value = true;
      final String jsonString = await rootBundle.loadString(
        'assets/data/doa.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> doaList = jsonData['data'];
      data.value = doaList.map((item) => DoaModel.fromJson(item)).toList();
    } catch (e) {
      print('Error loading doa data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data doa',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

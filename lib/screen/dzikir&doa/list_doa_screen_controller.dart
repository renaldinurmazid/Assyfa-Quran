import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran_app/models/doa_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

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
      AppToast.error(message: 'Gagal memuat data doa');
    } finally {
      isLoading.value = false;
    }
  }
}

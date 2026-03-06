import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran_app/models/dzikir_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class DzikirShowScreenController extends GetxController {
  final title = ''.obs;
  final data = <DzikirModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      title.value = Get.arguments['title'] ?? '';
      final dataPath = Get.arguments['data'] ?? '';
      if (dataPath.isNotEmpty) {
        loadDzikirData(dataPath);
      }
    }
  }

  Future<void> loadDzikirData(String path) async {
    try {
      isLoading.value = true;
      final String jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonData = json.decode(jsonString);
      data.value = jsonData.map((item) => DzikirModel.fromJson(item)).toList();
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat memuat data dzikir');
    } finally {
      isLoading.value = false;
    }
  }
}

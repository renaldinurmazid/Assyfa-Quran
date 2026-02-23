import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/home_screen_controller.dart';

class CreatePrayerController extends GetxController {
  final contentController = TextEditingController();
  final isAnonymous = false.obs;
  final isLoading = false.obs;

  Future<void> submitPrayer() async {
    if (contentController.text.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Tuliskan doa Anda terlebih dahulu.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await Request().post(
        Url.prayers,
        data: {
          'content': contentController.text,
          'is_anonymous': isAnonymous.value,
        },
        useToken: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        if (Get.isRegistered<HomeScreenController>()) {
          Get.find<HomeScreenController>().fetchPrayers();
        }
        Get.snackbar(
          'Berhasil',
          'Doa Anda berhasil dikirim.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mengirim doa.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CreatePrayerController extends GetxController {
  final contentController = TextEditingController();
  final isAnonymous = false.obs;
  final isLoading = false.obs;

  Future<void> submitPrayer() async {
    if (contentController.text.isEmpty) {
      AppToast.warning(message: 'Tuliskan doa Anda terlebih dahulu.');
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
        AppToast.success(message: response.data['message']);
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat mengirim doa.');
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/group/group_ngaji_screen_controller.dart';

class CreateGroupController extends GetxController {
  final nameController = TextEditingController();
  final isPrivate = false.obs;
  final isLoading = false.obs;

  Future<void> createGroup() async {
    try {
      if (nameController.text.isEmpty) {
        Get.snackbar("Error", "Nama grup tidak boleh kosong");
        return;
      }

      isLoading.value = true;

      final response = await Request().post(
        Url.groups,
        data: {
          'name': nameController.text,
          'is_private': isPrivate.value ? 1 : 0,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.back(); // Kembali ke halaman list grup
        Get.snackbar("Success", "Grup berhasil dibuat");
      } else {
        final data = response.data;
        Get.snackbar("Error", data['message'] ?? "Gagal membuat grup");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

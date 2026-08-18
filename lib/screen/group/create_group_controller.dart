import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/screen/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CreateGroupController extends GetxController {
  final nameController = TextEditingController();
  final isPrivate = false.obs;
  final isLoading = false.obs;

  Future<void> createGroup() async {
    try {
      if (nameController.text.isEmpty) {
        AppToast.error(message: 'Nama grup tidak boleh kosong');
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
        AppToast.success(message: response.data['message']);
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
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

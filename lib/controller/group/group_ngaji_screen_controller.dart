import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/group/group_model.dart';

class GroupNgajiScreenController extends GetxController {
  final pageController = PageController();
  final isGroupSaya = true.obs;
  final isLoading = false.obs;
  final myGroups = <Datum>[].obs;

  @override
  void onInit() {
    super.onInit();
    getGroups();
  }

  void getGroups() {
    if (AuthController.to.isLogin.value) {
      fetchMyGroups();
    } else {
      return;
    }
  }

  Future<void> fetchMyGroups() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.groups, useToken: true);

      if (response.statusCode == 200) {
        final groupsData = Groups.fromJson(response.data);
        myGroups.assignAll(groupsData.data);
      } else {
        Get.snackbar("Error", "Gagal mengambil data grup");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
    fetchMyGroups();
  }

  Future<void> fetchMyGroups() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(Url.baseUrl + Url.groups),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final groupsData = groupsFromJson(response.body);
        myGroups.assignAll(groupsData.data);
      } else {
        Get.snackbar("Error", "Gagal mengambil data grup");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/group/show_group_controller.dart';
import 'package:quran_app/models/group/member_group_tilawah.dart';
import 'package:quran_app/theme/app_color.dart';

class ShowMemberController extends GetxController {
  final isLoading = false.obs;
  final group = Rxn<Data>();
  int? groupId;
  int? creatorId;

  bool get isOwner =>
      AuthController.to.userData['id'] == (creatorId ?? group.value?.id);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is int) {
      groupId = Get.arguments;
    } else if (Get.arguments is Map) {
      groupId = Get.arguments['groupId'];
      creatorId = Get.arguments['creatorId'];
    }

    if (groupId != null) {
      fetchMemberTilawah();
    }
  }

  Future<void> fetchMemberTilawah() async {
    try {
      isLoading.value = true;
      final response = await Request().get(
        '${Url.baseUrl}${Url.groups}/$groupId/member-group-tilawah',
      );

      if (response.statusCode == 200) {
        final result = MemberGroupTilawah.fromJson(response.data);
        group.value = result.data;
      } else {
        Get.snackbar('Error', 'Gagal mengambil data anggota');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengambil data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> dropUser(int userId) async {
    // Show Loading Dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      ),
      barrierDismissible: false,
    );

    try {
      isLoading.value = true;
      final response = await Request().post(
        '${Url.baseUrl}${Url.groups}/drop-user',
        data: {'group_id': groupId, 'user_id': userId},
      );

      if (response.statusCode == 200) {
        Get.back(); // Close loading dialog
        Get.back(); // Close confirmation dialog
        Get.snackbar('Success', 'Anggota berhasil dikeluarkan');
        fetchMemberTilawah(); // Refresh list
        Get.find<ShowGroupController>().fetchGroupDetail(groupId!);
      } else {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Gagal mengeluarkan anggota',
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Terjadi kesalahan saat mengeluarkan anggota');
    } finally {
      isLoading.value = false;
    }
  }
}

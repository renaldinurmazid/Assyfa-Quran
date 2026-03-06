import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/controller/group/show_group_controller.dart';
import 'package:quran_app/models/group/user_for_group_list.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:share_plus/share_plus.dart';

class AddMemberGroupController extends GetxController {
  final isLoading = false.obs;
  final users = <Datum>[].obs;
  final filteredUsers = <Datum>[].obs;
  final searchController = TextEditingController();
  int? groupId;
  final shareUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    groupId = Get.arguments;
    fetchUsers();
    fetchGroupShareUrl();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchGroupShareUrl() async {
    try {
      final response = await Request().get(
        '${Url.baseUrl}${Url.groups}/$groupId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        shareUrl.value = data['data']['share_url'] ?? '';
      }
    } catch (e) {
      print("Error fetching share url: $e");
    }
  }

  void shareGroup() {
    if (shareUrl.value.isNotEmpty) {
      Share.share(
        'Yuk bergabung ke grup ngaji saya di Assyfa Quran! Klik link berikut: ${shareUrl.value}',
        subject: 'Undangan Grup Ngaji',
      );
    } else {
      Get.snackbar('Gagal', 'Tautan berbagi belum tersedia');
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    if (searchController.text.isEmpty) {
      filteredUsers.assignAll(users);
    } else {
      filteredUsers.assignAll(
        users
            .where(
              (user) => user.name.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
            )
            .toList(),
      );
    }
  }

  Future<void> addUserToGroup(int userId) async {
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
        '${Url.baseUrl}${Url.groups}/add-user',
        data: {'user_id': userId, 'group_id': groupId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchUsers();
        await Get.find<ShowGroupController>().fetchGroupDetail(groupId!);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();

        Get.back(); // Close loading dialog
        Get.back(); // Close confirmation dialog
        Get.snackbar('Success', 'Anggota berhasil ditambahkan');
      } else {
        Get.back(); // Close loading dialog
        Get.snackbar('Error', 'Gagal menambahkan anggota');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan anggota');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await Request().get(
        '${Url.baseUrl}${Url.groups}/$groupId/list-user',
      );

      if (response.statusCode == 200) {
        final data = UserForMemberGroup.fromJson(response.data);
        users.assignAll(data.data);
        filteredUsers.assignAll(data.data);
      } else {
        Get.snackbar('Error', 'Gagal mengambil daftar pengguna');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil daftar pengguna');
    } finally {
      isLoading.value = false;
    }
  }
}

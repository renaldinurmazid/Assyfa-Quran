import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/controller/group/show_group_controller.dart';
import 'package:quran_app/models/group/user_for_group_list.dart';

class AddMemberGroupController extends GetxController {
  final isLoading = false.obs;
  final users = <Datum>[].obs;
  final filteredUsers = <Datum>[].obs;
  final searchController = TextEditingController();
  int? groupId;

  @override
  void onInit() {
    super.onInit();
    groupId = Get.arguments;
    fetchUsers();
    searchController.addListener(_onSearchChanged);
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
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse("${Url.baseUrl}${Url.groups}/add-user"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': userId, 'group_id': groupId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchUsers();
        await Get.find<ShowGroupController>().fetchGroupDetail(groupId!);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.back();
        Get.snackbar('Success', 'Anggota berhasil ditambahkan');
      } else {
        Get.snackbar('Error', 'Gagal menambahkan anggota');
      }

      isLoading.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan anggota');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse("${Url.baseUrl}${Url.groups}/$groupId/list-user"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = userForMemberGroupFromJson(response.body);
        users.assignAll(data.data);
        filteredUsers.assignAll(data.data);
      } else {
        Get.snackbar('Error', 'Gagal mengambil daftar pengguna');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Gagal mengambil daftar pengguna');
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/models/group/group_show_model.dart';

class ShowGroupController extends GetxController {
  final isLoading = false.obs;
  final group = Rxn<Data>();
  final nameController = TextEditingController();
  final isPrivate = false.obs;

  void copyToClipboard() {
    if (group.value != null) {
      Clipboard.setData(ClipboardData(text: group.value!.code));
      Get.snackbar('Success', 'Kode grup berhasil disalin');
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      fetchGroupDetail(Get.arguments);
    }
  }

  Future<void> fetchGroupDetail(int id) async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse("${Url.baseUrl}${Url.groups}/$id"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        group.value = Data.fromJson(data['data']);
        nameController.text = group.value?.name ?? '';
        isPrivate.value = group.value?.isPrivate == 1;
      } else {
        Get.snackbar('Error', 'Failed to fetch group detail');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch group detail');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroup() async {
    try {
      if (nameController.text.isEmpty) {
        Get.snackbar('Error', 'Nama grup tidak boleh kosong');
        return;
      }

      isLoading.value = true;
      final response = await http.put(
        Uri.parse("${Url.baseUrl}${Url.groups}/${group.value!.id}"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'is_private': isPrivate.value ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        group.value = Data.fromJson(data['data']);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.back();
        Get.snackbar('Success', 'Grup berhasil diperbarui');
      } else {
        Get.snackbar('Error', 'Gagal memperbarui grup');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Gagal memperbarui grup');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGroup() async {
    try {
      isLoading.value = true;
      final response = await http.delete(
        Uri.parse("${Url.baseUrl}${Url.groups}/${group.value!.id}"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.back();
        Get.back();
        Get.snackbar('Success', 'Grup berhasil dihapus');
      } else {
        Get.snackbar('Error', 'Gagal menghapus grup');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus grup');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadCoverImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      isLoading.value = true;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "${Url.baseUrl}${Url.groups}/${group.value!.id}/change-cover-image",
        ),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${AuthController.to.token.value}',
        'Accept': 'application/json',
      });

      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        group.value = Data.fromJson(data['data']);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.snackbar('Success', 'Cover grup berhasil diperbarui');
      } else {
        Get.snackbar('Error', 'Gagal memperbarui cover grup');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Gagal memperbarui cover grup');
    } finally {
      isLoading.value = false;
    }
  }

  bool get isMember {
    if (group.value == null) return false;
    if (!AuthController.to.isLogin.value) return false;
    final currentUserId = AuthController.to.userData['id'];
    return group.value!.groupUser.any((gu) => gu.userId == currentUserId);
  }

  Future<void> joinGroup() async {
    try {
      if (!AuthController.to.isLogin.value) {
        Get.snackbar('Peringatan', 'Silakan login terlebih dahulu');
        return;
      }

      isLoading.value = true;
      final currentUserId = AuthController.to.userData['id'];
      final response = await http.post(
        Uri.parse("${Url.baseUrl}${Url.groups}/add-user"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': currentUserId,
          'group_id': group.value!.id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchGroupDetail(group.value!.id);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.snackbar('Success', 'Berhasil bergabung ke grup');
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Gagal bergabung ke grup');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat bergabung');
    } finally {
      isLoading.value = false;
    }
  }
}

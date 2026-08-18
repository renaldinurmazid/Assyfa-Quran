import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/models/group/group_show_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class ShowGroupController extends GetxController {
  final isLoading = false.obs;
  final group = Rxn<Data>();
  final nameController = TextEditingController();
  final isPrivate = false.obs;

  void copyToClipboard() {
    if (group.value != null) {
      Clipboard.setData(ClipboardData(text: group.value!.code));
      AppToast.success(message: 'Kode grup berhasil disalin');
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final arg = Get.arguments;
      if (arg is int) {
        // From normal navigation (group list → show)
        fetchGroupDetail(arg);
      } else if (arg is String) {
        // From deep link: /g/{code} → code is a String
        final asInt = int.tryParse(arg);
        if (asInt != null) {
          fetchGroupDetail(asInt);
        } else {
          fetchGroupByCode(arg);
        }
      }
    }
  }

  Future<void> fetchGroupByCode(String code) async {
    try {
      isLoading.value = true;
      final response = await Request().get(
        "${Url.groups}/by-code/$code",
        useToken: true,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        group.value = Data.fromJson(data['data']);
        nameController.text = group.value?.name ?? '';
        isPrivate.value = group.value?.isPrivate == 1;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGroupDetail(int id) async {
    try {
      isLoading.value = true;
      final response = await Request().get("${Url.groups}/$id", useToken: true);

      if (response.statusCode == 200) {
        final data = response.data;
        group.value = Data.fromJson(data['data']);
        nameController.text = group.value?.name ?? '';
        isPrivate.value = group.value?.isPrivate == 1;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroup() async {
    try {
      if (nameController.text.isEmpty) {
        AppToast.error(message: 'Nama grup tidak boleh kosong');
        return;
      }

      isLoading.value = true;
      final response = await Request().put(
        "${Url.groups}/${group.value!.id}",
        data: {
          'name': nameController.text,
          'is_private': isPrivate.value ? 1 : 0,
        },
      );

      if (response.statusCode == 200) {
        await fetchGroupDetail(group.value!.id);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.back();
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

  Future<void> deleteGroup() async {
    try {
      isLoading.value = true;
      final response = await Request().delete(
        "${Url.groups}/${group.value!.id}",
      );

      if (response.statusCode == 200) {
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        Get.back();
        Get.back();
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

  Future<void> pickAndUploadCoverImage() async {
    try {
      if (group.value == null) return;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      isLoading.value = true;

      final response = await Request().postMultipart(
        "${Url.groups}/${group.value!.id}/change-cover-image",
        {'image': await dio.MultipartFile.fromFile(image.path)},
      );

      if (response.statusCode == 200) {
        await fetchGroupDetail(group.value!.id);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
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

  bool get isMember {
    if (group.value == null) return false;
    if (!AuthController.to.isLogin.value) return false;
    final currentUserId = AuthController.to.userData['id'];
    return group.value!.groupUser.any((gu) => gu.userId == currentUserId);
  }

  Future<void> joinGroup() async {
    try {
      if (!AuthController.to.isLogin.value) {
        AppToast.error(message: 'Silakan login terlebih dahulu');
        return;
      }

      isLoading.value = true;
      final currentUserId = AuthController.to.userData['id'];
      final response = await Request().post(
        "${Url.groups}/add-user",
        data: {'user_id': currentUserId, 'group_id': group.value!.id},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchGroupDetail(group.value!.id);
        await Get.find<GroupNgajiScreenController>().fetchMyGroups();
        AppToast.success(message: 'Berhasil bergabung ke grup');
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal bergabung ke grup',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat bergabung');
    } finally {
      isLoading.value = false;
    }
  }
}

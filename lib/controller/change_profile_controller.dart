import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ChangeProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Isi field dengan data yang sudah ada
    nameController.text = AuthController.to.userData['name'] ?? '';
    emailController.text = AuthController.to.userData['email'] ?? '';
    phoneController.text = AuthController.to.userData['phone_number'] ?? '';
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> updateProfile() async {
    try {
      if (nameController.text.isEmpty) {
        AppToast.error(message: 'Nama tidak boleh kosong');
        return;
      }

      final Map<String, dynamic> data = {
        'name': nameController.text,
        'phone_number': phoneController.text,
      };

      if (selectedImage.value != null) {
        data['image'] = await dio.MultipartFile.fromFile(
          selectedImage.value!.path,
        );
      }

      final response = await Request().postMultipart(Url.changeProfile, data);

      if (response.statusCode == 200) {
        final userData = response.data['user'];

        // Update data user di AuthController dan Local Storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(userData));
        AuthController.to.userData.value = Map<String, dynamic>.from(userData);

        Get.back(); // Kembali ke halaman profil
        AppToast.success(
          message: response.data['message'] ?? "Profil berhasil diperbarui",
        );
      } else {
        AppToast.error(
          message: response.data['message'] ?? "Gagal memperbarui profil",
        );
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
    emailController.dispose();
    super.onClose();
  }
}

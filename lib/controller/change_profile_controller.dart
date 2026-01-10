import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ChangeProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Isi field dengan data yang sudah ada
    nameController.text = AuthController.to.userData['name'] ?? '';
    emailController.text = AuthController.to.userData['email'] ?? '';
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
        Get.snackbar("Error", "Nama tidak boleh kosong");
        return;
      }

      isLoading.value = true;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Url.baseUrl + Url.changeProfile),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${AuthController.to.token.value}',
        'Accept': 'application/json',
      });

      request.fields['name'] = nameController.text;

      if (selectedImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', selectedImage.value!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update data user di AuthController dan Local Storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        AuthController.to.userData.value = data['user'];

        Get.back(); // Kembali ke halaman profil
        Get.snackbar("Success", "Profil berhasil diperbarui");
      } else {
        print(response.body);
        Get.snackbar(
          "Error",
          "Gagal memperbarui profil: ${response.statusCode}",
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", e.toString());
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

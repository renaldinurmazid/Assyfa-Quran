import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/widgets/app_toast.dart';

class MosqueAddController extends GetxController {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final aboutController = TextEditingController();

  final _pickedImage = Rxn<XFile>();
  XFile? get pickedImage => _pickedImage.value;

  final _selectedLocation = const LatLng(-6.5715, 107.7587).obs;
  LatLng get selectedLocation => _selectedLocation.value;

  final imagePicker = ImagePicker();
  final isLoading = false.obs;

  Future<void> pickImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      _pickedImage.value = image;
    }
  }

  void updateLocation(LatLng location) {
    _selectedLocation.value = location;
  }

  Future<void> createMosque() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        cityController.text.isEmpty ||
        pickedImage == null) {
      AppToast.error(message: "Mohon lengkapi semua data");
      return;
    }

    isLoading.value = true;
    try {
      final Map<String, dynamic> data = {
        'name': nameController.text,
        'city': cityController.text,
        'latitude': selectedLocation.latitude,
        'longitude': selectedLocation.longitude,
        'address': addressController.text,
        'no_telepon': phoneController.text,
        'about': aboutController.text,
        'cover_image': await dio.MultipartFile.fromFile(
          pickedImage!.path,
          filename: pickedImage!.name,
        ),
      };

      final response = await Request().postMultipart(Url.mosqueCharity, data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        AppToast.success(message: "Masjid berhasil ditambahkan");
        Get.back();
      } else {
        AppToast.error(
          message: response.data['message'] ?? "Gagal menambahkan masjid",
        );
      }
    } catch (e) {
      AppToast.error(message: "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.onClose();
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/mosque/mosque_add_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';
import 'package:quran_app/widgets/keyboard_avoiding_bar.dart';

class MosqueAddScreen extends GetView<MosqueAddController> {
  const MosqueAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Masjid", style: pSemiBold16),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildInputSection(context),
              const SizedBox(height: 18),
              _buildImageSection(context),
              const SizedBox(height: 18),
              _buildLocationSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KeyboardAvoidingBar(
        child: _buildBottomAction(context),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi Masjid",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextInput(
            controller: controller.nameController,
            hintText: "Nama Masjid",
          ),
          const SizedBox(height: 12),
          TextInput(
            controller: controller.addressController,
            hintText: "Alamat Lengkap",
          ),
          const SizedBox(height: 12),
          TextInput(
            controller: controller.cityController,
            hintText: "Kota / Kabupaten",
          ),
          const SizedBox(height: 12),
          TextInput(
            controller: controller.phoneController,
            hintText: "Nomor Telepon",
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextInput(
            controller: controller.aboutController,
            hintText: "Tentang Masjid",
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Foto Masjid",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  border: Border.all(color: AppColor.globalBorder, width: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  image: controller.pickedImage != null
                      ? DecorationImage(
                          image: FileImage(File(controller.pickedImage!.path)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.pickedImage == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.imagePlus,
                            size: 34,
                            color: AppColor.globalTextSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tambah Foto Masjid",
                            style: pMedium12.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.camera,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lokasi Peta",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.globalBorder, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: controller.selectedLocation,
                    initialZoom: 14.0,
                    onPositionChanged: (camera, hasGesture) {
                      controller.updateLocation(camera.center);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.assyfa.quran_app',
                    ),
                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 34),
                    child: Icon(
                      Icons.location_on,
                      color: AppColor.primaryColor,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.globalBorder.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.mapPin,
                  size: 16,
                  color: AppColor.globalTextSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Text(
                      "Lat: ${controller.selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${controller.selectedLocation.longitude.toStringAsFixed(6)}",
                      style: pMedium10.copyWith(
                        color: AppColor.globalTextSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          disabledBackgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => controller.createMosque(),
        child: Obx(
          () => controller.isLoading.value
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Buat Masjid",
                  style: pMedium12.copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }
}

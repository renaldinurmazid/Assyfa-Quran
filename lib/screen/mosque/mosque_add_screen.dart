import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/mosque_add_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class MosqueAddScreen extends GetView<MosqueAddController> {
  const MosqueAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Masjid", style: pSemiBold16)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(
                  controller: controller.nameController,
                  hintText: "Nama Masjid",
                ),
                const SizedBox(height: 12),
                TextInput(
                  controller: controller.addressController,
                  hintText: "Alamat Masjid",
                ),
                const SizedBox(height: 12),
                TextInput(
                  controller: controller.cityController,
                  hintText: "Kota/Kab masjid berada",
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
                const SizedBox(height: 12),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.pickImage(),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        image: controller.pickedImage != null
                            ? DecorationImage(
                                image: FileImage(
                                  File(controller.pickedImage!.path),
                                ),
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
                                  Icons.photo_library_outlined,
                                  size: 34,
                                  color: context.isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tambah Foto Masjid",
                                  style: pRegular12.copyWith(
                                    color: context.isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Pilih Lokasi Masjid", style: pMedium12),
                const SizedBox(height: 8),
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
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
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    "Lat: ${controller.selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${controller.selectedLocation.longitude.toStringAsFixed(6)}",
                    style: pRegular10.copyWith(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => controller.createMosque(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Obx(
              () => controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Buat",
                      style: pSemiBold16.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

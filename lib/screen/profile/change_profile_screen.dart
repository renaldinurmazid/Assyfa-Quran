import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/change_profile_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class ChangeProfileScreen extends StatelessWidget {
  const ChangeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(ChangeProfileController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text('Ubah Profil', style: pBold18),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Profile Picture Section
              Obx(
                () => Center(
                  child: Stack(
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: controller.selectedImage.value != null
                              ? DecorationImage(
                                  image: FileImage(
                                    controller.selectedImage.value!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : (AuthController
                                            .to
                                            .userData['profile_picture'] !=
                                        null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          AuthController
                                              .to
                                              .userData['profile_picture'],
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child:
                            controller.selectedImage.value == null &&
                                AuthController.to.userData['profile_picture'] ==
                                    null
                            ? Icon(
                                IconlyBold.profile,
                                size: 45,
                                color: AppColor.primaryColor.withOpacity(0.2),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              IconlyBold.camera,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Form Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Nama Lengkap', style: pSemiBold14),
              ),
              const SizedBox(height: 10),
              TextInput(
                controller: controller.nameController,
                hintText: 'Masukkan nama lengkap',
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: pSemiBold14),
              ),
              const SizedBox(height: 10),
              TextInput(
                controller: controller.emailController,
                hintText: 'Email Anda',
                readOnly: true,
              ),

              const SizedBox(height: 50),

              // Save Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.updateProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: pSemiBold16.copyWith(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: Text('Ubah Profile', style: pSemiBold16),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    image: controller.selectedImage.value != null
                        ? DecorationImage(
                            image: FileImage(controller.selectedImage.value!),
                            fit: BoxFit.cover,
                          )
                        : (AuthController.to.userData['profile_picture'] != null
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
                  child: Stack(
                    children: [
                      if (controller.selectedImage.value == null &&
                          AuthController.to.userData['profile_picture'] == null)
                        Center(
                          child: Icon(
                            Icons.person,
                            size: 26,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.image_rounded,
                              size: 14,
                              color: AppColor.backgroundColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextInput(
                controller: controller.nameController,
                hintText: 'Nama Lengkap',
              ),
              const SizedBox(height: 16),
              TextInput(
                controller: controller.emailController,
                hintText: 'Email',
                readOnly: true,
              ),
              const SizedBox(height: 40),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.updateProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    fixedSize: const Size(double.maxFinite, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColor.backgroundColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: pMedium14.copyWith(
                            color: AppColor.backgroundColor,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

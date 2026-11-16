import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/profile/change_profile_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/widgets/text_input.dart';

class ChangeProfileScreen extends StatelessWidget {
  const ChangeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(ChangeProfileController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Ubah Profil', style: pSemiBold16),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: context.theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.globalBorder,
                            width: 2,
                          ),
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
                                LucideIcons.user,
                                size: 40,
                                color: AppColor.globalTextSecondary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.theme.scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.camera,
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
              const SizedBox(height: 32),

              // Form Section
              _buildInputLabel(context, 'Nama Lengkap'),
              const SizedBox(height: 8),
              TextInput(
                controller: controller.nameController,
                hintText: 'Masukkan nama lengkap',
              ),
              const SizedBox(height: 20),

              _buildInputLabel(context, 'Nomor Telepon'),
              const SizedBox(height: 8),
              TextInput(
                controller: controller.phoneController,
                hintText: 'Nomor Telepon Anda',
                keyboardType: TextInputType.phone,
                readOnly: false,
              ),
              const SizedBox(height: 20),

              _buildInputLabel(context, 'Email'),
              const SizedBox(height: 8),
              TextInput(
                controller: controller.emailController,
                hintText: 'Email Anda',
                readOnly: true,
              ),

              const SizedBox(height: 40),

              // Save Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.updateProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    disabledBackgroundColor: AppColor.primaryColor
                        .withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: pSemiBold14.copyWith(color: Colors.white),
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

  Widget _buildInputLabel(BuildContext context, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label,
          style: pSemiBold12.copyWith(
            color: AppColor.globalTextSecondary,
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/event/event_registration_form_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class EventRegistrationFormScreen extends StatelessWidget {
  const EventRegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventRegistrationFormController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Text(
          'Pendaftaran Event',
          style: pSemiBold16.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.event.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informasi Pribadi'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.nameController,
                  label: 'Nama Lengkap (Wajib)',
                  icon: IconlyLight.profile,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.emailController,
                  label: 'Email Aktif (Wajib)',
                  icon: IconlyLight.message,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.phoneController,
                  label: 'Nomor WA (Wajib)',
                  icon: IconlyLight.call,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Nomor WA wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.domicileController,
                  label: 'Domisili (Opsional)',
                  icon: IconlyLight.location,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.jobActivityController,
                  label: 'Pekerjaan (Opsional)',
                  icon: IconlyLight.work,
                ),

                const SizedBox(height: 28),
                _buildSectionTitle('Informasi Tambahan'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.infoSourceController,
                  label: 'Tahu info dari mana? (Opsional)',
                  icon: IconlyLight.info_square,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.communityController,
                  label: 'Asal Komunitas (Opsional)',
                  hint: 'Assyifa/ODOJ/Yakesma/dll',
                  icon: Icons.people_outline,
                ),

                const SizedBox(height: 28),
                _buildSectionTitle('Donasi & Bukti Transfer'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.operationalDonationController,
                  label: 'Donasi Operasional (Opsional)',
                  hint: 'Nominal',
                  icon: IconlyLight.wallet,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                _buildImagePicker(controller, context),

                const SizedBox(height: 24),
                _buildInstagramCheckbox(controller, context),

                const SizedBox(height: 40),
                _buildSubmitButton(controller, context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: pSemiBold14.copyWith(color: Colors.grey.shade600),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<dynamic>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters?.cast(),
      style: pRegular14,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: pRegular14.copyWith(color: Colors.grey.shade500),
        hintText: hint,
        hintStyle: pRegular14.copyWith(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
      ),
    );
  }

  Widget _buildImagePicker(
      EventRegistrationFormController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Transfer (Opsional)',
          style: pRegular14.copyWith(color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.pickImage(),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: controller.transferProof.value != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      controller.transferProof.value!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconlyLight.image,
                          size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih gambar',
                        style: pRegular12.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramCheckbox(
      EventRegistrationFormController controller, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() => SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
                value: controller.instagramFollowed.value,
                onChanged: (value) {
                  if (value != null) controller.instagramFollowed.value = value;
                },
                activeColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: Colors.grey.shade400),
              ),
        )),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Follow IG @quranuna_official (Opsional)',
                style: pMedium14.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(
                      'https://www.instagram.com/quranuna_official?igsh=MWdxdXNjbzI4YmQzZg==');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text(
                  'Buka Instagram',
                  style: pRegular12.copyWith(
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      EventRegistrationFormController controller, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : () => controller.submitForm(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isSubmitting.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Lanjutkan',
                style: pSemiBold14.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}

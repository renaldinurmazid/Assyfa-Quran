import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/group/create_group_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class CreateGroupNgajiScreen extends StatelessWidget {
  const CreateGroupNgajiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateGroupController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        title: Text('Buat Grup Ngaji', style: pSemiBold16),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Yuk, buat grup ngaji! ajak temanmu untuk bergabung, raih berlipat pahala dan kebaikan',
              style: pSemiBold14,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextInput(
              controller: controller.nameController,
              hintText: 'Nama Grup',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set Private Grup', style: pSemiBold14),
                      Text(
                        'Informasi grup hanya bisa dilihat oleh anggota grup',
                        style: pRegular12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Switch(
                    value: controller.isPrivate.value,
                    onChanged: (value) {
                      controller.isPrivate.value = value;
                    },
                    activeColor: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.createGroup(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  fixedSize: const Size(double.maxFinite, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
    );
  }
}

import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/find-qiblat/find_qiblat_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class FindQiblatScreen extends StatelessWidget {
  const FindQiblatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FindQiblatController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text('Arah Qiblat', style: pSemiBold16),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasPermission.value) {
            return Center(
              child: Text(
                'Izin lokasi diperlukan untuk menentukan arah Qiblat.',
                style: pMedium14,
                textAlign: TextAlign.center,
              ),
            );
          }

          // Calculate the rotation angle (in radians)
          // We rotate the compass so that its top (0 degrees) points to the Qibla.
          final qiblaAngle = controller.qiblaDirection.value;
          final headingAngle = controller.heading.value;
          final rotationAngle = (qiblaAngle - headingAngle) * (pi / 180.0);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (controller.needsCalibration.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, left: 24, right: 24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        "Akurasi kompas rendah. Kalibrasikan dengan menggerakkan ponsel Anda membentuk angka 8.",
                        style: pRegular14.copyWith(color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.globalBorder, width: 3),
                  ),
                  child: Transform.rotate(
                    angle: rotationAngle,
                    child: Image.asset('assets/images/png/kompas.png', width: 280),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Posisi Qiblat ${qiblaAngle.toStringAsFixed(0)}° dari utara",
                  style: pMedium14.copyWith(color: AppColor.secondaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: Get.width - 40,
                  child: Text(
                    "Putar ponsel perlahan hingga Ka'bah tegak lurus dengan layar",
                    style: pRegular14,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}


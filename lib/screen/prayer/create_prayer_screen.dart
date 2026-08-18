import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/screen/prayer/create_prayer_controller.dart';
import 'package:quran_app/theme/font.dart';

class CreatePrayerScreen extends StatelessWidget {
  const CreatePrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePrayerController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Buat Doa', style: pSemiBold16),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Tulis Doa atau Harapan Anda',
              style: pBold16.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Biarkan saudara muslim lainnya ikut mengaminkan doa baik Anda.',
              style: pRegular12.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Input Field
            Container(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: controller.contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Tulis doa Anda di sini...',
                  hintStyle: pRegular14.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant
                        .withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
                style: pRegular14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Anonymous Toggle
            Obx(
              () => GestureDetector(
                onTap: () => controller.isAnonymous.value =
                    !controller.isAnonymous.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: controller.isAnonymous.value
                          ? context.theme.colorScheme.primary.withOpacity(0.3)
                          : context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: controller.isAnonymous.value
                              ? context.theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: controller.isAnonymous.value
                                ? context.theme.colorScheme.primary
                                : context.isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: controller.isAnonymous.value
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kirim sebagai Hamba Allah (Anonim)',
                          style: pMedium12.copyWith(
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Submit Button
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.submitPrayer(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.primary,
                  disabledBackgroundColor: context.theme.colorScheme.primary
                      .withOpacity(0.5),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
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
                        'Kirim Doa',
                        style: pSemiBold14.copyWith(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

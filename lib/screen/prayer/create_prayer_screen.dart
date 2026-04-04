import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/prayer/create_prayer_controller.dart';
import 'package:quran_app/theme/font.dart';

class CreatePrayerScreen extends StatelessWidget {
  const CreatePrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePrayerController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          'Buat Doa',
          style: pSemiBold16.copyWith(color: Theme.of(context).primaryColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tulis Doa atau Harapan Anda',
                style: pBold16.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Biarkan saudara muslim lainnya ikut mengaminkan doa baik Anda.',
                style: pRegular12.copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 24),

              // Input Field
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: controller.contentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Tulis doa Anda di sini...',
                    hintStyle: pRegular14.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    border: InputBorder.none,
                  ),
                  style: pRegular14.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Anonymous Toggle
              Obx(
                () => InkWell(
                  onTap: () => controller.isAnonymous.value =
                      !controller.isAnonymous.value,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: controller.isAnonymous.value
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: controller.isAnonymous.value
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerColor,
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
                        Text(
                          'Kirim sebagai Hamba Allah (Anonim)',
                          style: pMedium12.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
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
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Kirim Doa',
                          style: pBold16.copyWith(color: Colors.white),
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

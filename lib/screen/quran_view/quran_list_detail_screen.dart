import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/quran/quran_list_detail_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:quran_app/theme/font.dart';

class QuranListDetailScreen extends StatelessWidget {
  const QuranListDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranListDetailScreenController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(controller.data.value?.namaLatin ?? '', style: pMedium16),
        ),
        backgroundColor: AppColor.backgroundColor,
        elevation: 1,
        surfaceTintColor: AppColor.backgroundColor,
        shadowColor: AppColor.primaryColor,
        iconTheme: const IconThemeData(color: AppColor.primaryColor),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColor.primaryColor),
              )
            : Stack(
                children: [
                  ScrollablePositionedList.separated(
                    itemScrollController: controller.itemScrollController,
                    itemPositionsListener: controller.itemPositionsListener,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final ayat = controller.data.value?.ayat[index];
                      return Obx(() {
                        final isCurrent =
                            controller.currentAyahIndex.value == index &&
                            controller.isPlaying.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          color: isCurrent
                              ? AppColor.primaryColor.withOpacity(0.05)
                              : Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? AppColor.primaryColor
                                          : AppColor.primaryColor.withOpacity(
                                              0.8,
                                            ),
                                      shape: BoxShape.circle,
                                      boxShadow: isCurrent
                                          ? [
                                              BoxShadow(
                                                color: AppColor.primaryColor
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      ayat?.nomorAyat.toString() ?? '',
                                      style: pMedium14.copyWith(
                                        color: AppColor.backgroundColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ayat?.teksArab ?? '',
                                      style: pMedium18.copyWith(
                                        color: isCurrent
                                            ? AppColor.primaryColor
                                            : null,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(ayat?.teksLatin ?? '', style: pRegular14),
                              const SizedBox(height: 8),
                              Text(
                                ayat?.teksIndonesia ?? '',
                                style: pRegular14,
                              ),
                            ],
                          ),
                        );
                      });
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppColor.borderColor),
                    itemCount: controller.data.value?.ayat.length ?? 0,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.backgroundColor,
                        border: Border(
                          top: BorderSide(color: AppColor.primaryColor),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Obx(
                            () => ElevatedButton(
                              onPressed: () => controller.playPauseAudio(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryColor,
                                padding: EdgeInsets.all(0),
                                minimumSize: const Size(48, 48),
                                maximumSize: const Size(48, 48),
                                shape: const CircleBorder(),
                              ),
                              child: Icon(
                                controller.isPlaying.value
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColor.backgroundColor,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 28,
                            color: AppColor.primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(
                              () => DropdownButtonFormField<String>(
                                dropdownColor: AppColor.backgroundColor,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  fillColor: AppColor.backgroundColor,
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                                value: controller.selectedReciter.value,
                                items: controller.reciters.map((reciter) {
                                  return DropdownMenuItem(
                                    value: reciter['code'],
                                    child: Text(
                                      reciter['name']!,
                                      style: pMedium14,
                                    ),
                                  );
                                }).toList(),
                                onChanged: controller.onReciterChanged,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/asmaul-husna/asmaulhusna_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class AsmaulhusnaScreen extends StatelessWidget {
  const AsmaulhusnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AsmaulhusnaController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Asmaul Husna", style: pSemiBold16),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(LucideIcons.arrowLeft),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.resetToStart(),
            icon: Icon(LucideIcons.refreshCcw),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.asmaulHusnaList.isEmpty) {
            return const Center(child: Text("Data tidak tersedia"));
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.asmaulHusnaList.length,
                  itemBuilder: (context, index) {
                    final itemData = controller.asmaulHusnaList[index];
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(14),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColor.globalBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              itemData['arab'] ?? "",
                              style: pSemiBold16.copyWith(
                                fontFamily: "quran",
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            itemData['latin'] ?? "",
                            style: pMedium14.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            itemData['arti'] ?? "",
                            style: pMedium14.copyWith(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => controller.previous(),
                    icon: Icon(LucideIcons.chevronLeft, size: 28),
                  ),
                  Text(
                    "${controller.currentIndex.value + 1}/${controller.asmaulHusnaList.length}",
                    style: pSemiBold18.copyWith(fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: () => controller.next(),
                    icon: Icon(LucideIcons.chevronRight, size: 28),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

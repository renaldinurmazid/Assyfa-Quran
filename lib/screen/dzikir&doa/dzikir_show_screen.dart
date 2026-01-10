import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/dzikir_show_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class DzikirShowScreen extends StatelessWidget {
  const DzikirShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DzikirShowScreenController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(controller.title.value, style: pMedium16)),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
        elevation: 1,
        surfaceTintColor: AppColor.backgroundColor,
        shadowColor: AppColor.primaryColor,
        iconTheme: const IconThemeData(color: AppColor.primaryColor),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }

        if (controller.data.isEmpty) {
          return Center(
            child: Text('Tidak ada data dzikir', style: pRegular14),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final dzikir = controller.data[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.backgroundColor,
                border: Border.all(color: AppColor.borderColor),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dzikir.title,
                          style: pSemiBold16.copyWith(
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${dzikir.read}x',
                          style: pSemiBold12.copyWith(
                            color: AppColor.backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dzikir.arab,
                    style: pSemiBold18.copyWith(height: 2),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dzikir.latin,
                    style: pRegular14.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dzikir.arti,
                    style: pRegular14.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },
          itemCount: controller.data.length,
        );
      }),
    );
  }
}

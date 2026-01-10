import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/quran/quran_list_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranListScreenController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text('Quran Per-Ayat', style: pMedium16),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
        elevation: 1,
        surfaceTintColor: AppColor.backgroundColor,
        shadowColor: AppColor.primaryColor,
        iconTheme: const IconThemeData(color: AppColor.primaryColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: TextInput(
              onChanged: controller.onSearch,
              controller: controller.searchController,
              hintText: 'Cari nama surah',
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                );
              }
              return ListView.separated(
                itemBuilder: (context, index) {
                  final quran = controller.quranList[index];
                  return GestureDetector(
                    onTap: () async {
                      await Get.toNamed(
                        Routes.quranListDetail,
                        arguments: quran.nomor,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              quran.nomor.toString(),
                              style: pMedium14.copyWith(
                                color: AppColor.backgroundColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(quran.namaLatin, style: pMedium16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      quran.tempatTurun,
                                      style: pMedium14.copyWith(
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 4,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      quran.jumlahAyat.toString(),
                                      style: pMedium14.copyWith(
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            quran.nama,
                            style: pMedium18.copyWith(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: controller.quranList.length,
              );
            }),
          ),
        ],
      ),
    );
  }
}

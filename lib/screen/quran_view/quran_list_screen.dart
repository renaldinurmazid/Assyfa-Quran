import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/quran_view/quran_list_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranListScreenController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Quran Per-Ayat', style: pSemiBold16),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Container(
              height: 160,
              width: Get.width - 24,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('assets/images/png/banner-quran.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 48,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.globalBorder, width: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.search,
                    color: AppColor.globalTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: controller.onSearch,
                      controller: controller.searchController,
                      style: pMedium14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari nama surah...',
                        hintStyle: pRegular14.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  itemCount: controller.quranList.length,
                  itemBuilder: (context, index) {
                    final quran = controller.quranList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () async {
                          await Get.toNamed(
                            Routes.quranListDetail,
                            arguments: quran.nomor,
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColor.globalBorder),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/png/frame.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    quran.nomor.toString(),
                                    style: pBold14.copyWith(
                                      color: AppColor.globalTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quran.namaLatin,
                                      style: pSemiBold14.copyWith(
                                        color: AppColor.globalTextSecondary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          quran.tempatTurun.toUpperCase(),
                                          style: pMedium10.copyWith(
                                            color: Theme.of(context).hintColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          height: 3,
                                          width: 3,
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).dividerColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Text(
                                          '${quran.jumlahAyat} Ayat',
                                          style: pMedium10.copyWith(
                                            color: Theme.of(context).hintColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                quran.nama,
                                style: pBold20.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

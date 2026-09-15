import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/screen/quran_view/quran_list_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranListScreenController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Quran Per-Ayat', style: pSemiBold16),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
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
            TextInput(
              onChanged: controller.onSearch,
              controller: controller.searchController,
              hintText: 'Cari nama surah...',
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: context.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                            ),
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
                                      color: Theme.of(context).primaryColor,
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
                                      style: pSemiBold16.copyWith(
                                        color: Theme.of(context).primaryColor,
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
                                          '${quran.jumlahAyat} AYAT',
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

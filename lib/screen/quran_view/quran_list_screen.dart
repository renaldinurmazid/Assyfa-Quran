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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColor.primaryColor,
            surfaceTintColor: AppColor.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Quran Per-Ayat',
                style: pSemiBold16.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.primaryColor,
                      AppColor.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.menu_book,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamu\'alaikum',
                    style: pMedium14.copyWith(
                      color: AppColor.primaryColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mari beribadah hari ini',
                    style: pSemiBold20.copyWith(color: AppColor.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  TextInput(
                    onChanged: controller.onSearch,
                    controller: controller.searchController,
                    hintText: 'Cari nama surah...',
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  quran.nomor.toString(),
                                  style: pBold14.copyWith(
                                    color: AppColor.primaryColor,
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
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        quran.tempatTurun.toUpperCase(),
                                        style: pMedium10.copyWith(
                                          color: AppColor.primaryColor
                                              .withOpacity(0.5),
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
                                          color: AppColor.primaryColor
                                              .withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        '${quran.jumlahAyat} AYAT',
                                        style: pMedium10.copyWith(
                                          color: AppColor.primaryColor
                                              .withOpacity(0.5),
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
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: controller.quranList.length),
              ),
            );
          }),
        ],
      ),
    );
  }
}

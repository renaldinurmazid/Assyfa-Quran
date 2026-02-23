import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/prayer/show_prayer_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/screen/home_screen.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class ShowPrayerScreen extends StatelessWidget {
  const ShowPrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowPrayerController());
    final homeController = Get.isRegistered<HomeScreenController>()
        ? Get.find<HomeScreenController>()
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
        ),
        title: Text(
          'Doa Saudaramu',
          style: pSemiBold16.copyWith(color: AppColor.primaryColor),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoading();
        }

        final prayer = controller.prayer.value;
        if (prayer == null) {
          return const Center(child: Text('Gagal memuat data doa.'));
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColor.primaryColor.withOpacity(
                              0.1,
                            ),
                            backgroundImage:
                                (prayer.isAnonymous == false &&
                                    prayer.userProfile != null)
                                ? NetworkImage(prayer.userProfile!)
                                : null,
                            child:
                                (prayer.isAnonymous == true ||
                                    prayer.userProfile == null)
                                ? Text(
                                    (prayer.isAnonymous == true)
                                        ? 'H'
                                        : (prayer.userName?[0].toUpperCase() ??
                                              'U'),
                                    style: pBold18.copyWith(
                                      color: AppColor.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prayer.isAnonymous == true
                                      ? 'Hamba Allah'
                                      : (prayer.userName ?? 'User'),
                                  style: pSemiBold14.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prayer.publishedAt ?? '-',
                                  style: pRegular12.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          prayer.content ?? '-',
                          style: pRegular16.copyWith(
                            color: Colors.black87,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Diaminkan oleh ${prayer.amensCount ?? 0} orang',
                        style: pSemiBold14.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      if (prayer.amens != null && prayer.amens!.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: prayer.amens!.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final amenUser = prayer.amens![index];
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColor.primaryColor
                                      .withOpacity(0.1),
                                  backgroundImage: amenUser.userProfile != null
                                      ? NetworkImage(amenUser.userProfile!)
                                      : null,
                                  child: amenUser.userProfile == null
                                      ? Text(
                                          amenUser.userName?[0].toUpperCase() ??
                                              'A',
                                          style: pBold10.copyWith(
                                            color: AppColor.primaryColor,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  amenUser.userName ?? 'User',
                                  style: pRegular12.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      else
                        Text(
                          'Belum ada yang mengaminkan doa ini.',
                          style: pRegular12.copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
              if (prayer.isMyPrayer != true)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (AuthController.to.isLogin.value) {
                        if (homeController != null) {
                          await homeController.toggleAmen(prayer.id!);
                          // Refresh data after amen
                          controller.fetchPrayerDetail(prayer.id!);
                        }
                      } else {
                        if (homeController != null) {
                          Get.dialog(
                            const HomeScreen().buildLoginDialog(homeController),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: prayer.isAmened == true
                          ? Colors.grey.shade200
                          : AppColor.primaryColor,
                      foregroundColor: prayer.isAmened == true
                          ? Colors.grey
                          : Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      prayer.isAmened == true ? 'Sudah Diaminkan' : 'Aamiin',
                      style: pSemiBold16,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 24),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 40),
            Container(width: 150, height: 16, color: Colors.white),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 14),
                    const SizedBox(width: 12),
                    Container(width: 100, height: 12, color: Colors.white),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/prayer/show_prayer_controller.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/screen/home/home_screen.dart';

import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';
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
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Detail Doa', style: pSemiBold16),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(LucideIcons.arrowLeft, size: 20),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoading(context);
          }

          final prayer = controller.prayer.value;
          if (prayer == null) {
            return Center(
              child: Text(
                'Gagal memuat data doa.',
                style: pMedium14.copyWith(color: AppColor.globalTextSecondary),
              ),
            );
          }

          bool isAnon = prayer.isAnonymous == true;
          bool isAmened = prayer.isAmened == true;
          String name = isAnon
              ? "Hamba Allah"
              : (prayer.isMyPrayer == true
                    ? "Kamu"
                    : (prayer.userName ?? "Hamba Allah"));
          String time = prayer.publishedAt ?? "-";

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.globalBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                              image:
                                  (!isAnon &&
                                      prayer.userProfile != null &&
                                      prayer.userProfile!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(prayer.userProfile!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                (isAnon ||
                                    prayer.userProfile == null ||
                                    prayer.userProfile!.isEmpty)
                                ? Icon(
                                    LucideIcons.circleUserRound,
                                    size: 20,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: pMedium14.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(time, style: pRegular12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        prayer.content ?? "-",
                        style: pRegular12.copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 18),
                      if (prayer.isMyPrayer != true)
                        GestureDetector(
                          onTap: () async {
                            if (isAmened) return;

                            if (AuthController.to.isLogin.value) {
                              if (homeController != null) {
                                await homeController.toggleAmen(prayer.id!);
                                controller.fetchPrayerDetail(prayer.id!);
                              }
                            } else {
                              if (homeController != null) {
                                Get.dialog(
                                  const HomeScreen().buildLoginDialog(
                                    homeController,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: Get.width,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isAmened
                                  ? context.theme.colorScheme.primary
                                        .withValues(alpha: 0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isAmened
                                    ? context.theme.colorScheme.primary
                                    : AppColor.globalBorder,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isAmened
                                      ? LucideIcons.heartHandshake
                                      : LucideIcons.handshake,
                                  size: 14,
                                  color: isAmened
                                      ? context.theme.colorScheme.primary
                                      : context.theme.iconTheme.color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isAmened ? "Diaminkan" : "Aamiin",
                                  style: pMedium12.copyWith(
                                    color: isAmened
                                        ? context.theme.colorScheme.primary
                                        : context
                                              .theme
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Comment Section (Amens)
                Container(
                  width: Get.width,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.globalBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Diaminkan oleh",
                            style: pSemiBold14.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            "${prayer.amensCount ?? 0} orang",
                            style: pSemiBold12.copyWith(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (prayer.amens != null && prayer.amens!.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: prayer.amens!.length,
                          separatorBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              color: AppColor.globalBorder,
                              height: 1,
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final amenUser = prayer.amens![index];
                            return Row(
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade100,
                                    image:
                                        (amenUser.userProfile != null &&
                                            amenUser.userProfile!.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              amenUser.userProfile!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      (amenUser.userProfile == null ||
                                          amenUser.userProfile!.isEmpty)
                                      ? Icon(
                                          LucideIcons.user,
                                          size: 18,
                                          color: Colors.grey.shade400,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        amenUser.userName ?? 'User',
                                        style: pSemiBold12.copyWith(
                                          color: AppColor.globalTextSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // Backend only gives us userName and userProfile, not time. So let's omit the time or put a dash.
                                      // If publishedAt is available we could use it, but usually it's not.
                                      // I will just remove the time for now or just put empty.
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Belum ada yang mengaminkan doa ini.',
                              style: pMedium12.copyWith(
                                color: AppColor.globalTextSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade200,
      highlightColor: context.isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/prayer/show_prayer_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/screen/home_screen.dart';


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
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          'Detail Doa',
          style: pSemiBold16.copyWith(color: context.theme.colorScheme.primary),
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
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header Section with Profile and Background
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: context.theme.colorScheme
                                    .primary
                                    .withOpacity(0.1),
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
                                            : (prayer.userName?[0]
                                                      .toUpperCase() ??
                                                  'U'),
                                        style: pBold24.copyWith(
                                          color: context
                                              .theme.colorScheme.primary,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              prayer.isAnonymous == true
                                  ? 'Hamba Allah'
                                  : (prayer.isMyPrayer == true
                                        ? 'Kamu'
                                        : prayer.userName ?? 'User'),
                              style: pBold18.copyWith(
                                color: context.theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prayer.publishedAt ?? '-',
                              style: pRegular12.copyWith(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Prayer Content Section
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 40,
                              ),
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.theme.colorScheme.primary
                                        .withOpacity(
                                      0.06,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Text(
                                prayer.content ?? '-',
                                style: pMedium18.copyWith(
                                  color: context.theme.colorScheme.primary,
                                  height: 1.8,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Decorative Quote Icon
                            Positioned(
                              top: -15,
                              left: 30,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: context.theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.theme.colorScheme.primary
                                          .withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.format_quote_rounded,
                                  color: Get.context!.theme.colorScheme.surface,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Amens List Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Diaminkan Oleh',
                                  style: pBold16.copyWith(
                                    color: context.theme.colorScheme.onSurface,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '${prayer.amensCount ?? 0} Orang',
                                    style: pSemiBold12.copyWith(
                                      color: context.theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (prayer.amens != null &&
                                prayer.amens!.isNotEmpty)
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: prayer.amens!.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final amenUser = prayer.amens![index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: context.theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: context.theme.colorScheme.outline
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: context
                                              .theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          backgroundImage:
                                              amenUser.userProfile != null
                                              ? NetworkImage(
                                                  amenUser.userProfile!,
                                                )
                                              : null,
                                          child: amenUser.userProfile == null
                                              ? Text(
                                                  amenUser.userName?[0]
                                                          .toUpperCase() ??
                                                      'A',
                                                  style: pBold12.copyWith(
                                                    color: context.theme
                                                        .colorScheme.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          amenUser.userName ?? 'User',
                                          style: pSemiBold14.copyWith(
                                            color: context
                                                .theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.check_circle,
                                          color: context
                                              .theme.colorScheme.secondary,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: context.theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: context.theme.colorScheme.outline
                                        .withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.favorite_border_rounded,
                                      color: context
                                          .theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.3),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Belum ada yang mengaminkan doa ini.',
                                      style: pRegular12.copyWith(
                                        color: context.theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 100), // Bottom padding
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      // Move Button to BottomNavigationBar or Float on top
      bottomNavigationBar: Obx(() {
        final prayer = controller.prayer.value;
        if (prayer == null || prayer.isMyPrayer == true) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              if (AuthController.to.isLogin.value) {
                if (homeController != null) {
                  await homeController.toggleAmen(prayer.id!);
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
                  ? context.theme.colorScheme.surfaceVariant
                  : context.theme.colorScheme.primary,
              foregroundColor: prayer.isAmened == true
                  ? context.theme.colorScheme.onSurfaceVariant
                  : context.theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: prayer.isAmened == true ? 0 : 8,
              shadowColor: context.theme.colorScheme.primary.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  prayer.isAmened == true ? Icons.check_circle : Icons.favorite,
                  size: 20,
                  color: prayer.isAmened == true
                      ? context.theme.colorScheme.onSurfaceVariant
                      : context.theme.colorScheme.onPrimary,
                ),
                const SizedBox(width: 12),
                Text(
                  prayer.isAmened == true ? 'Sudah Diaminkan' : 'Aamiin',
                  style: pBold16.copyWith(
                    color: prayer.isAmened == true
                        ? context.theme.colorScheme.onSurfaceVariant
                        : context.theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Get.context!.theme.colorScheme.surfaceVariant,
      highlightColor: Get.context!.theme.colorScheme.surface,
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
                    Container(width: 120, height: 16, color: Get.context!.theme.colorScheme.surface),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: Get.context!.theme.colorScheme.surface),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Get.context!.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 40),
            Container(width: 150, height: 16, color: Get.context!.theme.colorScheme.surface),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 14),
                    const SizedBox(width: 12),
                    Container(width: 100, height: 12, color: Get.context!.theme.colorScheme.surface),
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

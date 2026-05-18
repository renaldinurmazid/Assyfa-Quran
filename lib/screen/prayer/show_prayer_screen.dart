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
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Detail Doa', style: pSemiBold16),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoading(context);
        }

        final prayer = controller.prayer.value;
        if (prayer == null) {
          return Center(
            child: Text(
              'Gagal memuat data doa.',
              style: pMedium14.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Profile Card
                _buildProfileCard(context, prayer),
                const SizedBox(height: 20),

                // 2. Prayer Content
                _buildPrayerContent(context, prayer),
                const SizedBox(height: 24),

                // 3. Amen List
                _buildAmenSection(context, prayer),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final prayer = controller.prayer.value;
        if (prayer == null || prayer.isMyPrayer == true) {
          return const SizedBox.shrink();
        }
        return _buildBottomAction(
          context,
          prayer,
          controller,
          homeController,
        );
      }),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic prayer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor:
                context.theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage:
                (prayer.isAnonymous == false && prayer.userProfile != null)
                    ? NetworkImage(prayer.userProfile!)
                    : null,
            child: (prayer.isAnonymous == true || prayer.userProfile == null)
                ? Text(
                    (prayer.isAnonymous == true)
                        ? 'H'
                        : (prayer.userName?[0].toUpperCase() ?? 'U'),
                    style: pBold24.copyWith(
                      color: context.theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            prayer.isAnonymous == true
                ? 'Hamba Allah'
                : (prayer.isMyPrayer == true
                    ? 'Kamu'
                    : prayer.userName ?? 'User'),
            style: pBold16.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prayer.publishedAt ?? '-',
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerContent(BuildContext context, dynamic prayer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          // Quote Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: context.theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            prayer.content ?? '-',
            style: pMedium14.copyWith(
              color: context.theme.colorScheme.onSurface,
              height: 1.7,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAmenSection(BuildContext context, dynamic prayer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Diaminkan Oleh', style: pSemiBold14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${prayer.amensCount ?? 0} Orang',
                style: pSemiBold10.copyWith(
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (prayer.amens != null && prayer.amens!.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prayer.amens!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final amenUser = prayer.amens![index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: context.theme.colorScheme.primary
                          .withOpacity(0.1),
                      backgroundImage: amenUser.userProfile != null
                          ? NetworkImage(amenUser.userProfile!)
                          : null,
                      child: amenUser.userProfile == null
                          ? Text(
                              amenUser.userName?[0].toUpperCase() ?? 'A',
                              style: pBold10.copyWith(
                                color: context.theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        amenUser.userName ?? 'User',
                        style: pSemiBold12.copyWith(
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      color: context.theme.colorScheme.primary,
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  color: context.theme.colorScheme.onSurfaceVariant
                      .withOpacity(0.3),
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada yang mengaminkan doa ini.',
                  style: pRegular12.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    dynamic prayer,
    ShowPrayerController controller,
    HomeScreenController? homeController,
  ) {
    final isAmened = prayer.isAmened == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.isDarkMode
                ? Colors.grey.shade900
                : Colors.grey.shade100,
          ),
        ),
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
          backgroundColor: isAmened
              ? context.theme.colorScheme.surfaceContainerHighest
              : context.theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAmened ? Icons.check_circle_rounded : Icons.favorite,
              size: 18,
              color: isAmened
                  ? context.theme.colorScheme.onSurfaceVariant
                  : Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              isAmened ? 'Sudah Diaminkan' : 'Aamiin',
              style: pSemiBold14.copyWith(
                color: isAmened
                    ? context.theme.colorScheme.onSurfaceVariant
                    : Colors.white,
              ),
            ),
          ],
        ),
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
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

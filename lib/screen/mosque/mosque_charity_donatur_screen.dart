import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/screen/mosque/mosque_charity_donatur_controller.dart';
import 'package:quran_app/models/campaign_donatur_model.dart';

import 'package:quran_app/theme/font.dart';

class MosqueCharityDonaturScreen extends StatelessWidget {
  const MosqueCharityDonaturScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MosqueCharityDonaturController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: context.theme.colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: context.theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Daftar Donatur',
          style: pSemiBold16.copyWith(color: context.theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.donaturList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildDonaturHeader(controller),
            Expanded(
              child: RefreshIndicator(
                color: context.theme.colorScheme.primary,
                onRefresh: () => controller.refreshData(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200 &&
                        !controller.isLoadingMore.value &&
                        controller.hasMore.value) {
                      controller.fetchDonaturList(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount:
                        controller.donaturList.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.donaturList.length) {
                        return _buildLoadMoreIndicator();
                      }
                      final donatur = controller.donaturList[index];
                      final isLast =
                          index == controller.donaturList.length - 1 &&
                          !controller.isLoadingMore.value;
                      return _buildDonaturCard(donatur, index, isLast);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDonaturHeader(MosqueCharityDonaturController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.context!.theme.colorScheme.primary.withOpacity(0.08),
            Get.context!.theme.colorScheme.primary.withOpacity(0.03),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Get.context!.theme.colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Get.context!.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconlyBold.heart,
              color: Get.context!.theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Donatur',
                style: pMedium12.copyWith(
                  color: Get.context!.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  '${controller.total.value} Orang',
                  style: pBold16.copyWith(
                    color: Get.context!.theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            IconlyLight.user_1,
            color: Get.context!.theme.colorScheme.primary.withOpacity(0.3),
            size: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildDonaturCard(DonaturItem donatur, int index, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(donatur),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donatur.name,
                      style: pSemiBold14.copyWith(
                        color: Get.context!.theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          IconlyLight.time_circle,
                          size: 13,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          donatur.time,
                          style: pRegular10.copyWith(
                            color:
                                Get.context!.theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      Get.context!.theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  donatur.amount,
                  style: pSemiBold12.copyWith(
                    color: Get.context!.theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildAvatar(DonaturItem donatur) {
    if (donatur.isAnonymous) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Get.context!.theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          IconlyBold.user_3,
          color: Get.context!.theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          size: 22,
        ),
      );
    }
    return _buildInitialsAvatar(donatur.name);
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
              .join()
        : '?';

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.context!.theme.colorScheme.primary.withOpacity(0.7),
            Get.context!.theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(initials, style: pBold14.copyWith(color: Colors.white)),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
                Get.context!.theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Get.context!.theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyLight.user_1,
                size: 56,
                color: Get.context!.theme.colorScheme.onSurfaceVariant
                    .withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Donatur',
              style: pBold18.copyWith(
                color: Get.context!.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadilah yang pertama berdonasi\nuntuk masjid ini',
              textAlign: TextAlign.center,
              style: pRegular14.copyWith(
                color: Get.context!.theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Get.context!.theme.colorScheme.surfaceContainerHighest,
      highlightColor: Get.context!.theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: Get.context!.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              8,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Get.context!.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Get.context!.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 10,
                            width: 90,
                            decoration: BoxDecoration(
                              color: Get.context!.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 28,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Get.context!.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
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

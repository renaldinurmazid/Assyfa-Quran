import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/screen/mosque/mosque_charity_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class MosqueCharityScreen extends StatelessWidget {
  const MosqueCharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MosqueCharityController());
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Infaq Masjid', style: pSemiBold16),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LucideIcons.arrowLeft,
            color: AppColor.globalTextSecondary,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.map,
              color: AppColor.globalTextSecondary,
              size: 20,
            ),
            onPressed: () => Get.toNamed(Routes.mosqueMap),
            tooltip: 'Peta Masjid',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            searchController.clear();
            controller.searchQuery.value = '';
            await controller.fetchMosqueCharityList();
          },
          color: AppColor.primaryColor,
          backgroundColor: context.theme.colorScheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 42,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.globalBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.search,
                        size: 18,
                        color: AppColor.globalTextSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: controller.searchMosque,
                          style: pRegular14.copyWith(
                            color: AppColor.globalTextSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Cari nama masjid..',
                            isDense: true,
                            hintStyle: pRegular14.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => controller.searchQuery.value.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchController.clear();
                                  controller.searchMosque('');
                                },
                                child: Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: AppColor.globalTextSecondary,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildListMosque(context, controller),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListMosque(
    BuildContext context,
    MosqueCharityController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildGridShimmer(context);
      }

      if (controller.filteredMosqueList.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "Masjid Rekomendasi",
              style: pSemiBold14.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68, // Adjust based on user's 168/252 ratio
            ),
            itemCount: controller.filteredMosqueList.length,
            itemBuilder: (context, index) {
              final mosque = controller.filteredMosqueList[index];
              return GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.mosqueCharityShow,
                  arguments: {'id': mosque.id},
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.globalBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: mosque.coverImage,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            color: context.isDarkMode
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            color: context
                                .theme
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Icon(
                              LucideIcons.image,
                              size: 24,
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mosque.name,
                                style: pSemiBold12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      LucideIcons.mapPin,
                                      size: 10,
                                      color: AppColor.globalTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      mosque.address,
                                      style: pRegular10.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.globalTextSecondary
                                            .withOpacity(0.8),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                "Terkumpul",
                                style: pRegular10.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                mosque.collectedAmount,
                                style: pSemiBold12.copyWith(
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildGridShimmer(BuildContext context) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            highlightColor: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            child: Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            highlightColor: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.globalBorder.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.home,
                size: 36,
                color: AppColor.globalTextSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Masjid tidak ditemukan',
              style: pSemiBold14.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba gunakan kata kunci pencarian lain',
              style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
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
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Infaq Masjid',
          style: pBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              IconlyBroken.location,
              color: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
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
          color: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
          backgroundColor: context.theme.colorScheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeaderSection(context),

                // Search bar
                _buildSearchBar(context, controller, searchController),

                const SizedBox(height: 20),

                // Section label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 3.5,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColor.primaryColorDark
                              : AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Masjid Pilihan',
                        style: pBold14.copyWith(
                          color: context.theme.colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // List
                _buildMosqueList(context, controller),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kemakmuran & Infaq Masjid',
            style: pBold20.copyWith(
              color: context.theme.colorScheme.onSurface,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Salurkan kepedulian Anda untuk pembangunan dan kemakmuran masjid.',
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant.withOpacity(
                0.85,
              ),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    MosqueCharityController controller,
    TextEditingController searchController,
  ) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              IconlyLight.search,
              size: 18,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: controller.searchMosque,
                cursorColor: isDark
                    ? AppColor.primaryColorDark
                    : AppColor.primaryColor,
                style: pRegular12.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama masjid atau lokasi...',
                  hintStyle: pRegular12.copyWith(
                    color: isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
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
                        Icons.cancel_rounded,
                        size: 18,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueList(
    BuildContext context,
    MosqueCharityController controller,
  ) {
    final isDark = context.isDarkMode;

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildVerticalListShimmer(context);
      }

      if (controller.filteredMosqueList.isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.filteredMosqueList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final mosque = controller.filteredMosqueList[index];
          final double progressValue =
              (mosque.percentage / 100).clamp(0.0, 1.0);

          return GestureDetector(
            onTap: () => Get.toNamed(
              Routes.mosqueCharityShow,
              arguments: {'id': mosque.id},
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: mosque.coverImage,
                      width: 110,
                      height: 96,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 110,
                        height: 96,
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade100,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppColor.primaryColorDark
                                    : AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 110,
                        height: 96,
                        color: context.theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(IconlyLight.home, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque.name,
                          style: pSemiBold12.copyWith(
                            color: context.theme.colorScheme.onSurface,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              IconlyLight.location,
                              size: 10,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                mosque.address,
                                style: pRegular10.copyWith(
                                  color: isDark
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 4.5,
                            backgroundColor: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark
                                  ? AppColor.primaryColorDark
                                  : AppColor.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Metrics
                        Row(
                          children: [
                            Text(
                              'Terkumpul',
                              style: pRegular10.copyWith(
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mosque.collectedAmount,
                              style: pBold12.copyWith(
                                color: context.theme.colorScheme.onSurface,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildVerticalListShimmer(BuildContext context) {
    final isDark = context.isDarkMode;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColor.primaryColorDark : AppColor.primaryColor)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.home,
              size: 36,
              color: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Masjid tidak ditemukan',
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba gunakan kata kunci pencarian lain',
            style: pRegular12.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/charity/charity_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityScreenController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Infaq", style: pSemiBold16),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () => Get.toNamed(Routes.charitySearch),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColor.globalBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: AppColor.globalTextSecondary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Cari program infaq",
                        style: pRegular12.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4),
              _buildInfaqCategories(controller),
              const SizedBox(height: 24),
              _buildInfaqPilihan(controller),
              const SizedBox(height: 24),
              _buildInfaqLainnya(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfaqLainnya(CharityScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "Ayo berinfaq sekarang",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoading.value) {
            return _buildVerticalListShimmer(Get.context!);
          }

          if (controller.charityList.isEmpty) {
            return _buildEmptyState(Get.context!, controller);
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount:
                controller.charityList.length +
                (controller.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.charityList.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final charity = controller.charityList[index];
                  final progressValue = (charity.percentage / 100).clamp(
                    0.0,
                    1.0,
                  );

                  return GestureDetector(
                    onTap: () => Get.toNamed(
                      Routes.charityShow,
                      arguments: {'id': charity.id},
                    ),
                    child: Container(
                      height: 108,
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColor.globalBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: charity.coverImage,
                              width: 156,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 156,
                                color: context.isDarkMode
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100,
                                child: const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColor.primaryColorDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 156,
                                color: context
                                    .theme
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(IconlyLight.image, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 4,
                                left: 4,
                                right: 4,
                                bottom: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    charity.title,
                                    style: pSemiBold12.copyWith(
                                      color: AppColor.globalTextSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: double.infinity,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColor.globalBorder,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: LinearProgressIndicator(
                                      value: progressValue,
                                      color: AppColor.primaryColor,
                                      backgroundColor: AppColor.globalBorder,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Terkumpul",
                                            style: pRegular10.copyWith(
                                              color:
                                                  AppColor.globalTextSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            charity.collectedAmount,
                                            style: pSemiBold10.copyWith(
                                              color:
                                                  AppColor.globalTextSecondary,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Sisa hari",
                                            style: pRegular10.copyWith(
                                              color:
                                                  AppColor.globalTextSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          charity.endDate.toString() ==
                                                  'Infinity'
                                              ? const Icon(
                                                  Icons.all_inclusive,
                                                  size: 14,
                                                  color: Colors.grey,
                                                )
                                              : Text(
                                                  charity.endDate.toString(),
                                                  style: pSemiBold10.copyWith(
                                                    color: AppColor
                                                        .globalTextSecondary,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
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
              );
            }),
      ],
    );
  }

  Widget _buildInfaqPilihan(CharityScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "Infaq Pilihan",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildFeaturedShimmer(Get.context!);
            }

            if (controller.latestCharityList.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: controller.latestCharityList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final charity = controller.latestCharityList[index];
                final progressValue = (charity.percentage / 100).clamp(
                  0.0,
                  1.0,
                );

                return GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.charityShow,
                    arguments: {'id': charity.id},
                  ),
                  child: Container(
                    width: 220,
                    padding: EdgeInsets.only(
                      top: 2,
                      bottom: 16,
                      left: 2,
                      right: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColor.globalBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: charity.coverImage,
                            height: 125,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 125,
                              color: context.isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColor.primaryColorDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 125,
                              color: context
                                  .theme
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Icon(
                                IconlyLight.image,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  charity.title,
                                  style: pMedium12.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.globalTextSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Terkumpul",
                                      style: pRegular10.copyWith(
                                        color: AppColor.globalTextSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      charity.collectedAmount,
                                      style: pRegular10.copyWith(
                                        color: AppColor.globalTextSecondary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progressValue,
                                  borderRadius: BorderRadius.circular(100),
                                  color: AppColor.primaryColor,
                                  backgroundColor: AppColor.globalBorder,
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
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInfaqCategories(CharityScreenController controller) {
    return Obx(() {
      if (controller.isLoadingCategory.value) {
        return _buildCategoryShimmer(Get.context!);
      }

      final categories = controller.campaignCategories;
      final selectedId = controller.selectedCategoryId.value;

      return SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: categories.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = selectedId == null;
              return _buildCategoryPill(
                context: context,
                label: 'Semua',
                isSelected: isSelected,
                onTap: () => controller.filterByCategory(null),
              );
            }

            final category = categories[index - 1];
            final isSelected = selectedId == category.id;

            return _buildCategoryPill(
              context: context,
              label: category.name,
              isSelected: isSelected,
              onTap: () => controller.filterByCategory(category.id),
            );
          },
        ),
      );
    });
  }

  Widget _buildCategoryPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.globalBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? pSemiBold12.copyWith(color: Colors.white)
              : pMedium12.copyWith(color: AppColor.globalTextSecondary),
        ),
      ),
    );
  }

  Widget _buildCategoryShimmer(BuildContext context) {
    final isDark = context.isDarkMode;
    return SizedBox(
      height: 38,
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) => Container(
            width: 80 + (index * 15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedShimmer(BuildContext context) {
    final isDark = context.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: ListView.separated(
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalListShimmer(BuildContext context) {
    final isDark = context.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemBuilder: (context, index) => Container(
          height: 108,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    CharityScreenController controller,
  ) {
    final isDark = context.isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primaryColorDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyLight.document,
                size: 36,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Tidak ada program ditemukan',
              style: pBold14.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Belum ada program untuk kategori ini. Silakan coba kategori lainnya.',
              style: pRegular12.copyWith(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.filterByCategory(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(100)),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('Tampilkan Semua', style: pSemiBold12),
            ),
          ],
        ),
      ),
    );
  }
}

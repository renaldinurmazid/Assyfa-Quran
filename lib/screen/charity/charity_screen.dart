import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/models/campaign_category_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/controller/charity/charity_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityScreenController());
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Infaq & Sedekah', style: pBold16),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Hero Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColorDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppColor.primaryColorDark.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                size: 12,
                                color: AppColor.primaryColorDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Assyfa Peduli Sesama',
                                style: pSemiBold10.copyWith(
                                  color: AppColor.primaryColorDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tebar Kebaikan & Infaq',
                      style: pBold20.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Salurkan infaq dan sedekah Anda dengan mudah, aman, dan transparan.',
                      style: pRegular12.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar & Filter Button Inline
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.toNamed(Routes.charitySearch),
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: context.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                IconlyLight.search,
                                size: 20,
                                color: context.isDarkMode
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Cari program kebaikan...',
                                style: pRegular14.copyWith(
                                  color: context.isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: context.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => _showFilterBottomSheet(context, controller),
                        icon: Icon(
                          IconlyLight.filter,
                          color: AppColor.primaryColorDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter Status (Quick Reset Chip if category selected)
              Obx(() {
                final categoryId = controller.selectedCategoryId.value;
                if (categoryId == null) return const SizedBox.shrink();
                
                final matchedCat = controller.campaignCategories.firstWhereOrNull(
                  (c) => c.id == categoryId,
                );
                final catName = matchedCat?.name ?? 'Kategori';
                
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Wrap(
                    children: [
                      InputChip(
                        label: Text('Kategori: $catName', style: pSemiBold12.copyWith(color: Colors.white)),
                        backgroundColor: AppColor.primaryColorDark,
                        deleteIconColor: Colors.white,
                        onDeleted: () {
                          controller.filterByCategory(null);
                        },
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Program Terbaru", style: pBold14),
              ),

              // list program terbaru
              const SizedBox(height: 12),
              _buildLatestProgramList(controller),
              const SizedBox(height: 24),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Program Lainnya", style: pBold14),
              ),

              // list program lainnya
              const SizedBox(height: 12),
              _buildOtherProgramList(controller),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedShimmer(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        highlightColor: context.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestProgramList(CharityScreenController controller) {
    return SizedBox(
      height: 275,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildFeaturedShimmer(Get.context!);
        }
        return ListView.separated(
          itemCount: controller.latestCharityList.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final charity = controller.latestCharityList[index];
            final double progressValue = (charity.percentage / 100).clamp(0.0, 1.0);
            return GestureDetector(
              onTap: () => Get.toNamed(
                Routes.charityShow,
                arguments: {'id': charity.id},
              ),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with top rounded corners
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        charity.coverImage,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: context
                                .theme
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Icon(
                              IconlyLight.image,
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    charity.category?.name ?? "Program Kebaikan",
                                    style: pBold10.copyWith(
                                      color: AppColor.primaryColorDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.blue,
                                  size: 12,
                                ),
                              ],
                            ),
                            Text(
                              charity.title,
                              style: pSemiBold12.copyWith(
                                color: context.theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 6,
                                    backgroundColor: context.isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColor.primaryColorDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Terkumpul',
                                            style: pRegular10.copyWith(color: Colors.grey.shade500),
                                          ),
                                          Text(
                                            charity.collectedAmount,
                                            style: pBold10.copyWith(color: context.theme.colorScheme.onSurface),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Sisa Hari',
                                          style: pRegular10.copyWith(color: Colors.grey.shade500),
                                        ),
                                        charity.endDate.toString() == 'Infinity'
                                            ? const Icon(
                                                Icons.all_inclusive,
                                                size: 14,
                                                color: Colors.grey,
                                              )
                                            : Text(
                                                charity.endDate.toString(),
                                                style: pBold10.copyWith(color: context.theme.colorScheme.onSurface),
                                              ),
                                      ],
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
    );
  }

  Widget _buildOtherProgramList(CharityScreenController controller) {
    return Column(
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return _buildVerticalListShimmer(Get.context!);
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.charityList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final charity = controller.charityList[index];
              final double progressValue = (charity.percentage / 100).clamp(0.0, 1.0);
              return GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.charityShow,
                  arguments: {'id': charity.id},
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          charity.coverImage,
                          width: 110,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 110,
                            height: 90,
                            color: context.theme.colorScheme.surfaceVariant,
                            child: const Icon(IconlyLight.image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    charity.category?.name ?? "Program Kebaikan",
                                    style: pBold10.copyWith(
                                      color: AppColor.primaryColorDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.blue,
                                  size: 12,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              charity.title,
                              style: pSemiBold12.copyWith(
                                color: context.theme.colorScheme.onSurface,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 5,
                                backgroundColor: context.isDarkMode
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColor.primaryColorDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Bottom Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Terkumpul",
                                      style: pRegular10.copyWith(
                                        color: context.theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      charity.collectedAmount,
                                      style: pBold10.copyWith(color: context.theme.colorScheme.onSurface),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Sisa Hari",
                                      style: pRegular10.copyWith(
                                        color: context.theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    charity.endDate.toString() == 'Infinity'
                                        ? const Icon(Icons.all_inclusive,
                                            size: 14, color: Colors.grey)
                                        : Text(
                                            charity.endDate.toString(),
                                            style: pBold10.copyWith(color: context.theme.colorScheme.onSurface),
                                          ),
                                  ],
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
        }),
        Obx(() {
          if (controller.isLoadingMore.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.primaryColorDark,
                    ),
                  ),
                ),
              ),
            );
          }
          if (!controller.hasMoreData.value && controller.charityList.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Sudah menampilkan semua program',
                style: pRegular12.copyWith(color: Colors.grey.shade500),
              ),
            );
          }
          return const SizedBox(height: 20);
        }),
      ],
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    CharityScreenController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Kategori',
                  style: pBold16.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.filterByCategory(null);
                    Get.back();
                  },
                  child: Text(
                    'Reset Semua',
                    style: pBold14.copyWith(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.isLoadingCategory.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.campaignCategories.isEmpty) {
                return const Center(child: Text("Tidak ada kategori"));
              }

              return Wrap(
                spacing: 10,
                runSpacing: 12,
                children: controller.campaignCategories.map((category) {
                  return _buildCategoryChip(context, controller, category);
                }).toList(),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    CharityScreenController controller,
    CategoryDatum category,
  ) {
    return Obx(() {
      final isSelected = controller.selectedCategoryId.value == category.id;
      return InkWell(
        onTap: () {
          controller.filterByCategory(category.id);
          Get.back();
        },
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primaryColorDark
                : context.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected
                  ? AppColor.primaryColorDark
                  : context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColor.primaryColorDark.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            category.name,
            style: pMedium14.copyWith(
              color: isSelected
                  ? Colors.white
                  : context.theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVerticalListShimmer(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        highlightColor: context.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 100, color: Colors.white),
                    const SizedBox(height: 16),
                    Container(height: 6, color: Colors.white),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 12, width: 60, color: Colors.white),
                        Container(height: 12, width: 40, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

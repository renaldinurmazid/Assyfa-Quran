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
        title: Text('Infaq', style: pSemiBold16),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: controller.scrollController,
          child: Column(
            children: [
              InkWell(
                onTap: () => Get.toNamed(Routes.charitySearch),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.isDarkMode
                            ? Colors.grey.shade600
                            : Colors.grey.shade500,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          IconlyLight.search,
                          color: context.isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                        ),
                        SizedBox(width: 8),
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Program Terbaru", style: pSemiBold14),
                    InkWell(
                      onTap: () {
                        _showFilterBottomSheet(context, controller);
                      },
                      child: Icon(
                        Icons.filter_alt,
                        color: context.isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              // list program terbaru
              const SizedBox(height: 12),
              _buildLatestProgramList(controller),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Program Lainnya", style: pSemiBold14),
                ),
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
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        highlightColor: context.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: Container(
          width: 260,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestProgramList(CharityScreenController controller) {
    return SizedBox(
      height: 260,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildFeaturedShimmer(Get.context!);
        }
        return ListView.separated(
          itemCount: controller.latestCharityList.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final charity = controller.latestCharityList[index];
            return GestureDetector(
              onTap: () => Get.toNamed(
                Routes.charityShow,
                arguments: {'id': charity.id},
              ),
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                charity.category?.name ?? "Program Kebaikan",
                                style: pRegular10.copyWith(
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                color: Colors.blue.shade500,
                                size: 12,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 30,
                            child: Text(
                              charity.title,
                              style: pSemiBold12.copyWith(
                                color: context.theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: charity.percentage / 100,
                              minHeight: 6,
                              backgroundColor: context.isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColor.primaryColorDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Terkumpul', style: pRegular10),
                                  Text(
                                    charity.collectedAmount,
                                    style: pSemiBold12,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Sisa hari', style: pRegular10),
                                  charity.endDate.toString() == 'Infinity'
                                      ? const Icon(
                                          Icons.all_inclusive,
                                          size: 16,
                                        )
                                      : Text(
                                          charity.endDate.toString(),
                                          style: pSemiBold12,
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.charityList.length,
            separatorBuilder: (context, index) => Divider(
              height: 32,
              color: context.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final charity = controller.charityList[index];
              return GestureDetector(
                onTap: () => Get.toNamed(Routes.charityShow,
                    arguments: {'id': charity.id}),
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          charity.coverImage,
                          width: 130,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 130,
                            height: 100,
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
                            // Title
                            Text(
                              charity.title,
                              style: pSemiBold12.copyWith(
                                color: context.theme.colorScheme.onSurface,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Organizer + Verified + ORG
                            Row(
                              children: [
                                Text(
                                  charity.category?.name ?? "Program Kebaikan",
                                  style: pRegular10.copyWith(
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  color: Colors.blue.shade500,
                                  size: 14,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: charity.percentage / 100,
                                minHeight: 4,
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
                                      style: pSemiBold12,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Sisa hari",
                                      style: pRegular10.copyWith(
                                        color: context.theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    charity.endDate.toString() == 'Infinity'
                                        ? const Icon(Icons.all_inclusive,
                                            size: 16)
                                        : Text(
                                            charity.endDate.toString(),
                                            style: pSemiBold12,
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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Kategori',
                  style: pSemiBold18.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.filterByCategory(null);
                    Get.back();
                  },
                  child: Text(
                    'Reset',
                    style: pRegular14.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoadingCategory.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.campaignCategories.isEmpty) {
                return const Center(child: Text("Tidak ada kategori"));
              }

              return Wrap(
                spacing: 8,
                runSpacing: 10,
                children: controller.campaignCategories.map((category) {
                  return _buildCategoryChip(context, controller, category);
                }).toList(),
              );
            }),
            const SizedBox(height: 32),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      color: AppColor.primaryColorDark.withOpacity(0.3),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        highlightColor: context.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 130,
                height: 100,
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

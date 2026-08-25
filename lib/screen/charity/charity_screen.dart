import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
// import 'package:quran_app/models/campaign_category_model.dart';
import 'package:quran_app/models/charity_model.dart';
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
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.primaryColorDark,
          backgroundColor: context.theme.colorScheme.surface,
          onRefresh: () async {
            await Future.wait([
              controller.fetchCharityList(),
              controller.fetchLatestCharityList(),
              controller.fetchCampaignCategories(),
            ]);
          },
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero / Header Section
                _buildHeaderSection(context),

                // Search & Filter Row
                _buildSearchAndFilter(context, controller),

                // Horizontal Category Chips
                _buildHorizontalCategoryList(context, controller),

                const SizedBox(height: 16),

                // Featured / Latest Programs Carousel
                _buildFeaturedSection(context, controller),

                const SizedBox(height: 24),

                // All Programs Section
                _buildAllProgramsSection(context, controller),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Infaq & Sedekah',
        style: pBold16.copyWith(
          color: context.theme.colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      centerTitle: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(Routes.charitySearch),
          icon: Icon(
            IconlyLight.search,
            color: context.theme.colorScheme.onSurface,
            size: 22,
          ),
          tooltip: 'Cari Program',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trust Badge Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColor.primaryColorDark.withOpacity(0.15)
                  : AppColor.primaryColorDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColor.primaryColorDark.withOpacity(0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 13,
                  color: AppColor.primaryColorDark,
                ),
                const SizedBox(width: 5),
                Text(
                  '100% Amanah & Transparan',
                  style: pSemiBold10.copyWith(
                    color: AppColor.primaryColorDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tebar Kebaikan & Infaq',
            style: pBold20.copyWith(
              color: context.theme.colorScheme.onSurface,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Salurkan kepedulian Anda untuk mereka yang membutuhkan dengan cepat dan tepat sasaran.',
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

  Widget _buildSearchAndFilter(
    BuildContext context,
    CharityScreenController controller,
  ) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Get.toNamed(Routes.charitySearch),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
                  children: [
                    Icon(
                      IconlyLight.search,
                      size: 18,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cari program kebaikan...',
                        style: pRegular12.copyWith(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // const SizedBox(width: 10),
          // // Obx(() {
          //   final hasActiveFilter = controller.selectedCategoryId.value != null;
          //   return Stack(
          //     clipBehavior: Clip.none,
          //     children: [
          //       Container(
          //         decoration: BoxDecoration(
          //           color: hasActiveFilter
          //               ? AppColor.primaryColorDark
          //               : context.theme.colorScheme.surface,
          //           borderRadius: BorderRadius.circular(14),
          //           border: Border.all(
          //             color: hasActiveFilter
          //                 ? AppColor.primaryColorDark
          //                 : isDark
          //                 ? Colors.grey.shade800
          //                 : Colors.grey.shade200,
          //           ),
          //           boxShadow: [
          //             BoxShadow(
          //               color: hasActiveFilter
          //                   ? AppColor.primaryColorDark.withOpacity(0.25)
          //                   : Colors.black.withOpacity(isDark ? 0.2 : 0.02),
          //               blurRadius: 8,
          //               offset: const Offset(0, 2),
          //             ),
          //           ],
          //         ),
          //         child: Material(
          //           color: Colors.transparent,
          //           child: InkWell(
          //             onTap: () => _showFilterBottomSheet(context, controller),
          //             borderRadius: BorderRadius.circular(14),
          //             child: Padding(
          //               padding: const EdgeInsets.all(12),
          //               child: Icon(
          //                 IconlyLight.filter,
          //                 color: hasActiveFilter
          //                     ? Colors.white
          //                     : isDark
          //                     ? Colors.grey.shade300
          //                     : AppColor.primaryColorDark,
          //                 size: 20,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       if (hasActiveFilter)
          //         Positioned(
          //           top: -2,
          //           right: -2,
          //           child: Container(
          //             width: 9,
          //             height: 9,
          //             decoration: BoxDecoration(
          //               color: Colors.amber.shade600,
          //               shape: BoxShape.circle,
          //               border: Border.all(
          //                 color: context.theme.scaffoldBackgroundColor,
          //                 width: 1.5,
          //               ),
          //             ),
          //           ),
          //         ),
          //     ],
          //   );
          // }),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategoryList(
    BuildContext context,
    CharityScreenController controller,
  ) {
    return Obx(() {
      if (controller.isLoadingCategory.value) {
        return _buildCategoryShimmer(context);
      }

      final categories = controller.campaignCategories;
      final selectedId = controller.selectedCategoryId.value;

      return SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColorDark
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColorDark
                : isDark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.primaryColorDark.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: isSelected
              ? pSemiBold12.copyWith(color: Colors.white)
              : pMedium12.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    CharityScreenController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColorDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Program Pilihan',
                    style: pBold14.copyWith(
                      color: context.theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (controller.latestCharityList.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColorDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Terbaru',
                    style: pSemiBold10.copyWith(
                      color: AppColor.primaryColorDark,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildLatestProgramList(controller),
      ],
    );
  }

  Widget _buildLatestProgramList(CharityScreenController controller) {
    return SizedBox(
      height: 262,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildFeaturedShimmer(Get.context!);
        }

        if (controller.latestCharityList.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          itemCount: controller.latestCharityList.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final charity = controller.latestCharityList[index];
            return _buildFeaturedCard(Get.context!, charity);
          },
        );
      }),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Datum charity) {
    final isDark = context.isDarkMode;
    final double progressValue = (charity.percentage / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () =>
          Get.toNamed(Routes.charityShow, arguments: {'id': charity.id}),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Top Rounded Corners & Floating Category Tag
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: charity.coverImage,
                    height: 125,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 125,
                      color: isDark
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
                      color: context.theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        IconlyLight.image,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // Gradient Vignette on bottom of image for contrast
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category Pill on top-left of image
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        charity.category?.name ?? "Kebaikan",
                        style: pSemiBold10.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Verified Icon on top-right
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(
                      Icons.verified_rounded,
                      color: Colors.blueAccent,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      charity.title,
                      style: pSemiBold12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Progress Section & Metrics
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Bar & Percentage
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: pRegular10.copyWith(
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              '${charity.percentage}%',
                              style: pBold10.copyWith(
                                color: AppColor.primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 5,
                            backgroundColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColorDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Stats: Terkumpul & Sisa Hari
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Terkumpul',
                                    style: pRegular10.copyWith(
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    charity.collectedAmount,
                                    style: pBold12.copyWith(
                                      color:
                                          context.theme.colorScheme.onSurface,
                                      letterSpacing: -0.2,
                                    ),
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
                                  style: pRegular10.copyWith(
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                charity.endDate.toString() == 'Infinity'
                                    ? const Icon(
                                        Icons.all_inclusive,
                                        size: 14,
                                        color: Colors.grey,
                                      )
                                    : Text(
                                        '${charity.endDate} hari',
                                        style: pSemiBold10.copyWith(
                                          color: context
                                              .theme
                                              .colorScheme
                                              .onSurface,
                                        ),
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
  }

  Widget _buildAllProgramsSection(
    BuildContext context,
    CharityScreenController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColorDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Semua Program',
                    style: pBold14.copyWith(
                      color: context.theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Obx(() {
                final categoryId = controller.selectedCategoryId.value;
                if (categoryId == null) return const SizedBox.shrink();

                final matchedCat = controller.campaignCategories
                    .firstWhereOrNull((c) => c.id == categoryId);
                final catName = matchedCat?.name ?? 'Kategori';

                return InkWell(
                  onTap: () => controller.filterByCategory(null),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        Text(
                          catName,
                          style: pMedium10.copyWith(
                            color: AppColor.primaryColorDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: AppColor.primaryColorDark,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildOtherProgramList(controller),
      ],
    );
  }

  Widget _buildOtherProgramList(CharityScreenController controller) {
    return Column(
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return _buildVerticalListShimmer(Get.context!);
          }

          if (controller.charityList.isEmpty) {
            return _buildEmptyState(Get.context!, controller);
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.charityList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final charity = controller.charityList[index];
              return _buildVerticalCharityCard(Get.context!, charity);
            },
          );
        }),

        // Pagination Loader / End of list message
        Obx(() {
          if (controller.isLoadingMore.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
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

          if (!controller.hasMoreData.value &&
              controller.charityList.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Semua program kebaikan telah ditampilkan',
                  style: pRegular12.copyWith(color: Colors.grey.shade500),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildVerticalCharityCard(BuildContext context, Datum charity) {
    final isDark = context.isDarkMode;
    final double progressValue = (charity.percentage / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () =>
          Get.toNamed(Routes.charityShow, arguments: {'id': charity.id}),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: charity.coverImage,
                width: 110,
                height: 96,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 110,
                  height: 96,
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
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
                  width: 110,
                  height: 96,
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(IconlyLight.image, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Right Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Verified Badge
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
                        color: Colors.blueAccent,
                        size: 13,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    charity.title,
                    style: pSemiBold12.copyWith(
                      color: context.theme.colorScheme.onSurface,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 4.5,
                      backgroundColor: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColor.primaryColorDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bottom Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Terkumpul",
                            style: pRegular10.copyWith(
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            charity.collectedAmount,
                            style: pBold12.copyWith(
                              color: context.theme.colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Sisa Hari",
                            style: pRegular10.copyWith(
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade800,
                            ),
                          ),
                          charity.endDate.toString() == 'Infinity'
                              ? const Icon(
                                  Icons.all_inclusive,
                                  size: 14,
                                  color: Colors.grey,
                                )
                              : Text(
                                  '${charity.endDate} hari',
                                  style: pSemiBold10.copyWith(
                                    color: context.theme.colorScheme.onSurface,
                                  ),
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
  }

  Widget _buildEmptyState(
    BuildContext context,
    CharityScreenController controller,
  ) {
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
              color: AppColor.primaryColorDark.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconlyLight.document,
              size: 36,
              color: AppColor.primaryColorDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak ada program ditemukan',
            style: pBold14.copyWith(color: context.theme.colorScheme.onSurface),
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
              backgroundColor: AppColor.primaryColorDark,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(100)),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('Tampilkan Semua', style: pSemiBold12),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    CharityScreenController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Kategori',
                      style: pBold16.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih program kebaikan sesuai minat Anda',
                      style: pRegular12.copyWith(
                        color: context.isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    controller.filterByCategory(null);
                    Get.back();
                  },
                  child: Text(
                    'Reset',
                    style: pBold14.copyWith(color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Obx(() {
              if (controller.isLoadingCategory.value) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.primaryColorDark,
                      ),
                    ),
                  ),
                );
              }

              if (controller.campaignCategories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text("Tidak ada kategori")),
                );
              }

              return Wrap(
                spacing: 10,
                runSpacing: 12,
                children: [
                  // 'Semua' option
                  _buildBottomSheetCategoryChip(
                    context: context,
                    label: 'Semua Kategori',
                    isSelected: controller.selectedCategoryId.value == null,
                    onTap: () {
                      controller.filterByCategory(null);
                      Get.back();
                    },
                  ),
                  ...controller.campaignCategories.map((category) {
                    final isSelected =
                        controller.selectedCategoryId.value == category.id;
                    return _buildBottomSheetCategoryChip(
                      context: context,
                      label: category.name,
                      isSelected: isSelected,
                      onTap: () {
                        controller.filterByCategory(category.id);
                        Get.back();
                      },
                    );
                  }),
                ],
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomSheetCategoryChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColorDark
              : isDark
              ? Colors.grey.shade900
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColorDark
                : isDark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.primaryColorDark.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: pMedium12.copyWith(
            color: isSelected
                ? Colors.white
                : context.theme.colorScheme.onSurface,
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: ListView.builder(
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => Container(
          width: 235,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 110,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 12,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 12,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

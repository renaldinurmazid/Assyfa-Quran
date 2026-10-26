import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/screen/charity/charity_search_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class CharitySearchScreen extends StatelessWidget {
  const CharitySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharitySearchController());
    final searchController = TextEditingController();

    // Auto focus and search if arguments passed
    if (Get.arguments != null) {
      searchController.text = Get.arguments;
      controller.searchCharity(Get.arguments);
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Cari program infaq", style: pSemiBold16),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (value) => controller.searchCharity(value),
                textAlignVertical: TextAlignVertical.center,
                style: pRegular14,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  constraints: BoxConstraints(maxHeight: 40),
                  hint: Text("Cari program infaq", style: pRegular12),
                  prefixIcon: Icon(LucideIcons.search, size: 20),
                  prefixIconColor: AppColor.globalTextSecondary,
                  prefixIconConstraints: BoxConstraints(
                    minHeight: 40,
                    minWidth: 40,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColor.globalBorder,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColor.globalBorder,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColor.globalBorder,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  if (controller.query.value.isEmpty) {
                    return _buildProgramPopuler(controller);
                  }
                  return _buildSearchResults(controller);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramPopuler(CharitySearchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Program Populer",
            style: pSemiBold14,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isPopularLoading.value) {
                return _buildListShimmer(Get.context!);
              }

              if (controller.popularCharities.isEmpty) {
                return const SizedBox.shrink();
              }

              return ListView.separated(
                itemCount: controller.popularCharities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final charity = controller.popularCharities[index];
                  return _buildProgramItem(
                    title: charity.title,
                    image: charity.coverImage,
                    id: charity.id,
                  );
                },
              );
            }),
          ),
        ],
      );
  }

  Widget _buildSearchResults(CharitySearchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hasil Pencarian",
          style: pSemiBold14,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildListShimmer(Get.context!);
            }

            if (controller.searchResults.isEmpty) {
              return _buildEmptyState(Get.context!);
            }

            return ListView.separated(
              controller: controller.scrollController,
              itemCount: controller.searchResults.length +
                  (controller.hasMoreData.value ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == controller.searchResults.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                        ),
                      ),
                    ),
                  );
                }
                final charity = controller.searchResults[index];
                return _buildProgramItem(
                  title: charity.title,
                  image: charity.coverImage,
                  id: charity.id,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDarkMode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.search,
            size: 48,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "Program tidak ditemukan",
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba cari dengan kata kunci lain",
            style: pRegular12.copyWith(
              color: AppColor.globalTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramItem({
    required String title,
    required String image,
    required int id,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.charityShow,
        arguments: {'id': id},
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: image,
              width: 120,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 120,
                height: 80,
                color: context.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade100,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 120,
                height: 80,
                color: context.theme.colorScheme.surfaceContainerHighest,
                child: const Icon(IconlyLight.image),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: pSemiBold12.copyWith(
                color: AppColor.globalTextSecondary,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListShimmer(BuildContext context) {
    final isDark = context.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 100,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

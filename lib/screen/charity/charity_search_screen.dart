import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/controller/charity/charity_search_controller.dart';
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
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: context.theme.colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(100),
          ),
          child: TextField(
            controller: searchController,
            autofocus: true,
            style: pRegular14,
            decoration: InputDecoration(
              hintText: 'Cari program...',
              hintStyle: pRegular14.copyWith(color: Colors.grey),
              prefixIcon: const Icon(
                IconlyLight.search,
                color: Colors.grey,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onSubmitted: (value) => controller.searchCharity(value),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        if (controller.searchResults.isEmpty) {
          return _buildEmptyState(context, controller.query.value);
        }

        return ListView.separated(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: controller.searchResults.length +
              (controller.isLoadingMore.value || !controller.hasMoreData.value
                  ? 1
                  : 0),
          separatorBuilder: (context, index) {
            if (index == controller.searchResults.length) {
              return const SizedBox();
            }
            return Divider(
              height: 32,
              color: context.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.grey.shade200,
            );
          },
          itemBuilder: (context, index) {
            if (index == controller.searchResults.length) {
              if (controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              if (!controller.hasMoreData.value &&
                  controller.searchResults.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Sudah menampilkan semua hasil',
                      style: pRegular12.copyWith(color: Colors.grey.shade500),
                    ),
                  ),
                );
              }
              return const SizedBox();
            }
            final item = controller.searchResults[index];
            return _buildSearchItem(context, item);
          },
        );
      }),
    );
  }

  Widget _buildSearchItem(BuildContext context, dynamic charity) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.charityShow, arguments: {'id': charity.id}),
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
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 130,
                  height: 100,
                  color: context.theme.colorScheme.surfaceContainerHighest,
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
                  // Organizer + Verified
                  Row(
                    children: [
                      Text(
                        charity.category?.name ?? "Program Kebaikan",
                        style: pRegular10.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
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
                              color: context.theme.colorScheme.onSurfaceVariant,
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
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          charity.endDate.toString() == 'Infinity'
                              ? const Icon(Icons.all_inclusive, size: 16)
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
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        highlightColor: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 130,
                height: 100,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
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

  Widget _buildEmptyState(BuildContext context, String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.search,
            size: 64,
            color: context.theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'Cari program kebaikan'
                : 'Tidak ditemukan hasil untuk "$query"',
            style: pMedium14.copyWith(color: context.theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

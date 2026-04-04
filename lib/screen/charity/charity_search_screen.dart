import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
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
        backgroundColor: context.theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left_2, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: searchController,
            autofocus: true,
            style: pRegular14.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari program...',
              hintStyle: pRegular14.copyWith(color: Colors.white70),
              prefixIcon: const Icon(
                IconlyLight.search,
                color: Colors.white70,
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final item = controller.searchResults[index];
            return _buildSearchItem(context, item);
          },
        );
      }),
    );
  }

  Widget _buildSearchItem(BuildContext context, dynamic item) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.charityShow, arguments: {'id': item.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                item.coverImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    IconlyLight.image,
                    color: context.theme.colorScheme.onSurfaceVariant
                        .withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: pBold14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: item.percentage / 100,
                      backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.theme.colorScheme.primary,
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.collectedAmount,
                          style: pBold12.copyWith(color: context.theme.colorScheme.primary),
                        ),
                        Text(
                          '${item.percentage}%',
                          style: pMedium10.copyWith(color: context.theme.colorScheme.onSurfaceVariant),
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

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        highlightColor: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
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

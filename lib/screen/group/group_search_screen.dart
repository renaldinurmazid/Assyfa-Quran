import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/group/group_search_controller.dart';
import 'package:quran_app/routes/app_routes.dart';

import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class GroupSearchScreen extends StatelessWidget {
  const GroupSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupSearchController());
    final searchController = TextEditingController();

    if (Get.arguments != null) {
      searchController.text = Get.arguments;
      controller.searchGroups(Get.arguments);
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.isDarkMode
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(100),
              color: context.isDarkMode
                  ? context.theme.colorScheme.surface
                  : Colors.white,
            ),
            child: TextField(
              controller: searchController,
              autofocus: true,
              style: pRegular14.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Cari grup ngaji...',
                hintStyle: pRegular14.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  IconlyLight.search,
                  color: context.theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (value) => controller.searchGroups(value),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.publicGroups.isEmpty) {
          return _buildEmptyState(controller.query.value);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.publicGroups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = controller.publicGroups[index];
            return _buildGroupItem(context, group);
          },
        );
      }),
    );
  }

  Widget _buildGroupItem(BuildContext context, dynamic group) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.showGroup, arguments: group.id),
      child: Container(
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
            // Cover Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surfaceContainerHighest,
                      image: DecorationImage(
                        image: group.coverImage != null
                            ? NetworkImage(group.coverImage)
                            : const AssetImage(
                                    'assets/images/jpg/bg-group.jpg',
                                  )
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount} Anggota',
                          style: pMedium10.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Group Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.theme.primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: group.createdBy.profilePicture != null &&
                              group.createdBy.profilePicture!.isNotEmpty
                          ? Image.network(
                              group.createdBy.profilePicture!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: context.theme.dividerColor,
                              child: Icon(
                                Icons.person,
                                color: context.theme.hintColor.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: pSemiBold14.copyWith(
                            color: context.theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Oleh ${group.createdBy.name}',
                          style: pRegular10.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: context.theme.colorScheme.onSurfaceVariant,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Get.context!.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        highlightColor: Get.context!.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: Get.context!.theme.colorScheme.onSurfaceVariant
                .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'Cari Grup Ngaji'
                : 'Tidak ditemukan grup untuk "$query"',
            style: pMedium14.copyWith(
              color: Get.context!.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

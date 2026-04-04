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
              hintText: 'Cari grup...',
              hintStyle: pRegular14.copyWith(color: Colors.white70),
              prefixIcon: const Icon(
                IconlyLight.search,
                color: Colors.white70,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onSubmitted: (value) => controller.searchGroups(value),
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
          padding: const EdgeInsets.all(16),
          itemCount: controller.publicGroups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final group = controller.publicGroups[index];
            return _buildGroupItem(group);
          },
        );
      }),
    );
  }

  Widget _buildGroupItem(dynamic group) {
    return Container(
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Get.context!.theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(Routes.showGroup, arguments: group.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
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
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.5),
                            ],
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
                            const Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 14,
                            ),
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
                            color: Get.context!.theme.colorScheme.primary
                                .withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              group.createdBy.profilePicture != null &&
                                  group.createdBy.profilePicture!.isNotEmpty
                              ? Image.network(
                                  group.createdBy.profilePicture!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Get.context!.theme.colorScheme
                                      .surfaceVariant,
                                  child: Icon(
                                    Icons.person,
                                    color: Get.context!.theme.colorScheme
                                        .onSurfaceVariant,
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
                              style: pBold16.copyWith(
                                color: Get.context!.theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dibuat oleh ${group.createdBy.name}',
                              style: pRegular12.copyWith(
                                color: Get
                                    .context!.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        IconlyLight.arrow_right_2,
                        color: Get.context!.theme.colorScheme.onSurfaceVariant,
                        size: 18,
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

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Get.context!.theme.colorScheme.surfaceVariant,
        highlightColor: Get.context!.theme.colorScheme.surface,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 220,
          decoration: BoxDecoration(
            color: Get.context!.theme.colorScheme.surface,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/models/public_group_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/home/home_screen.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class GroupNgajiScreen extends StatelessWidget {
  const GroupNgajiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupNgajiScreenController());
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Grup Ngaji', style: pSemiBold16),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchGroup(context),
              const SizedBox(height: 12),
              _createGroupCard(context),
              const SizedBox(height: 24),
              _popularGroup(context, controller),
              const SizedBox(height: 24),
              _listGroup(context, controller),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popularGroup(
    BuildContext context,
    GroupNgajiScreenController controller,
  ) {
    return Obx(() {
      if (controller.isLoadingPublic.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grup Populer',
                style: pSemiBold14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 185,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: context.isDarkMode
                          ? Colors.grey.shade900
                          : Colors.grey.shade200,
                      highlightColor: context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      if (controller.publicGroups.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grup Populer',
              style: pSemiBold14.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 185,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.publicGroups.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final group = controller.publicGroups[index];
                  return _popularGroupCard(context, group);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _popularGroupCard(BuildContext context, PublicGroupItem group) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.showGroup, arguments: group.id),
      child: Container(
        width: 220,
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
            // Cover Image + Member count
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surfaceContainerHighest,
                      image: DecorationImage(
                        image: group.coverImage != null
                            ? NetworkImage(group.coverImage!)
                            : const AssetImage('assets/images/jpg/bg-group.jpg')
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
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group, color: Colors.white, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount}',
                          style: pMedium10.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: pSemiBold12.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1,
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
                                  color: Theme.of(context).dividerColor,
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context)
                                        .hintColor
                                        .withOpacity(0.5),
                                    size: 12,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          group.createdBy.name,
                          style: pRegular10.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _searchGroup(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.groupSearch),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.isDarkMode
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: context.isDarkMode
                    ? Colors.grey.shade600
                    : Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                'Cari Grup Ngaji...',
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
    );
  }

  Widget _createGroupCard(BuildContext context) {
    void showLoginDialog() {
      final homeController = Get.find<HomeScreenController>();
      Get.dialog(const HomeScreen().buildLoginDialog(homeController));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.primaryColorDark, AppColor.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soleh bareng-bareng yuk!',
                  style: pBold16.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Buat grup ngaji & undang temanmu sekarang',
                  style: pRegular12.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              if (AuthController.to.isLogin.value) {
                Get.toNamed(Routes.createGroupNgaji);
              } else {
                showLoginDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColor.primaryColorDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text('Buat Grup', style: pBold12),
          ),
        ],
      ),
    );
  }

  Widget _listGroup(
    BuildContext context,
    GroupNgajiScreenController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Grup Saya',
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _listViewMyGroup(context, controller),
      ],
    );
  }

  Widget _listViewMyGroup(
    BuildContext context,
    GroupNgajiScreenController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      }

      if (controller.myGroups.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  color: Theme.of(context).disabledColor.withOpacity(0.3),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada grup ngaji',
                  style: pMedium14.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: controller.myGroups.length,
        itemBuilder: (context, index) {
          final group = controller.myGroups[index];
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
                  // Image
                  Stack(
                    children: [
                      _buildGroupCover(context, group.coverImage),
                      _buildMemberCount(group.memberCount),
                    ],
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildCreatorAvatar(
                          context,
                          group.createdBy.profilePicture,
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
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: context.theme.colorScheme.onSurfaceVariant,
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

  Widget _buildGroupCover(BuildContext context, String? coverImage) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerHighest,
          image: DecorationImage(
            image: coverImage != null
                ? NetworkImage(coverImage)
                : const AssetImage('assets/images/jpg/bg-group.jpg')
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
    );
  }

  Widget _buildMemberCount(int count) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              '$count Anggota',
              style: pMedium10.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorAvatar(BuildContext context, String? profilePicture) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: profilePicture != null && profilePicture.isNotEmpty
            ? Image.network(profilePicture, fit: BoxFit.cover)
            : Container(
                color: Theme.of(context).dividerColor,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).hintColor.withOpacity(0.5),
                  size: 20,
                ),
              ),
      ),
    );
  }
}

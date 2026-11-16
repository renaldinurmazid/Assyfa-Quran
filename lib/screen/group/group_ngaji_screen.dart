import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(LucideIcons.arrowLeft, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(),
              const SizedBox(height: 18),
              _buildCreateGroupCard(context),
              const SizedBox(height: 14),
              _buildListGrupPopular(context, controller),
              const SizedBox(height: 14),
              _buildListMyGroup(context, controller),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateGroupCard(BuildContext context) {
    void showLoginDialog() {
      final homeController = Get.find<HomeScreenController>();
      Get.dialog(const HomeScreen().buildLoginDialog(homeController));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Soleh bareng-bareng yuk!",
                  style: pSemiBold16.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Buat grup ngaji & undang temanmu sekarang",
                  style: pRegular12.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (AuthController.to.isLogin.value) {
                Get.toNamed(Routes.createGroupNgaji);
              } else {
                showLoginDialog();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "Buat Grup",
                style: pSemiBold12.copyWith(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListGrupPopular(BuildContext context, GroupNgajiScreenController controller) {
    return Obx(() {
      if (controller.isLoadingPublic.value) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                "Grup Populer",
                style: pSemiBold14.copyWith(
                  color: AppColor.globalTextSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }

      if (controller.publicGroups.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "Grup Populer",
              style: pSemiBold14.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: controller.publicGroups.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final group = controller.publicGroups[index];
                return _popularGroupCard(context, group);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _popularGroupCard(BuildContext context, PublicGroupItem group) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.showGroup, arguments: group.id),
      child: Container(
        width: 220,
        height: 210,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.globalBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: group.coverImage != null
                  ? Image.network(
                      group.coverImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    )
                  : Image.asset(
                      'assets/images/jpg/bg-group.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: pSemiBold12.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${group.memberCount} Anggota",
                      style: pRegular10.copyWith(
                        color: AppColor.globalTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (group.createdBy.profilePicture != null && group.createdBy.profilePicture!.isNotEmpty)
                          CircleAvatar(
                            radius: 8,
                            backgroundImage: NetworkImage(group.createdBy.profilePicture!),
                          )
                        else
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Theme.of(context).dividerColor,
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                              size: 10,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "dibuat oleh ${group.createdBy.name}",
                            style: pRegular10.copyWith(
                              color: AppColor.globalTextSecondary,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListMyGroup(BuildContext context, GroupNgajiScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "Grup Saya",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
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
                      LucideIcons.users,
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
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
            padding: const EdgeInsets.symmetric(horizontal: 14),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: controller.myGroups.length,
            itemBuilder: (context, index) {
              final group = controller.myGroups[index];
              return GestureDetector(
                onTap: () => Get.toNamed(Routes.showGroup, arguments: group.id),
                child: Container(
                  height: 90,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColor.globalBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: group.coverImage != null
                            ? Image.network(
                                group.coverImage!,
                                fit: BoxFit.cover,
                                width: 90,
                                height: double.infinity,
                              )
                            : Image.asset(
                                'assets/images/jpg/bg-group.jpg',
                                fit: BoxFit.cover,
                                width: 90,
                                height: double.infinity,
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                group.name,
                                style: pSemiBold14.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${group.memberCount} Anggota',
                                style: pRegular12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: AppColor.globalTextSecondary,
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

  Widget _buildSearchField() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.groupSearch),
      child: Container(
        width: double.infinity,
        height: 42,
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColor.globalBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 20,
              color: AppColor.globalTextSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Cari Grup Ngaji..',
              style: pRegular14.copyWith(
                color: AppColor.globalTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

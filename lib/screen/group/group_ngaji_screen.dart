import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/home_screen.dart';
import 'package:quran_app/theme/font.dart';

class GroupNgajiScreen extends StatelessWidget {
  const GroupNgajiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupNgajiScreenController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Grup Ngaji',
          style: pSemiBold16.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _searchGroup(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _createGroupCard(context),
                  _listGroup(context, controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchGroup(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Get.toNamed(Routes.groupSearch, arguments: value);
            }
          },
          cursorColor: Theme.of(context).primaryColor,
          style: pRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).hintColor,
              size: 22,
            ),
            hintText: 'Cari Grup Ngaji...',
            hintStyle: pRegular14.copyWith(color: Theme.of(context).hintColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _createGroupCard(BuildContext context) {
    void _showLoginDialog() {
      final homeController = Get.find<HomeScreenController>();
      Get.dialog(const HomeScreen().buildLoginDialog(homeController));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.25),
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
          ElevatedButton(
            onPressed: () {
              if (AuthController.to.isLogin.value) {
                Get.toNamed(Routes.createGroupNgaji);
              } else {
                _showLoginDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Grup Saya',
            style: pSemiBold16.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: controller.myGroups.length,
        itemBuilder: (context, index) {
          final group = controller.myGroups[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.15
                        : 0.05,
                  ),
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
                  onTap: () =>
                      Get.toNamed(Routes.showGroup, arguments: group.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          _buildGroupCover(group.coverImage),
                          _buildMemberCount(group.memberCount),
                        ],
                      ),
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
                                    style: pBold16.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dibuat oleh ${group.createdBy.name}',
                                    style: pRegular12.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
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
        },
      );
    });
  }

  Widget _buildGroupCover(String? coverImage) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
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
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.5),
            ],
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/home_screen.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class GroupNgajiScreen extends StatelessWidget {
  const GroupNgajiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupNgajiScreenController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Grup Ngaji', style: pSemiBold16),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _searchGroup(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [_createGroupCard(), _listGroup(controller)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchGroup() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          cursorColor: AppColor.primaryColor,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade400,
              size: 22,
            ),
            hintText: 'Cari Grup Ngaji...',
            hintStyle: pRegular14.copyWith(color: Colors.grey.shade400),
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

  Widget _createGroupCard() {
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
            AppColor.primaryColor,
            AppColor.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.25),
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
              foregroundColor: AppColor.primaryColor,
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

  Widget _listGroup(GroupNgajiScreenController controller) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _tabItem('Grup Saya', controller.isGroupSaya.value, () {
                    controller.isGroupSaya.value = true;
                    controller.pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }),
                  _tabItem('Browse Grup', !controller.isGroupSaya.value, () {
                    controller.isGroupSaya.value = false;
                    controller.pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: Get.height * 0.6, // Adjusted height
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            onPageChanged: (index) {
              controller.isGroupSaya.value = index == 0;
            },
            children: [_listViewMyGroup(controller), _listViewBrowseGroup()],
          ),
        ),
      ],
    );
  }

  Widget _tabItem(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: isActive
                ? pSemiBold14.copyWith(color: AppColor.primaryColor)
                : pMedium14.copyWith(color: Colors.grey.shade500),
          ),
        ),
      ),
    );
  }

  Widget _listViewMyGroup(GroupNgajiScreenController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        );
      }

      if (controller.myGroups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 16),
              Text(
                'Belum ada grup ngaji',
                style: pMedium14.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: controller.myGroups.length,
        itemBuilder: (context, index) {
          final group = controller.myGroups[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                            _buildCreatorAvatar(group.createdBy.profilePicture),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    style: pBold16.copyWith(
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dibuat oleh ${group.createdBy.name}',
                                    style: pRegular12.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.share_outlined,
                                color: AppColor.primaryColor,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
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

  Widget _buildCreatorAvatar(String profilePicture) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: profilePicture.isNotEmpty
            ? Image.network(profilePicture, fit: BoxFit.cover)
            : Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
      ),
    );
  }

  Widget _listViewBrowseGroup() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/svg/maintenance.svg', width: 200),
            const SizedBox(height: 24),
            Text(
              'Fitur Segera Datang',
              style: pBold18.copyWith(color: AppColor.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami sedang menyiapkan daftar grup terbaik untukmu. Tunggu kejutannya ya!',
              style: pRegular14.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

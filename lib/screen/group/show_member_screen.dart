import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/group/show_member_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/models/group/member_group_tilawah.dart';

class ShowMemberScreen extends StatelessWidget {
  const ShowMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowMemberController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(controller),
          Obx(() {
            if (controller.isLoading.value && controller.group.value == null) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                ),
              );
            }

            if (controller.group.value == null ||
                controller.group.value!.groupUser.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconlyLight.user,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada anggota',
                        style: pMedium14.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final member = controller.group.value!.groupUser[index];
                  return _buildMemberTile(member, controller);
                }, childCount: controller.group.value!.groupUser.length),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppBar(ShowMemberController controller) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColor.backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anggota Grup', style: pBold18),
            Text(
              '${controller.group.value?.memberCount ?? 0} Anggota Terdaftar',
              style: pRegular12.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          IconlyLight.arrow_left_2,
          color: AppColor.primaryColor,
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildMemberTile(GroupUser member, ShowMemberController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: member.user.profilePicture.isNotEmpty
                      ? Image.network(
                          member.user.profilePicture,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/png/user.png'),
                        )
                      : Image.asset(
                          'assets/images/png/user.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${member.rank}',
                    style: pBold10.copyWith(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.user.name,
                  style: pBold14.copyWith(color: Colors.grey.shade800),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      IconlyLight.document,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${member.totalPages} Halaman',
                      style: pRegular12.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (controller.isOwner && member.userId != controller.creatorId)
            IconButton(
              onPressed: () =>
                  _confirmDropUser(controller, member.userId, member.user.name),
              icon: const Icon(
                Icons.person_remove_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDropUser(
    ShowMemberController controller,
    int userId,
    String name,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_remove_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Keluarkan Anggota',
                style: pBold18.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin mengeluarkan $name dari grup ini?',
                textAlign: TextAlign.center,
                style: pRegular14.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: pBold14.copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.dropUser(userId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Keluarkan',
                        style: pBold14.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

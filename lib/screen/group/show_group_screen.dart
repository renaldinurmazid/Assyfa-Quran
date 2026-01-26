import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/group/show_group_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class ShowGroupScreen extends StatelessWidget {
  const ShowGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowGroupController());
    return Obx(
      () => Scaffold(
        backgroundColor: AppColor.backgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(controller),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStatsCard(controller),
                    const SizedBox(height: 32),
                    _buildAnggotaSection(controller),
                    const SizedBox(height: 120), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: controller.group.value?.isMyGroup == true
            ? _buildFloatingButtons(controller)
            : (!controller.isMember ? _buildJoinButton(controller) : null),
      ),
    );
  }

  Widget _buildJoinButton(ShowGroupController controller) {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.dialog(_buildJoinConfirmDialog(controller));
      },
      backgroundColor: AppColor.primaryColor,
      elevation: 4,
      icon: const Icon(IconlyBold.user_3, color: Colors.white),
      label: Text('Gabung Grup', style: pBold14.copyWith(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildJoinConfirmDialog(ShowGroupController controller) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.user_3,
                color: AppColor.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text('Gabung Grup?', style: pBold18),
            const SizedBox(height: 12),
            Text(
              'Anda akan bergabung dalam grup "${controller.group.value?.name}" dan dapat melihat aktivitas tilawah anggota lainnya.',
              textAlign: TextAlign.center,
              style: pRegular14.copyWith(color: Colors.grey),
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
                      controller.joinGroup();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Gabung',
                      style: pBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ShowGroupController controller) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColor.primaryColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(IconlyLight.arrow_left_2, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (controller.group.value?.isMyGroup == true)
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                controller.nameController.text = controller.group.value!.name;
                Get.dialog(Dialog(child: _buildEditGroup(controller)));
              } else if (value == 'change_cover') {
                controller.pickAndUploadCoverImage();
              } else if (value == 'delete') {
                Get.dialog(_buildDeleteGroup(controller));
              }
            },
            icon: const Icon(IconlyLight.more_square, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(
                      IconlyLight.edit,
                      size: 20,
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text('Edit Grup', style: pMedium14),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_cover',
                child: Row(
                  children: [
                    const Icon(
                      IconlyLight.image,
                      size: 20,
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text('Ganti Cover', style: pMedium14),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(IconlyLight.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      'Hapus Grup',
                      style: pMedium14.copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () => controller.group.value?.coverImage != null
                  ? Image.network(
                      controller.group.value!.coverImage,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/jpg/bg-group.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.group.value?.name ?? '-',
                      style: pBold24.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          IconlyLight.profile,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => Text(
                          'Owner: ${controller.group.value?.createdBy.name ?? '-'}',
                          style: pMedium14.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ShowGroupController controller) {
    final history = controller.group.value?.weeklyHistory;
    final summary = history?.summary ?? [];
    final totalPages = history?.totalPages ?? 0;

    // Scaling logic
    int maxPages = 0;
    for (var s in summary) {
      if (s.totalPages > maxPages) maxPages = s.totalPages;
    }
    double maxVal = maxPages.toDouble();
    if (maxVal < 5) maxVal = 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statistik Tilawah', style: pBold18),
                  const SizedBox(height: 4),
                  Text(
                    'Aktivitas mingguan grup Anda',
                    style: pRegular12.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  IconlyLight.activity,
                  color: AppColor.primaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: summary.map((s) {
                      double heightFactor = s.totalPages / maxVal;
                      return _buildBar(s.day, heightFactor, s.totalPages);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '$totalPages',
                    style: pBold24.copyWith(
                      color: AppColor.primaryColor,
                      fontSize: 32,
                    ),
                  ),
                  Text('Halaman', style: pSemiBold14),
                  Text(
                    'Pekan Ini',
                    style: pRegular10.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightFactor, int totalPages) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$totalPages',
          style: pMedium10.copyWith(color: AppColor.primaryColor),
        ),
        const SizedBox(height: 4),
        Container(
          width: 12,
          height: 60 * heightFactor + 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.primaryColor.withOpacity(0.8),
                AppColor.primaryColor.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: pMedium10.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAnggotaSection(ShowGroupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                '${controller.group.value?.groupUser.length ?? 0} Anggota',
                style: pBold18,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(
                  Routes.showMemberGroup,
                  arguments: {
                    'groupId': controller.group.value!.id,
                    'creatorId': controller.group.value!.userId,
                  },
                );
              },
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: pBold14.copyWith(color: AppColor.primaryColor),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    IconlyLight.arrow_right_2,
                    size: 16,
                    color: AppColor.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 68,
          child: Obx(
            () => ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: (controller.group.value?.groupUser.length ?? 0) > 8
                  ? 8
                  : (controller.group.value?.groupUser.length ?? 0),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final user = controller.group.value!.groupUser[index].user;
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: user.profilePicture.isNotEmpty
                        ? Image.network(
                            user.profilePicture,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/images/png/user.png'),
                          )
                        : Image.asset(
                            'assets/images/png/user.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButtons(ShowGroupController controller) {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.toNamed(
          Routes.addMemberGroup,
          arguments: controller.group.value!.id,
        );
      },
      backgroundColor: AppColor.primaryColor,
      elevation: 4,
      icon: const Icon(IconlyBold.add_user, color: Colors.white),
      label: Text(
        'Tambah Anggota',
        style: pBold14.copyWith(color: Colors.white),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildEditGroup(ShowGroupController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text('Edit Info Grup', style: pBold18)),
          const SizedBox(height: 24),
          Text('Nama Grup', style: pSemiBold14),
          const SizedBox(height: 8),
          TextInput(
            controller: controller.nameController,
            hintText: 'Nama grup baru...',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grup Privat', style: pSemiBold14),
                    Text(
                      'Hanya anggota yang bisa melihat detail',
                      style: pRegular12.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.isPrivate.value,
                  onChanged: (val) => controller.isPrivate.value = val,
                  activeColor: AppColor.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.updateGroup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Simpan Perubahan',
                style: pBold14.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteGroup(ShowGroupController controller) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(IconlyBold.delete, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Hapus Grup?', style: pBold18),
            const SizedBox(height: 12),
            Text(
              'Grup akan dihapus permanen. Anggota tidak akan bisa lagi mengakses grup ini.',
              textAlign: TextAlign.center,
              style: pRegular14.copyWith(color: Colors.grey),
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
                    onPressed: () => controller.deleteGroup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Hapus',
                      style: pBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

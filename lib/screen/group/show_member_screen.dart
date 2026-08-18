import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/group/show_member_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/models/group/member_group_tilawah.dart';

class ShowMemberScreen extends StatelessWidget {
  const ShowMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowMemberController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, controller),
          Obx(() {
            if (controller.isLoading.value && controller.group.value == null) {
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
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
                        color: Theme.of(context).disabledColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada anggota',
                        style: pMedium14.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
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
                  return _buildMemberTile(context, member, controller);
                }, childCount: controller.group.value!.groupUser.length),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ShowMemberController controller) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anggota Grup',
              style: pBold18.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${controller.group.value?.memberCount ?? 0} Anggota Terdaftar',
              style: pRegular12.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(
          IconlyLight.arrow_left_2,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    GroupUser member,
    ShowMemberController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
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
                  style: pBold14.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      IconlyLight.document,
                      size: 12,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${member.totalPages} Halaman',
                      style: pRegular12.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (controller.isOwner && member.userId != controller.creatorId)
            IconButton(
              onPressed: () => _confirmDropUser(
                context,
                controller,
                member.userId,
                member.user.name,
              ),
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
    BuildContext context,
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
            color: Theme.of(context).colorScheme.surface,
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
                style: pRegular14.copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: pBold14.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
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

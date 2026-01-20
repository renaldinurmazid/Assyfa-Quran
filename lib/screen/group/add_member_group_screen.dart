import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/group/add_member_group_controller.dart';
import 'package:quran_app/models/group/user_for_group_list.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class AddMemberGroupScreen extends StatelessWidget {
  const AddMemberGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMemberGroupController());
    const String inviteLink = 'https://quranapp.id/app190289881';

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInviteCard(inviteLink),
                  const SizedBox(height: 24),
                  Text(
                    'Tambah dari Daftar',
                    style: pBold16.copyWith(color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 12),
                  TextInput(
                    controller: controller.searchController,
                    hintText: 'Cari nama teman...',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value && controller.users.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                ),
              );
            }

            if (controller.filteredUsers.isEmpty) {
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
                        'Tidak ada pengguna ditemukan',
                        style: pMedium14.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final user = controller.filteredUsers[index];
                  return _buildUserTile(user, controller);
                }, childCount: controller.filteredUsers.length),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColor.backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text('Undang Teman', style: pBold18),
      leading: IconButton(
        icon: const Icon(
          IconlyLight.arrow_left_2,
          color: AppColor.primaryColor,
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildInviteCard(String link) {
    return Container(
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconlyBold.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bagikan Tautan',
                style: pBold16.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ajak teman atau kerabat bergabung ke grup dengan membagikan tautan di bawah ini.',
            style: pRegular12.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link,
                    style: pMedium12.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: link));
                    Get.snackbar(
                      'Tersalin',
                      'Tautan undangan telah disalin ke papan klip',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                      colorText: AppColor.primaryColor,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: AppColor.primaryColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Datum user, AddMemberGroupController controller) {
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primaryColor.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: pBold14.copyWith(color: Colors.grey.shade800),
                ),
                Text(
                  'Siap untuk bergabung',
                  style: pRegular12.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Get.dialog(_addMemberDialog(controller, user.id, user.name));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: AppColor.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addMemberDialog(
    AddMemberGroupController controller,
    int userId,
    String userName,
  ) {
    return Dialog(
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
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColor.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tambah Anggota',
              style: pBold18.copyWith(color: AppColor.primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              'Apakah Anda yakin ingin menambahkan $userName ke dalam grup?',
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
                      side: BorderSide(
                        color: AppColor.primaryColor.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: pBold14.copyWith(color: AppColor.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.addUserToGroup(userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Tambah',
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

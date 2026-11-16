import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/profile/profile_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileScreenController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: pSemiBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Obx(() => _buildProfileHeader(context)),
              const SizedBox(height: 24),
              _buildMenuSection(context, controller),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final userData = AuthController.to.userData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColor.primaryColor.withOpacity(0.1),
            backgroundImage: userData['profile_picture'] != null
                ? NetworkImage(userData['profile_picture']!)
                : null,
            child: userData['profile_picture'] == null
                ? Icon(
                    LucideIcons.user,
                    size: 36,
                    color: AppColor.primaryColor.withOpacity(0.4),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            userData['name'] ?? 'Sahabat Assyfa',
            style: pSemiBold16.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'belum_login@mail.com',
            style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
          ),
          // const SizedBox(height: 20),

          // Quote Card
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          //   decoration: BoxDecoration(
          //     color: AppColor.primaryColor.withOpacity(0.05),
          //     borderRadius: BorderRadius.circular(14),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(LucideIcons.info, color: AppColor.primaryColor, size: 20),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: Text(
          //           '"Sudahkah hatimu menyapa Al-Quran hari ini?"',
          //           style: pMedium12.copyWith(
          //             color: AppColor.primaryColor,
          //             fontStyle: FontStyle.italic,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    ProfileScreenController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Pengaturan Akun',
            style: pSemiBold12.copyWith(color: AppColor.globalTextSecondary),
          ),
        ),
        _menuItem(
          context,
          title: 'Ubah Profil',
          icon: LucideIcons.user,
          onTap: () => Get.toNamed(Routes.changeProfile),
        ),
        _menuItem(
          context,
          title: 'Aktivitas Infaq',
          icon: LucideIcons.wallet,
          onTap: () => Get.toNamed(Routes.infaqActivity),
        ),
        _menuItem(
          context,
          title: 'Aktivitas Event',
          icon: LucideIcons.ticket,
          onTap: () {
            Get.toNamed(Routes.eventRegistrationList);
          },
        ),
        _menuItem(
          context,
          title: 'Aktivitas Doa',
          icon: LucideIcons.handHeart,
          onTap: () => Get.toNamed(Routes.listPrayer),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Lainnya',
            style: pSemiBold12.copyWith(color: AppColor.globalTextSecondary),
          ),
        ),
        Obx(
          () => _menuItem(
            context,
            title: controller.isLoadingShare.value
                ? 'Mempersiapkan...'
                : 'Share Aplikasi',
            icon: LucideIcons.share2,
            onTap: () => controller.shareApp(),
          ),
        ),
        _menuItem(
          context,
          title: 'Hapus Akun',
          icon: LucideIcons.trash2,
          onTap: () => Get.toNamed(Routes.deleteAccount),
          isDanger: true,
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.red.shade600,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          onPressed: () {
            AuthController.to.handleSignOut();
          },
          child: Text(
            'Keluar',
            style: pSemiBold14.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger ? Colors.red.shade500 : AppColor.globalTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDanger
              ? Colors.red.withOpacity(0.02)
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDanger
                ? Colors.red.withOpacity(0.2)
                : AppColor.globalBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: pMedium14.copyWith(
                  color: isDanger ? color : context.theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: AppColor.globalTextSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

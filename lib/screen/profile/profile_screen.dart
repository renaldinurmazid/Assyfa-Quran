import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/profile_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileScreenController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profil Saya', style: pSemiBold16),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundColor: context.theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: userData['profile_picture'] != null
                ? NetworkImage(userData['profile_picture']!)
                : null,
            child: userData['profile_picture'] == null
                ? Icon(
                    IconlyBold.profile,
                    size: 36,
                    color: context.theme.colorScheme.primary.withOpacity(0.4),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            userData['name'] ?? 'Sahabat Assyfa',
            style: pBold16.copyWith(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'belum_login@mail.com',
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Quote Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  IconlyBold.info_square,
                  color: context.theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"Sudahkah hatimu menyapa Al-Quran hari ini?"',
                    style: pMedium12.copyWith(
                      color: context.theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
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
            style: pSemiBold12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _menuItem(
          context,
          title: 'Ubah Profil',
          icon: IconlyLight.edit,
          onTap: () => Get.toNamed(Routes.changeProfile),
        ),
        _menuItem(
          context,
          title: 'Aktivitas Infaq',
          icon: IconlyLight.chart,
          onTap: () => Get.toNamed(Routes.infaqActivity),
        ),
        _menuItem(
          context,
          title: 'Aktivitas Event',
          icon: IconlyLight.ticket,
          onTap: () {
            Get.toNamed(Routes.eventRegistrationList);
          },
        ),
        _menuItem(
          context,
          title: 'Aktivitas Doa',
          icon: Icons.handshake_outlined,
          onTap: () => Get.toNamed(Routes.listPrayer),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Lainnya',
            style: pSemiBold12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Obx(
          () => _menuItem(
            context,
            title: controller.isLoadingShare.value
                ? 'Mempersiapkan...'
                : 'Share Aplikasi',
            icon: Icons.share_outlined,
            onTap: () => controller.shareApp(),
          ),
        ),
        _menuItem(
          context,
          title: 'Hapus Akun',
          icon: Icons.delete_outline,
          onTap: () => Get.toNamed(Routes.deleteAccount),
          isDanger: true,
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: Colors.red.shade700,
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
    final color = isDanger
        ? Colors.red.shade400
        : context.theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDanger
              ? Colors.red.withOpacity(0.03)
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDanger
                ? Colors.red.withOpacity(0.1)
                : context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
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
              IconlyLight.arrow_right_2,
              color: context.theme.colorScheme.onSurfaceVariant.withOpacity(
                0.4,
              ),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

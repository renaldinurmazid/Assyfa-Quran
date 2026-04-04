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
        title: Text(
          'Profil Saya',
          style: pSemiBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Obx(() => _buildProfileHeader(context)),
            const SizedBox(height: 20),
            _buildMenuSection(context, controller),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final userData = AuthController.to.userData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      child: Column(
        children: [
          // Avatar with Glow/Border
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.theme.colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: context.theme.colorScheme.surface,
              backgroundImage: userData['profile_picture'] != null
                  ? NetworkImage(userData['profile_picture']!)
                  : null,
              child: userData['profile_picture'] == null
                  ? Icon(
                      IconlyBold.profile,
                      size: 40,
                      color: context.theme.colorScheme.primary.withOpacity(0.3),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userData['name'] ?? 'Sahabat Assyfa',
            style: pBold20.copyWith(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'belum_login@mail.com',
            style: pRegular14.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          // Quote Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  IconlyBold.info_square,
                  color: context.theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '\"Sudahkah hatimu menyapa Al-Quran hari ini?\"',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Akun',
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant.withOpacity(
                0.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
            title: 'Aktivitas Doa',
            icon: Icons.handshake_outlined,
            onTap: () => Get.toNamed(Routes.listPrayer),
          ),
          const SizedBox(height: 24),
          Text(
            'Lainnya',
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant.withOpacity(
                0.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _menuItem(
              context,
              title: controller.isLoadingShare.value
                  ? 'Mempersiapkan...'
                  : 'Share Aplikasi',
              icon: Icons.share,
              onTap: () => controller.shareApp(),
            ),
          ),
          // _menuItem(
          //   title: 'Tentang Aplikasi',
          //   icon: IconlyLight.info_circle,
          //   onTap: () {},
          // ),
          _menuItem(
            context,
            title: 'Keluar',
            icon: IconlyLight.logout,
            onTap: () => AuthController.to.handleSignOut(),
            isDanger: true,
          ),
        ],
      ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDanger
                ? Colors.red.withOpacity(0.02)
                : context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDanger
                  ? Colors.red.withOpacity(0.1)
                  : context.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDanger
                      ? Colors.red.withOpacity(0.1)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: pMedium14.copyWith(
                    color: isDanger
                        ? color
                        : context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                IconlyLight.arrow_right_2,
                color: context.theme.colorScheme.onSurfaceVariant.withOpacity(
                  0.5,
                ),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

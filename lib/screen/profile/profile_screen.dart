import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text('Profil Saya', style: pBold18),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Obx(() => _buildProfileHeader()),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
                color: AppColor.primaryColor.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: userData['profile_picture'] != null
                  ? NetworkImage(userData['profile_picture']!)
                  : null,
              child: userData['profile_picture'] == null
                  ? Icon(
                      IconlyBold.profile,
                      size: 40,
                      color: AppColor.primaryColor.withOpacity(0.3),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userData['name'] ?? 'Sahabat Assyfa',
            style: pBold20.copyWith(color: AppColor.primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'belum_login@mail.com',
            style: pRegular14.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          // Quote Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  IconlyBold.info_square,
                  color: AppColor.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '\"Sudahkah hatimu menyapa Al-Quran hari ini?\"',
                    style: pMedium12.copyWith(
                      color: AppColor.primaryColor,
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

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Akun',
            style: pSemiBold14.copyWith(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          _menuItem(
            title: 'Ubah Profil',
            icon: IconlyLight.edit,
            onTap: () => Get.toNamed(Routes.changeProfile),
          ),
          _menuItem(
            title: 'Aktivitas Infaq',
            icon: IconlyLight.chart,
            onTap: () => Get.toNamed(Routes.infaqActivity),
          ),
          const SizedBox(height: 24),
          Text(
            'Lainnya',
            style: pSemiBold14.copyWith(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          // _menuItem(
          //   title: 'Tentang Aplikasi',
          //   icon: IconlyLight.info_circle,
          //   onTap: () {},
          // ),
          _menuItem(
            title: 'Keluar',
            icon: IconlyLight.logout,
            onTap: () => AuthController.to.handleSignOut(),
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger ? Colors.red.shade400 : AppColor.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDanger ? Colors.red.withOpacity(0.02) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDanger
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
                    color: isDanger ? color : AppColor.textColor,
                  ),
                ),
              ),
              Icon(
                IconlyLight.arrow_right_2,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

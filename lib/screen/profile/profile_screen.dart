import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: Text('Profile', style: pSemiBold16),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(children: [Obx(() => _buildProfileInfo()), _buildMenu()]),
      ),
    );
  }

  Widget _buildMenu() {
    final listMenu = [
      {'title': 'Ubah Profile', 'icon': Icons.person},
      {'title': 'Aktivitas Tilawah', 'icon': Icons.book},
      {'title': 'Keluar', 'icon': Icons.logout},
    ];
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      separatorBuilder: (context, index) {
        return const SizedBox(height: 4);
      },
      shrinkWrap: true,
      itemCount: listMenu.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (listMenu[index]['title'] == 'Keluar') {
              AuthController.to.handleSignOut();
            } else if (listMenu[index]['title'] == 'Ubah Profile') {
              Get.toNamed(Routes.changeProfile);
            }
          },
          child: Row(
            children: [
              Icon(
                listMenu[index]['icon'] as IconData,
                color: AppColor.primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    listMenu[index]['title'] as String,
                    style: pSemiBold14.copyWith(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: AuthController.to.userData['profile_picture'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        AuthController.to.userData['profile_picture']!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.person, size: 26, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Text(
              AuthController.to.userData['name'] ?? 'User Name',
              style: pMedium14.copyWith(color: AppColor.primaryColor),
            ),
            Text(
              AuthController.to.userData['email'] ?? 'email@gmail.com',
              style: pRegular12.copyWith(
                color: AppColor.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 240,
              child: Text(
                'Sudahkah hatimu menyapa Al-Quran hari ini?',
                style: pRegular12.copyWith(color: AppColor.primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

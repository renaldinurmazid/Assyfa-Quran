import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/screen/chat/chat_screen.dart';
import 'package:quran_app/screen/home_screen.dart';
import 'package:quran_app/screen/profile/profile_screen.dart';
import 'package:quran_app/screen/tilawahku_screen.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class MainController extends GetxController {
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    if ((index == 1 || index == 3) && !AuthController.to.isLogin.value) {
      _showLoginDialog();
      return;
    }
    tabIndex.value = index;
  }

  void _showLoginDialog() {
    final homeController = Get.find<HomeScreenController>();
    Get.dialog(const HomeScreen().buildLoginDialog(homeController));
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    final MainController controller = Get.put(MainController());

    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomeScreen(),
            TilawahkuScreen(),
            ChatScreen(),
            ProfileScreen(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          unselectedItemColor: AppColor.primaryColor.withOpacity(0.2),
          selectedItemColor: AppColor.primaryColor,
          onTap: controller.changeTabIndex,
          currentIndex: controller.tabIndex.value,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColor.backgroundColor,
          selectedLabelStyle: pMedium12.copyWith(color: AppColor.primaryColor),
          unselectedLabelStyle: pRegular12.copyWith(
            color: AppColor.primaryColor.withOpacity(0.2),
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(IconlyLight.home),
              label: 'Home',
              activeIcon: Icon(IconlyBold.home),
            ),
            BottomNavigationBarItem(
              icon: Icon(IconlyLight.bookmark),
              label: 'Tilawahku',
              activeIcon: Icon(IconlyBold.bookmark),
            ),
            BottomNavigationBarItem(
              icon: Icon(IconlyLight.chat),
              label: 'Pesan',
              activeIcon: Icon(IconlyBold.chat),
            ),
            BottomNavigationBarItem(
              icon: Icon(IconlyLight.profile),
              label: 'Profile',
              activeIcon: Icon(IconlyBold.profile),
            ),
          ],
        );
      }),
    );
  }
}

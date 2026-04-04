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
    if ((index == 1 || index == 2 || index == 3) &&
        !AuthController.to.isLogin.value) {
      _showLoginDialog();
      return;
    }
    tabIndex.value = index;
  }

  void _showLoginDialog() {
    if (!Get.isRegistered<HomeScreenController>()) return;
    final homeController = Get.find<HomeScreenController>();
    Get.dialog(const HomeScreen().buildLoginDialog(homeController));
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          unselectedItemColor: Colors.grey.shade600,
          selectedItemColor: context.theme.colorScheme.primary,
          onTap: controller.changeTabIndex,
          currentIndex: controller.tabIndex.value,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          selectedLabelStyle: pMedium12.copyWith(color: AppColor.primaryColor),
          unselectedLabelStyle: pRegular12.copyWith(
            color: Colors.grey.shade600,
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
              icon: Icon(IconlyLight.notification),
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

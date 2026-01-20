import 'package:get/get.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/group/add_member_group_screen.dart';
import 'package:quran_app/screen/group/show_member_screen.dart';
import 'package:quran_app/screen/profile/change_profile_screen.dart';
import 'package:quran_app/screen/charity/charity_screen.dart';
import 'package:quran_app/screen/group/create_group_ngaji_screen.dart';
import 'package:quran_app/screen/dzikir&doa/dzikir_screen.dart';
import 'package:quran_app/screen/dzikir&doa/dzikir_show_screen.dart';
import 'package:quran_app/screen/group/group_ngaji_screen.dart';
import 'package:quran_app/screen/dzikir&doa/list_doa_screen.dart';
import 'package:quran_app/screen/main_screen.dart';
import 'package:quran_app/screen/prayer_time_detail_screen.dart';
import 'package:quran_app/screen/quran_view/quran_list_detail_screen.dart';
import 'package:quran_app/screen/quran_view/quran_list_screen.dart';
import 'package:quran_app/screen/quran_view/quran_page_screen.dart';
import 'package:quran_app/screen/group/show_group_screen.dart';
import 'package:quran_app/screen/splash_screen.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.dzikir,
      page: () => const DzikirScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.dzikirShow,
      page: () => const DzikirShowScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.listDoa,
      page: () => const ListDoaScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.prayerTimeDetail,
      page: () => const PrayerTimeDetailScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.quranList,
      page: () => const QuranListScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.quranListDetail,
      page: () => const QuranListDetailScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.quranPage,
      page: () => const QuranPageScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.charity,
      page: () => const CharityScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.changeProfile,
      page: () => const ChangeProfileScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.groupNgaji,
      page: () => const GroupNgajiScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.createGroupNgaji,
      page: () => const CreateGroupNgajiScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.showGroup,
      page: () => const ShowGroupScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.addMemberGroup,
      page: () => const AddMemberGroupScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.showMemberGroup,
      page: () => const ShowMemberScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}

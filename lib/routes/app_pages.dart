import 'package:get/get.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/app_share_leaderboard/app_share_leaderboard_screen.dart';
import 'package:quran_app/screen/blog/show_blog_screen.dart';
import 'package:quran_app/screen/charity/charity_donatur_screen.dart';
import 'package:quran_app/screen/group/add_member_group_screen.dart';
import 'package:quran_app/screen/group/show_member_screen.dart';
import 'package:quran_app/screen/charity/mosque_infaq_activity_detail_screen.dart';
import 'package:quran_app/screen/leaderboard/leaderboard_screen.dart';
import 'package:quran_app/screen/mosque/mosque_charity_screen.dart';
import 'package:quran_app/screen/mosque/mosque_charity_show_screen.dart';
import 'package:quran_app/screen/mosque/mosque_charity_payment_detail_screen.dart';
import 'package:quran_app/screen/mosque/mosque_charity_payment_screen.dart';
import 'package:quran_app/screen/mosque/mosque_charity_donatur_screen.dart';
import 'package:quran_app/screen/mosque/mosque_map_screen.dart';
import 'package:quran_app/screen/notification/notification_screen.dart';
import 'package:quran_app/screen/prayer/create_prayer_screen.dart';
import 'package:quran_app/screen/prayer/list_prayer_screen.dart';
import 'package:quran_app/screen/prayer/show_prayer_screen.dart';

import 'package:quran_app/screen/profile/change_profile_screen.dart';
import 'package:quran_app/screen/charity/charity_screen.dart';
import 'package:quran_app/screen/charity/charity_show_screen.dart';
import 'package:quran_app/screen/charity/charity_search_screen.dart';
import 'package:quran_app/screen/group/create_group_ngaji_screen.dart';
import 'package:quran_app/screen/dzikir&doa/dzikir_screen.dart';
import 'package:quran_app/screen/dzikir&doa/dzikir_show_screen.dart';
import 'package:quran_app/screen/group/group_ngaji_screen.dart';
import 'package:quran_app/screen/group/group_search_screen.dart';
import 'package:quran_app/screen/dzikir&doa/list_doa_screen.dart';
import 'package:quran_app/screen/main_screen.dart';
import 'package:quran_app/screen/prayer_time_detail_screen.dart';
import 'package:quran_app/screen/quran_view/quran_list_detail_screen.dart';
import 'package:quran_app/screen/quran_view/quran_list_screen.dart';
import 'package:quran_app/screen/quran_view/quran_page_info_screen.dart';
import 'package:quran_app/screen/quran_view/quran_page_screen.dart';
import 'package:quran_app/screen/group/show_group_screen.dart';
import 'package:quran_app/screen/charity/charity_payment_screen.dart';
import 'package:quran_app/screen/charity/charity_payment_detail_screen.dart';
import 'package:quran_app/screen/charity/infaq_activity_screen.dart';
import 'package:quran_app/screen/charity/infaq_activity_detail_screen.dart';
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
      name: Routes.charityShow,
      page: () => const CharityShowScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.charitySearch,
      page: () => const CharitySearchScreen(),
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
      name: Routes.groupSearch,
      page: () => const GroupSearchScreen(),
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
    GetPage(
      name: Routes.charityPayment,
      page: () => const CharityPaymentScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.charityPaymentDetail,
      page: () => const CharityPaymentDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.infaqActivity,
      page: () => const InfaqActivityScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.infaqActivityDetail,
      page: () => const InfaqActivityDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.mosqueCharity,
      page: () => const MosqueCharityScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.mosqueCharityShow,
      page: () => const MosqueCharityShowScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.mosqueMap,
      page: () => const MosqueMapScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.mosqueCharityPayment,
      page: () => const MosqueCharityPaymentScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.mosqueCharityPaymentDetail,
      page: () => const MosqueCharityPaymentDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.mosqueInfaqActivityDetail,
      page: () => const MosqueInfaqActivityDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.leaderboard,
      page: () => const LeaderboardScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.appShareLeaderboard,
      page: () => const AppShareLeaderboardScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.charityDonatur,
      page: () => const CharityDonaturScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.mosqueCharityDonatur,
      page: () => const MosqueCharityDonaturScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.quranPageInfo,
      page: () => const QuranPageInfoScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.showBlog,
      page: () => const ShowBlogScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.createPrayer,
      page: () => const CreatePrayerScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.showPrayer,
      page: () => const ShowPrayerScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.listPrayer,
      page: () => const ListPrayerScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.notification,
      page: () => const NotificationScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}

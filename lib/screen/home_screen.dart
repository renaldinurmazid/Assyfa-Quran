import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/controller/quran/tilawah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());
    Get.put(TilawahController());

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getPrayerTime();
            await controller.getCalendarToday();
          },
          color: AppColor.primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildQuickActions(controller),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Program Spesial', () {}),
                      const SizedBox(height: 16),
                      _buildSlideBanner(controller),
                      const SizedBox(height: 32),
                      _buildFeaturedCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(HomeScreenController controller) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      stretch: true,
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/png/bg-palestine.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                    const Color(0xFFFBFBFB).withOpacity(0.8),
                    const Color(0xFFFBFBFB),
                  ],
                ),
              ),
            ),
            _buildHeroContent(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroContent(HomeScreenController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(controller),
            const SizedBox(height: 32),
            _buildPrayerGlassCard(controller),
            const SizedBox(height: 24),
            _buildQuranQuickAccess(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HomeScreenController controller) {
    return Obx(() {
      final isLogin = AuthController.to.isLogin.value;
      final userData = AuthController.to.userData;
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: userData['profile_picture'] != null
                  ? NetworkImage(userData['profile_picture']!)
                  : null,
              child: userData['profile_picture'] == null
                  ? Icon(
                      IconlyBold.profile,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLogin ? 'Assalamu’alaikum,' : 'Selamat Datang,',
                style: pRegular12.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                isLogin ? '${userData['name']}' : 'Orang Baik',
                style: pBold16.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildPrayerGlassCard(HomeScreenController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: InkWell(
          onTap: () {
            Get.toNamed('/prayer_time_detail');
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.calendarToday.value,
                            style: pMedium12.copyWith(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Row(
                            children: [
                              const Icon(
                                IconlyBold.location,
                                color: Colors.orangeAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${controller.kabKota.value}',
                                style: pBold14.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          controller.countdownText.value.split(' ').first,
                          style: pBold14.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: controller.displayPrayers.asMap().entries.map((
                        entry,
                      ) {
                        int idx = entry.key;
                        var prayer = entry.value;
                        bool isCurrent = idx == 0;
                        return Container(
                          margin: const EdgeInsets.only(right: 28),
                          child: Column(
                            children: [
                              Text(
                                prayer['name']!.capitalizeFirst!,
                                style: pRegular12.copyWith(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.white60,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                prayer['time']!,
                                style: pBold18.copyWith(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  height: 4,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.orangeAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuranQuickAccess(HomeScreenController controller) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.bottomSheet(_buildBottomSheetQuran(controller)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SvgPicture.asset('assets/images/svg/al-quran.svg', width: 50),
                const SizedBox(height: 12),
                Text('Al-Quran', style: pBold14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 85,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() {
              final isLogin = AuthController.to.isLogin.value;
              return isLogin
                  ? _buildTilawahStats(controller)
                  : _buildLoginOffer(controller);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTilawahStats(HomeScreenController controller) {
    if (controller.isLoadingWeekly.value) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final summary = controller.weeklyStats['summary'] as List? ?? [];
    final totalPages = controller.weeklyStats['total_pages'] ?? 0;

    // Find max value for scaling
    double maxVal = 0;
    for (var item in summary) {
      if ((item['total_pages'] ?? 0).toDouble() > maxVal) {
        maxVal = (item['total_pages'] ?? 0).toDouble();
      }
    }
    if (maxVal < 5) maxVal = 5; // Default reference

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progres Ngaji',
                style: pRegular10.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                '$totalPages Halaman',
                style: pBold12.copyWith(color: AppColor.primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: summary.map((item) {
              final val = (item['total_pages'] ?? 0).toDouble();
              final heightFactor = (val / maxVal).clamp(0.05, 1.0);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4.0,
                    height: (25 * heightFactor).toDouble(),
                    decoration: BoxDecoration(
                      color: val > 0
                          ? AppColor.primaryColor
                          : AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['day'],
                    style: pRegular10.copyWith(
                      fontSize: 8,
                      color: val > 0 ? AppColor.primaryColor : Colors.grey,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginOffer(HomeScreenController controller) {
    return InkWell(
      onTap: () => Get.dialog(buildLoginDialog(controller)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            IconlyLight.bookmark,
            color: AppColor.primaryColor,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            'Login Yuk!',
            style: pBold12.copyWith(color: AppColor.primaryColor),
          ),
          Text(
            'Simpan Progres',
            style: pRegular10.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(HomeScreenController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          'Infaq',
          'assets/images/svg/infaq.svg',
          () => Get.toNamed(Routes.charity),
          const Color(0xFFF0F9F1),
        ),
        _buildActionItem(
          'Dzikir',
          'assets/images/svg/dzikir.svg',
          () => Get.toNamed(Routes.dzikir),
          const Color(0xFFF0F7FF),
        ),
        _buildActionItem(
          'Masjid',
          'assets/images/svg/ic-mosque.svg',
          () {},
          const Color(0xFFFFF7ED),
        ),
        _buildActionItem(
          'More',
          'assets/images/svg/ic-info.svg',
          () => Get.bottomSheet(_bottomSheetMoreMenu()),
          const Color(0xFFFAF5FF),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String label,
    String asset,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: pSemiBold12.copyWith(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: pBold18.copyWith(color: Colors.black87)),
        TextButton(
          onPressed: onTap,
          child: Text(
            'Lihat Semua',
            style: pSemiBold14.copyWith(color: AppColor.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideBanner(HomeScreenController controller) {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: controller.sliderController,
        itemCount: controller.dataBanner.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                controller.dataBanner[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              IconlyBold.shield_done,
              color: AppColor.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Solidaritas Palestina', style: pBold16),
                const SizedBox(height: 4),
                Text(
                  'Bantu saudara kita di Gaza',
                  style: pRegular12.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(IconlyLight.arrow_right_2, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomSheetQuran(HomeScreenController controller) {
    final dataQuran = [
      {
        'title': 'Per Ayat',
        'asset': 'assets/images/svg/q-yellow.svg',
        'is_pages': false,
        'slug': 'per-ayat',
        'route': Routes.quranList,
      },
      {
        'title': 'Indonesia',
        'asset': 'assets/images/svg/q-red.svg',
        'is_pages': true,
        'slug': 'id',
        'route': Routes.quranPage,
      },
      {
        'title': 'Tajwid Indo',
        'asset': 'assets/images/svg/q-blue.svg',
        'is_pages': true,
        'slug': 'id-tajwid',
        'route': Routes.quranPage,
      },
      {
        'title': 'Per-Kata',
        'asset': 'assets/images/svg/q-green.svg',
        'is_pages': true,
        'slug': 'kata-tajwid',
        'route': Routes.quranPage,
      },
      {
        'title': 'Latin',
        'asset': 'assets/images/svg/q-blue.svg',
        'is_pages': true,
        'slug': 'latin-tajwid',
        'route': Routes.quranPage,
      },
      {
        'title': 'Madinah',
        'asset': 'assets/images/svg/q-red.svg',
        'is_pages': true,
        'slug': 'md',
        'route': Routes.quranPage,
      },
      {
        'title': 'Tajwid Md',
        'asset': 'assets/images/svg/q-yellow.svg',
        'is_pages': true,
        'slug': 'md-tajwid',
        'route': Routes.quranPage,
      },
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 28),
          _buildRiwayatCard(controller),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Pilih Mushaf', style: pBold18),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.72,
            ),
            itemCount: dataQuran.length,
            itemBuilder: (context, index) {
              final item = dataQuran[index];
              return InkWell(
                onTap: () {
                  Get.back();
                  if (item['is_pages'] as bool) {
                    Get.toNamed(
                      Routes.quranPage,
                      arguments: {'slug': item['slug']},
                    );
                  } else {
                    Get.toNamed(Routes.quranList);
                  }
                },
                child: Column(
                  children: [
                    Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SvgPicture.asset(
                          item['asset'] as String,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      style: pMedium10,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(HomeScreenController controller) {
    return Obx(() {
      if (!AuthController.to.isLogin.value || controller.isOfflineMode.value)
        return const SizedBox();
      return InkWell(
        onTap: () {
          Get.back();
          _showTilawahHistoryDialog();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(IconlyBold.bookmark, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Tilawah',
                      style: pBold16.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Lanjutkan bacaan terakhirmu',
                      style: pRegular12.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(
                IconlyLight.arrow_right_2,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _bottomSheetMoreMenu() {
    final menu = [
      {
        'title': 'Grup Ngaji',
        'icon': 'assets/images/svg/ic-group-ngaji.svg',
        'route': Routes.groupNgaji,
      },
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Layanan Lainnya', style: pBold18),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: menu.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                if (menu[index]['route'] != null) {
                  Get.back();
                  Get.toNamed(menu[index]['route'] as String);
                }
              },
              child: Column(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: SvgPicture.asset(menu[index]['icon'] as String),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    menu[index]['title'] as String,
                    style: pSemiBold10,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginDialog(HomeScreenController controller) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login Sekarang',
              style: pBold20.copyWith(color: AppColor.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Simpan riwayat ngaji dan nikmati fitur lainnya',
              style: pRegular12,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: controller.bannerLoginController,
                itemCount: controller.banner.length,
                itemBuilder: (context, index) =>
                    Image.asset(controller.banner[index]),
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => ElevatedButton(
                onPressed: AuthController.to.isLoading.value
                    ? null
                    : () => AuthController.to.handleSignIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  shadowColor: AppColor.primaryColor.withOpacity(0.4),
                ),
                child: AuthController.to.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/png/google.png',
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Login dengan Google',
                            style: pBold14.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTilawahHistoryDialog() {
    final tilawahController = Get.put(TilawahController());
    tilawahController.loadAllBookmarks();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Riwayat', style: pBold20),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      IconlyLight.close_square,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Obx(() {
                  if (tilawahController.isLoading.value)
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  if (tilawahController.bookmarks.isEmpty)
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('Belum ada data'),
                    );
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: tilawahController.bookmarks.length,
                    itemBuilder: (context, index) {
                      final b = tilawahController.bookmarks[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            IconlyBold.document,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(b['surah_name'], style: pBold14),
                        subtitle: Text(
                          'Halaman ${b['page_number']}',
                          style: pRegular12,
                        ),
                        trailing: const Icon(
                          IconlyLight.arrow_right_2,
                          size: 16,
                        ),
                        onTap: () {
                          Get.back();
                          Get.toNamed(
                            Routes.quranPage,
                            arguments: {
                              'slug': b['quran_type_slug'] ?? 'id',
                              'page_number': b['page_number'],
                            },
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

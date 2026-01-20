import 'package:flutter/material.dart';
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
      backgroundColor: AppColor.backgroundColor,
      body: Column(
        children: [
          _buildHeroBanner(controller),
          _buildMenu(),
          _buildSlideBanner(controller),
        ],
      ),
    );
  }

  Widget _buildSlideBanner(HomeScreenController controller) {
    return SizedBox(
      height: 158,
      width: double.infinity,
      child: PageView.builder(
        controller: controller.sliderController,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        itemCount: controller.dataBanner.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.primaryColor.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
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

  Widget _buildMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.charity);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned(
                          left: -5,
                          right: -5,
                          bottom: -20,
                          child: SvgPicture.asset(
                            'assets/images/svg/infaq.svg',
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Infaq', style: pSemiBold12.copyWith(fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.dzikir);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned(
                          left: -5,
                          right: -5,
                          bottom: -25,
                          child: SvgPicture.asset(
                            'assets/images/svg/dzikir.svg',
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Dzikir', style: pSemiBold12.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -5,
                        right: -5,
                        bottom: -12,
                        child: SvgPicture.asset(
                          'assets/images/svg/ic-mosque.svg',
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kencleng\nMasjid',
                style: pSemiBold12.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Get.bottomSheet(_bottomSheetMoreMenu());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/svg/ic-info.svg',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text('More', style: pSemiBold12.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(HomeScreenController controller) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 380,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/png/bg-palestine.png'),
              colorFilter: ColorFilter.mode(
                Color.fromARGB(100, 0, 0, 0),
                BlendMode.srcOver,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 16,
            decoration: const BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 12,
          right: 20,
          child: GestureDetector(
            onTap: () {
              Get.toNamed(Routes.prayerTimeDetail);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.calendarToday.value,
                    style: pRegular12.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => SizedBox(
                    height: 50,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final prayer = controller.displayPrayers[index];
                        final nameRaw = prayer['name']!;
                        final name =
                            "${nameRaw[0].toUpperCase()}${nameRaw.substring(1)}";
                        final time = prayer['time']!;
                        final isFirst = index == 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: isFirst
                                  ? pBold14.copyWith(color: Colors.white)
                                  : pRegular14.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: isFirst
                                  ? pBold16.copyWith(color: Colors.white)
                                  : pRegular14.copyWith(color: Colors.white),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Center(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 1,
                            height: 15,
                          ),
                        );
                      },
                      itemCount: controller.displayPrayers.length,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Row(
                    children: [
                      AnimatedOpacity(
                        opacity: controller.isPrayerArrived.value
                            ? (controller.showHeartbeat.value ? 1.0 : 0.3)
                            : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          controller.countdownText.value,
                          style: pRegular12.copyWith(
                            color: Colors.white,
                            fontWeight: controller.isPrayerArrived.value
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(IconlyBold.location, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.kabKota.value}, ${controller.provinsi.value}',
                        style: pRegular12.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(_buildBottomSheetQuran(controller));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/al-quran.svg',
                        width: 80,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Al-Quran',
                        style: pSemiBold12.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(
                        () => AuthController.to.isLogin.value
                            ? _widgetDailyTilawah(controller)
                            : _widgetBeforeLoginInfo(controller),
                      ),
                      const SizedBox(height: 8),
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 12,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: AppColor.primaryColor,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         '173.029.182',
                      //         style: pBold14.copyWith(
                      //           color: AppColor.backgroundColor,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 6),
                      //       Text(
                      //         'Halaman telah dibaca',
                      //         style: pRegular12.copyWith(
                      //           color: AppColor.backgroundColor,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _widgetDailyTilawah(HomeScreenController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 106,
          child: RichText(
            text: TextSpan(
              text: 'Pekan ini kamu telah ngaji ',
              style: pRegular12.copyWith(color: Colors.white),
              children: [
                TextSpan(
                  text: '\n1',
                  style: pSemiBold14.copyWith(color: AppColor.backgroundColor),
                ),
                TextSpan(
                  text: '\nHalaman',
                  style: pRegular12.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 60, color: Colors.white),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _widgetBeforeLoginInfo(HomeScreenController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    'Login agar aktivitas ngajimu tercatat',
                    style: pRegular10.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.dialog(buildLoginDialog(controller));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    minimumSize: const Size(80, 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: Text(
                    'Login yuk!',
                    style: pRegular10.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildLoginDialog(HomeScreenController controller) {
    return Dialog(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Login yuk!',
                    style: pSemiBold18.copyWith(color: AppColor.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dapatkan akses gratis 6 jenis mushaf dan fitur menarik lainnya.',
                    style: pRegular12,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: controller.bannerLoginController,
                onPageChanged: (index) {
                  controller.bannerLoginPage.value = index;
                },
                itemCount: controller.banner.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    controller.banner[index],
                    width: 60,
                    height: 60,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.banner.length,
                  (index) => Obx(
                    () => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: controller.bannerLoginPage.value == index
                            ? AppColor.primaryColor
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => InkWell(
                onTap: AuthController.to.isLoading.value
                    ? null
                    : () async {
                        await AuthController.to.handleSignIn();
                        if (AuthController.to.isLogin.value) {
                          Get.back(); // Tutup dialog setelah berhasil login
                        }
                      },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: AuthController.to.isLoading.value
                      ? const Center(
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/png/google.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Login dengan Google',
                              style: pSemiBold12.copyWith(
                                color: AppColor.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
              child: Text(
                'Login dengan akun lainnya',
                style: pSemiBold12.copyWith(color: AppColor.primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: RichText(
                text: TextSpan(
                  text: 'Dengan mendaftar, Anda setuju dengan ',
                  style: pRegular12,
                  children: [
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: pSemiBold12.copyWith(color: AppColor.primaryColor),
                    ),
                    TextSpan(text: ' dan ', style: pRegular12),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: pSemiBold12.copyWith(color: AppColor.primaryColor),
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
        'title': 'Indonesia Tajwid',
        'asset': 'assets/images/svg/q-blue.svg',
        'is_pages': true,
        'slug': 'id-tajwid',
        'route': Routes.quranPage,
      },
      {
        'title': 'Per Kata Tajwid',
        'asset': 'assets/images/svg/q-green.svg',
        'is_pages': true,
        'slug': 'kata-tajwid',
        'route': Routes.quranPage,
      },
      {
        'title': 'Latin Tajwid',
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
        'title': 'Madinah Tajwid',
        'asset': 'assets/images/svg/q-yellow.svg',
        'is_pages': true,
        'slug': 'md-tajwid',
        'route': Routes.quranPage,
      },
    ];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 2,
              width: 100,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (AuthController.to.isLogin.value == false ||
                controller.isOfflineMode.value) {
              return Container();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      _showTilawahHistoryDialog();
                    },
                    child: Container(
                      width: 130,
                      height: 136,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 3,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColor.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tilawahku',
                                style: pSemiBold12.copyWith(
                                  color: AppColor.backgroundColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Terdapat ${Get.find<TilawahController>().bookmarks.length} tilawah',
                              style: pRegular12.copyWith(
                                color: AppColor.backgroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Al-Quran',
                style: pMedium14.copyWith(color: AppColor.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dataQuran.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (dataQuran[index]['is_pages'] as bool) {
                      Get.back();
                      Get.toNamed(
                        Routes.quranPage,
                        arguments: {'slug': dataQuran[index]['slug']},
                      );
                    } else {
                      Get.back();
                      Get.toNamed(Routes.quranList);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SvgPicture.asset(
                            dataQuran[index]['asset'] as String,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dataQuran[index]['title'] as String,
                        style: pMedium10.copyWith(color: AppColor.primaryColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSheetMoreMenu() {
    final List<Map<String, dynamic>> menu = [
      // {
      //   'title': 'Arah Kiblat',
      //   'icon': 'assets/images/svg/ic-kabah.svg',
      //   'route': null,
      // },
      {
        'title': 'Grup Ngaji',
        'icon': 'assets/images/svg/ic-group-ngaji.svg',
        'route': Routes.groupNgaji,
      },
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu Lainnya', style: pRegular12),
          const SizedBox(height: 20),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (menu[index]['route'] != null) {
                    Get.back();
                    Get.toNamed(menu[index]['route']);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SvgPicture.asset(
                          menu[index]['icon'] as String,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menu[index]['title'] as String,
                      style: pSemiBold10.copyWith(color: AppColor.primaryColor),
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

  void _showTilawahHistoryDialog() {
    final tilawahController = Get.put(TilawahController());
    tilawahController.loadAllBookmarks();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: Get.height * 0.7),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Tilawah',
                    style: pBold18.copyWith(color: AppColor.primaryColor),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      IconlyLight.close_square,
                      color: Colors.grey,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Obx(() {
                  if (tilawahController.isLoading.value &&
                      tilawahController.bookmarks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    );
                  }

                  if (tilawahController.bookmarks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            IconlyLight.bookmark,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat',
                            style: pMedium14.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: tilawahController.bookmarks.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Colors.grey),
                    itemBuilder: (context, index) {
                      final bookmark = tilawahController.bookmarks[index];
                      final surahName = bookmark['surah_name'] ?? '';
                      final pageNumber = bookmark['page_number'];
                      final quranType = bookmark['quran_type'] ?? 'Quran';

                      return InkWell(
                        onTap: () {
                          Get.back();
                          Get.toNamed(
                            Routes.quranPage,
                            arguments: {
                              'slug':
                                  (bookmark['quran_type_slug'] ??
                                  quranType.toLowerCase().replaceAll(' ', '-')),
                              'page_number': pageNumber,
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  IconlyLight.document,
                                  size: 18,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surahName,
                                      style: pBold14.copyWith(
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Text(
                                      '$quranType • Halaman $pageNumber',
                                      style: pRegular12.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                IconlyLight.arrow_right_2,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
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

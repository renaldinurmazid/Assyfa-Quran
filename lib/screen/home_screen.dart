import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/blog_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/controller/quran/tilawah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';

import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart' as widget;
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());
    final blogController = Get.put(BlogController());
    Get.put(TilawahController());

    // Mark deep link service as ready once HomeScreen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().markReady();
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: context.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getPrayerTime();
            await controller.fetchWeeklyStats();
            await controller.fetchPrayers();
            await blogController.refreshBlogs();
            await controller.fetchReadingHistoryTotal();
          },
          color: context.theme.colorScheme.primary,
          child: CustomScrollView(
            controller: blogController.scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildQuickActions(context, controller),
                      const SizedBox(height: 20),
                      // _buildSectionHeader(context, 'Program Spesial'),
                      const SizedBox(height: 16),
                      _buildSlideBanner(context, controller),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        context,
                        'Saling Mendoakan',
                        true,
                        InkWell(
                          onTap: () {
                            final isLogin = AuthController.to.isLogin.value;
                            if (isLogin) {
                              Get.toNamed(Routes.createPrayer);
                            } else {
                              controller.isEmailLogin.value = false;
                              Get.dialog(buildLoginDialog(controller));
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 18),
                              const SizedBox(width: 4),
                              Text('Buat Doa', style: pSemiBold12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildListDoa(context, controller),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        context,
                        'Taman Syurga',
                        false,
                        const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                      _buildListBlog(context, controller),
                      const SizedBox(height: 32),
                      // _buildFeaturedCard(context),
                      // const SizedBox(height: 40),
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

  Widget _buildSliverAppBar(
    BuildContext context,
    HomeScreenController controller,
  ) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      stretch: true,
      backgroundColor: context.isDarkMode
          ? context.theme.scaffoldBackgroundColor
          : context.theme.colorScheme.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              final auth = AuthController.to;
              final bgUrl = auth.userData['selected_background_path_url'];

              if (!auth.isLogin.value || bgUrl == null || bgUrl.isEmpty) {
                return Image.asset(
                  'assets/images/png/bg-palestine.png',
                  fit: BoxFit.cover,
                );
              }

              return Image.network(
                bgUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/png/bg-palestine.png',
                    fit: BoxFit.cover,
                  );
                },
              );
            }),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                    context.theme.scaffoldBackgroundColor.withOpacity(0.8),
                    context.theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
            _buildHeroContent(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroContent(
    BuildContext context,
    HomeScreenController controller,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            const SizedBox(height: 32),
            _buildPrayerGlassCard(context, controller),
            const SizedBox(height: 24),
            _buildQuranQuickAccess(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeScreenController controller) {
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
                style: pRegular12.copyWith(color: Colors.white),
              ),
              Text(
                isLogin ? '${userData['name']}' : 'Orang Baik',
                style: pSemiBold14.copyWith(color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              Get.toNamed('/theme');
            },
            child: Icon(Icons.palette_outlined, size: 26, color: Colors.white),
          ),
        ],
      );
    });
  }

  Widget _buildPrayerGlassCard(
    BuildContext context,
    HomeScreenController controller,
  ) {
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
            child: Obx(() {
              // Show shimmer when loading and no cached data
              if (controller.isLoadingPrayerTime.value &&
                  controller.displayPrayers.isEmpty) {
                return _buildPrayerCardShimmer(context);
              }

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              '${controller.dayName.value}, ${controller.calendarToday.value}',
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
                                  controller.kabKota.value,
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
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: controller.displayPrayers.asMap().entries.map((
                        entry,
                      ) {
                        int idx = entry.key;
                        var prayer = entry.value;
                        bool isCurrent = idx == 0;
                        return Column(
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
                                margin: const EdgeInsets.only(top: 4),
                                height: 4,
                                width: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.orangeAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCardShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode
          ? Colors.grey[800]!
          : Colors.white.withOpacity(0.1),
      highlightColor: context.isDarkMode
          ? Colors.grey[700]!
          : Colors.white.withOpacity(0.3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 90,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 70,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  Container(
                    width: 45,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 55,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranQuickAccess(
    BuildContext context,
    HomeScreenController controller,
  ) {
    return Row(
      children: [
        GestureDetector(
          onTap: () =>
              Get.bottomSheet(_buildBottomSheetQuran(context, controller)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset('assets/images/png/quran.png', width: 76),
                Text('Quranuna', style: pSemiBold14),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 85,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
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
                      ? _buildTilawahStats(context, controller)
                      : _buildLoginOffer(context, controller);
                }),
              ),
              Obx(() {
                final isLogin = AuthController.to.isLogin.value;
                return !isLogin
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: controller.formattedReadingHistoryTotal,
                                style: pSemiBold14.copyWith(
                                  color: context.theme.colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: ' Halaman telah dibaca',
                                style: pRegular12.copyWith(
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTilawahStats(
    BuildContext context,
    HomeScreenController controller,
  ) {
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
                style: pRegular10.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${NumberFormat.decimalPattern('id').format(totalPages)} Halaman',
                style: pBold12.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
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
                          ? context.theme.colorScheme.primary
                          : context.theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['day'],
                    style: pRegular10.copyWith(
                      fontSize: 8,
                      color: val > 0
                          ? context.theme.colorScheme.primary
                          : context.theme.colorScheme.onSurfaceVariant,
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

  Widget _buildLoginOffer(
    BuildContext context,
    HomeScreenController controller,
  ) {
    return InkWell(
      onTap: () {
        controller.isEmailLogin.value = false;
        Get.dialog(buildLoginDialog(controller));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.bookmark,
            color: context.theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            'Login Yuk!',
            style: pBold12.copyWith(color: context.theme.colorScheme.primary),
          ),
          Text(
            'Simpan Progres',
            style: pRegular10.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    HomeScreenController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          context,
          'Infaq',
          'assets/images/png/infaq.png',
          () => Get.toNamed(Routes.charity),
          const Color(0xFFF0F9F1),
        ),
        _buildActionItem(
          context,
          'Dzikir',
          'assets/images/png/tasbih.png',
          () => Get.toNamed(Routes.dzikir),
          const Color(0xFFF0F7FF),
        ),
        _buildActionItem(
          context,
          'Infaq Masjid',
          'assets/images/png/masjid.png',
          () => Get.toNamed(Routes.mosqueCharity),
          const Color(0xFFFFF7ED),
        ),
        _buildActionItem(
          context,
          'More',
          'assets/images/png/menu.png',
          () => Get.bottomSheet(_bottomSheetMoreMenu(context, controller)),
          const Color(0xFFFAF5FF),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String label,
    String asset,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            height: 65,
            width: 65,
            child: Image.asset(asset, fit: BoxFit.contain, width: 120),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: pSemiBold12.copyWith(
              fontSize: 11,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isShowAction,
    Widget actionWidget,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: pSemiBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        isShowAction ? actionWidget : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSlideBanner(
    BuildContext context,
    HomeScreenController controller,
  ) {
    return Obx(() {
      if (controller.isLoadingBanner.value) {
        return _buildBannerShimmer();
      }

      if (controller.dataBanner.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Belum ada program.',
              style: pRegular12.copyWith(color: Colors.grey),
            ),
          ),
        );
      }

      return SizedBox(
        height: 170,
        child: PageView.builder(
          controller: controller.sliderController,
          itemCount: controller.dataBanner.length,
          itemBuilder: (context, index) {
            final banner = controller.dataBanner[index];
            return GestureDetector(
              onTap: () async {
                final link = banner.redirectTo;
                final uri = Uri.tryParse(link);

                if (uri != null) {
                  final segments = uri.pathSegments;

                  // Check for charity: /c/{id} or /api/c/{id}
                  final cIndex = segments.indexOf('c');
                  if (cIndex != -1 && cIndex + 1 < segments.length) {
                    final id = int.tryParse(segments[cIndex + 1]);
                    if (id != null) {
                      Get.toNamed(Routes.charityShow, arguments: {'id': id});
                      return;
                    }
                  }

                  // Check for mosque charity: /m/{id} or /api/m/{id}
                  final mIndex = segments.indexOf('m');
                  if (mIndex != -1 && mIndex + 1 < segments.length) {
                    final id = int.tryParse(segments[mIndex + 1]);
                    if (id != null) {
                      Get.toNamed(
                        Routes.mosqueCharityShow,
                        arguments: {'id': id},
                      );
                      return;
                    }
                  }
                }

                // Fallback: open external URL
                final url = Uri.parse(link);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade100,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(
                    banner.cover,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(IconlyLight.image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBannerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 170,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }

  // Widget _buildFeaturedCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(28),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.02),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(14),
  //           decoration: BoxDecoration(
  //             color: AppColor.primaryColor.withOpacity(0.08),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: const Icon(
  //             IconlyBold.shield_done,
  //             color: AppColor.primaryColor,
  //             size: 28,
  //           ),
  //         ),
  //         const SizedBox(width: 20),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text('Solidaritas Palestina', style: pBold16),
  //               const SizedBox(height: 4),
  //               Text(
  //                 'Bantu saudara kita di Gaza',
  //                 style: pRegular12.copyWith(color: Colors.grey),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const Icon(IconlyLight.arrow_right_2, color: Colors.grey, size: 20),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomSheetQuran(
    BuildContext context,
    HomeScreenController controller,
  ) {
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
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(28),
      child: SingleChildScrollView(
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
            _buildRiwayatCard(context, controller),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Pilih Mushaf', style: pSemiBold16),
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
      ),
    );
  }

  Widget _buildRiwayatCard(
    BuildContext context,
    HomeScreenController controller,
  ) {
    return Obx(() {
      if (!AuthController.to.isLogin.value || controller.isOfflineMode.value)
        return const SizedBox();
      return InkWell(
        onTap: () {
          Get.back();
          _showTilawahHistoryDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
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

  Widget _bottomSheetMoreMenu(
    BuildContext context,
    HomeScreenController controller,
  ) {
    final menu = [
      {
        'title': 'Grup Ngaji',
        'icon': 'assets/images/png/group.png',
        'route': Routes.groupNgaji,
      },
      {
        'title': 'Leaderboard',
        'icon': 'assets/images/png/leaderboard.png',
        'route': Routes.leaderboard,
      },
      {
        'title': 'Penyebar Al-Quran',
        'icon': 'assets/images/png/share.png',
        'route': Routes.appShareLeaderboard,
      },
      {
        'title': 'Bahasa Arab Quran',
        'icon': 'assets/images/png/hafalan.png',
        'route': Routes.memorizeQuran,
      },
      {
        'title': 'Kalkulator Zakat',
        'icon': 'assets/images/png/giving-zakat.png',
        'route': Routes.calculatorZakat,
      },
    ];
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Layanan Lainnya', style: pSemiBold18),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: menu.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                if (menu[index]['route'] == Routes.groupNgaji &&
                    !AuthController.to.isLogin.value) {
                  Get.back();
                  controller.isEmailLogin.value = false;
                  Get.dialog(buildLoginDialog(controller));
                  return;
                }

                if (menu[index]['route'] == Routes.memorizeQuran &&
                    !AuthController.to.isLogin.value) {
                  Get.back();
                  controller.isEmailLogin.value = false;
                  Get.dialog(buildLoginDialog(controller));
                  return;
                }

                if (menu[index]['route'] != null) {
                  Get.back();
                  Get.toNamed(menu[index]['route'] as String);
                }
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 65,
                    width: 65,
                    child: Image.asset(
                      menu[index]['icon'] as String,
                      fit: BoxFit.contain,
                      width: 120,
                    ),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Get.context!.theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => Text(
                  controller.isEmailLogin.value
                      ? 'Login Akun'
                      : 'Login Sekarang',
                  style: pSemiBold18.copyWith(
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  controller.isEmailLogin.value
                      ? 'Masukkan email dan password akunmu'
                      : 'Simpan riwayat ngaji dan nikmati fitur lainnya',
                  style: pRegular12,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Obx(() {
                if (controller.isEmailLogin.value) {
                  return Column(
                    children: [
                      widget.TextInput(
                        controller: controller.emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      widget.TextInput(
                        controller: controller.passwordController,
                        hintText: 'Password',
                        obscureText: !controller.isPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              controller.isPasswordVisible.toggle(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: AuthController.to.isLoading.value
                            ? null
                            : () {
                                AuthController.to.loginWithEmail(
                                  controller.emailController.text,
                                  controller.passwordController.text,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
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
                            : Text(
                                'Masuk',
                                style: pSemiBold14.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
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
                      ElevatedButton(
                        onPressed: AuthController.to.isLoading.value
                            ? null
                            : () => AuthController.to.handleSignIn(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
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
                                    style: pMedium14.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      // const SizedBox(height: 16),
                      // ElevatedButton(
                      //   onPressed: AuthController.to.isLoadingAppleLogin.value
                      //       ? null
                      //       : () => AuthController.to.handleAppleSignIn(),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     minimumSize: const Size(double.infinity, 48),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(100),
                      //     ),
                      //   ),
                      //   child: AuthController.to.isLoadingAppleLogin.value
                      //       ? SizedBox(
                      //           height: 24,
                      //           width: 24,
                      //           child: CircularProgressIndicator(
                      //             color: Get.theme.colorScheme.primary,
                      //             strokeWidth: 2,
                      //           ),
                      //         )
                      //       : Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Image.asset(
                      //               'assets/images/png/apple.png',
                      //               width: 24,
                      //             ),
                      //             const SizedBox(width: 12),
                      //             Text(
                      //               'Login dengan Apple',
                      //               style: pMedium14.copyWith(
                      //                 color: Colors.black,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      // ),
                    ],
                  );
                }
              }),
              Obx(
                () => TextButton(
                  onPressed: () => controller.isEmailLogin.toggle(),
                  child: Text(
                    controller.isEmailLogin.value
                        ? 'Login dengan Google'
                        : 'Login dengan akun lainnya',
                    style: pMedium12.copyWith(
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Dengan login, kamu menyetujui ',
                  style: pRegular10.copyWith(
                    color: Get.theme.colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: pMedium10.copyWith(
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' serta ',
                      style: pRegular10.copyWith(
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: pMedium10.copyWith(
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' yang berlaku di Aplikasi',
                      style: pRegular10.copyWith(
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTilawahHistoryDialog(BuildContext context) {
    final tilawahController = Get.put(TilawahController());
    tilawahController.loadAllBookmarks();
    Get.dialog(
      Dialog(
        backgroundColor: context.theme.colorScheme.surface,
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
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            IconlyBold.document,
                            color: context.theme.colorScheme.primary,
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
                              'marker_id': b['marker_id'],
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

Widget _buildListBlog(BuildContext context, HomeScreenController controller) {
  final blogController = BlogController.to;
  return Obx(() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter - Always visible
        SizedBox(
          height: 30,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected =
                    blogController.selectedCategoryId.value == null;
                return InkWell(
                  onTap: () => blogController.filterByCategory(null),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? context.theme.colorScheme.primary
                            : context.isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade100,
                      ),
                      color: isSelected
                          ? context.theme.colorScheme.primary
                          : context.isDarkMode
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                    ),
                    child: Text(
                      'Semua',
                      style: pSemiBold10.copyWith(
                        color: isSelected
                            ? Colors.white
                            : context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }
              final category = blogController.categories[index - 1];
              final isSelected =
                  blogController.selectedCategoryId.value == category.id;
              return InkWell(
                onTap: () => blogController.filterByCategory(category.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? context.theme.colorScheme.primary
                          : context.isDarkMode
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                    ),
                    color: isSelected
                        ? context.theme.colorScheme.primary
                        : context.isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade100,
                  ),
                  child: Text(
                    category.name ?? '-',
                    style: pSemiBold10.copyWith(
                      color: isSelected
                          ? Colors.white
                          : context.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: blogController.categories.length + 1,
          ),
        ),
        const SizedBox(height: 20),

        // Blog content area
        if (blogController.isLoading.value && blogController.blogs.isEmpty)
          _buildBlogShimmer(context)
        else if (blogController.blogs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Belum ada blog.',
                style: pRegular12.copyWith(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final blog = blogController.blogs[index];
              return InkWell(
                onTap: () => Get.toNamed(Routes.showBlog, arguments: blog.slug),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: blog.thumbnail != null
                          ? CachedNetworkImage(
                              imageUrl: blog.thumbnail!,
                              height: 160,
                              width: double.infinity,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.50),
                                          BlendMode.darken,
                                        ),
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) => Container(
                                color: context.theme.colorScheme.primary
                                    .withOpacity(0.1),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      IconlyLight.image,
                                      color: Colors.grey.shade400,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gagal memuat gambar',
                                      style: pRegular10.copyWith(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 160,
                              width: double.infinity,
                              color: context.theme.colorScheme.primary
                                  .withOpacity(0.1),
                            ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (blog.category?.icon != null)
                            CachedNetworkImage(
                              imageUrl: blog.category!.icon!,
                              width: 20,
                              height: 20,
                              placeholder: (context, url) => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.category,
                                size: 16,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(
                              Icons.category,
                              size: 16,
                              color: Colors.white,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            blog.category?.name ?? 'General',
                            style: pMedium12.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              blog.title ?? '-',
                              style: pSemiBold14.copyWith(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.thumb_up,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${blog.likes ?? 0}',
                                style: pMedium12.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: blogController.blogs.length,
          ),
        if (blogController.isLoadingMore.value)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  });
}

Widget _buildBlogShimmer(BuildContext context) {
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) => Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDarkMode
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    separatorBuilder: (context, index) => const SizedBox(height: 16),
    itemCount: 3,
  );
}

Widget _buildListDoa(BuildContext context, HomeScreenController controller) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Obx(() {
      if (controller.isLoadingPrayers.value && controller.prayers.isEmpty) {
        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[50]!,
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        );
      }

      if (controller.prayers.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Belum ada doa hari ini.',
              style: pRegular12.copyWith(color: Colors.grey),
            ),
          ),
        );
      }

      return SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: controller.prayers.length,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final prayer = controller.prayers[index];
            return GestureDetector(
              onTap: () {
                if (AuthController.to.isLogin.value) {
                  Get.toNamed(Routes.showPrayer, arguments: prayer.id);
                } else {
                  Get.dialog(const HomeScreen().buildLoginDialog(controller));
                }
              },
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child:
                                    (prayer.isAnonymous == false &&
                                        prayer.userProfile != null)
                                    ? CachedNetworkImage(
                                        imageUrl: prayer.userProfile!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage:
                                                      imageProvider,
                                                ),
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: context
                                                  .theme
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              child: SizedBox(
                                                width: 12,
                                                height: 12,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: context
                                                          .theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: context
                                                  .theme
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              child: Text(
                                                prayer.userName?[0]
                                                        .toUpperCase() ??
                                                    'U',
                                                style: pBold12.copyWith(
                                                  color: context
                                                      .theme
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                      )
                                    : CircleAvatar(
                                        radius: 16,
                                        backgroundColor: context
                                            .theme
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        child: Text(
                                          (prayer.isAnonymous == true)
                                              ? 'H'
                                              : (prayer.userName?[0]
                                                        .toUpperCase() ??
                                                    'U'),
                                          style: pBold12.copyWith(
                                            color: context
                                                .theme
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prayer.isAnonymous == true
                                          ? 'Hamba Allah'
                                          : prayer.isMyPrayer == true
                                          ? 'Kamu'
                                          : prayer.userName ?? 'User',
                                      style: pSemiBold12.copyWith(
                                        color:
                                            context.theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      prayer.publishedAt ?? '-',
                                      style: pRegular10.copyWith(
                                        color: context
                                            .theme
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              prayer.content ?? '-',
                              style: pMedium12.copyWith(
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                                color: context.theme.colorScheme.onSurface
                                    .withOpacity(0.9),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Amens Count
                              Expanded(
                                child: prayer.amensCount != 0
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            IconlyBold.heart,
                                            size: 12,
                                            color: context
                                                .theme
                                                .colorScheme
                                                .primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${prayer.amensCount ?? 0} Aamiin',
                                            style: pSemiBold10.copyWith(
                                              color: context
                                                  .theme
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              // Aamiinkan Button
                              if (prayer.isMyPrayer != true)
                                InkWell(
                                  onTap: () {
                                    if (AuthController.to.isLogin.value) {
                                      if (prayer.isAmened == false) {
                                        controller.toggleAmen(prayer.id!);
                                      } else {
                                        return;
                                      }
                                    } else {
                                      Get.dialog(
                                        const HomeScreen().buildLoginDialog(
                                          controller,
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: prayer.isAmened == true
                                          ? context.theme.colorScheme.primary
                                          : context.theme.colorScheme.primary
                                                .withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          prayer.isAmened == true
                                              ? Icons.check_circle_rounded
                                              : IconlyLight.heart,
                                          size: 12,
                                          color: prayer.isAmened == true
                                              ? Colors.white
                                              : context
                                                    .theme
                                                    .colorScheme
                                                    .primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          prayer.isAmened == true
                                              ? 'Diaminkan'
                                              : 'Aamiinkan',
                                          style: pSemiBold10.copyWith(
                                            color: prayer.isAmened == true
                                                ? Colors.white
                                                : context
                                                      .theme
                                                      .colorScheme
                                                      .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }),
  );
}

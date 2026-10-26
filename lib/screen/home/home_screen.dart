import 'dart:ui';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/blog/blog_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/screen/quran_view/tilawah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';

import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart' as widget;
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quran_app/models/event_model.dart';
import 'package:marquee/marquee.dart';
import 'package:quran_app/api/url.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());
    Get.put(TilawahController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().markReady();
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Obx(() {
              final bgUrl =
                  AuthController.to.userData['selected_background_path_url'];
              final ImageProvider imageProvider =
                  (bgUrl != null && bgUrl.toString().isNotEmpty)
                  ? CachedNetworkImageProvider(bgUrl)
                  : const AssetImage('assets/images/png/bg-palestine.png')
                        as ImageProvider;

              return Container(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  bottom: 20,
                  top: MediaQuery.of(context).padding.top + 6,
                ),
                height: 280,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      // ignore: deprecated_member_use
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(
                          () => Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 140,
                                height: 18,
                                child: Marquee(
                                  text: controller.kabKota.value,
                                  style: pSemiBold12.copyWith(
                                    color: Colors.white,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 40.0,
                                  velocity: 30.0,
                                  pauseAfterRound: const Duration(seconds: 3),
                                  startPadding: 0.0,
                                  accelerationDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  accelerationCurve: Curves.easeIn,
                                  decelerationDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(Routes.theme);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Icon(
                              LucideIcons.palette,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Obx(
                        () => InkWell(
                          onTap: () {
                            Get.toNamed(Routes.prayerTimeDetail);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                controller.countdownText.value,
                                style: pSemiBold22.copyWith(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.calendarMasehi.value,
                                style: pMedium14.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '(${controller.calendarToday.value})',
                                style: pRegular14.copyWith(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      final nextPrayerName =
                          controller.displayPrayers.isNotEmpty
                          ? controller.displayPrayers.first['name']
                          : '';
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPrayerItem(
                            'Subuh',
                            controller.jadwalToday['fajr'],
                            isNext: nextPrayerName == 'Subuh',
                          ),
                          _buildPrayerItem(
                            'Dhuhur',
                            controller.jadwalToday['dhuhr'],
                            isNext: nextPrayerName == 'Dhuhur',
                          ),
                          _buildPrayerItem(
                            'Asar',
                            controller.jadwalToday['asr'],
                            isNext: nextPrayerName == 'Asar',
                          ),
                          _buildPrayerItem(
                            'Maghrib',
                            controller.jadwalToday['maghrib'],
                            isNext: nextPrayerName == 'Maghrib',
                          ),
                          _buildPrayerItem(
                            'Isya',
                            controller.jadwalToday['isha'],
                            isNext: nextPrayerName == 'Isya',
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            _buildProgressNgaji(),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 14),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.globalBorder, width: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Obx(
                () => RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${controller.formattedReadingHistoryTotal} ',
                    style: pSemiBold14.copyWith(color: AppColor.primaryColor),
                    children: [
                      TextSpan(
                        text: ' Halaman Quran telah dibaca',
                        style: pRegular12.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildMenuGrid(context),
            const SizedBox(height: 18),
            _buildBanner(),
            const SizedBox(height: 18),
            _buildListEvent(),
            _buildListFinishedEvent(),
            const SizedBox(height: 18),
            _buildListDoa(),
            const SizedBox(height: 18),
            _buildListBlog(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Get.toNamed(Routes.chatBot);
        },
        child: Image.asset('assets/gif/chat-bot.gif', width: 68, height: 68),
      ),
    );
  }

  Widget _buildProgressNgaji() {
    final controller = Get.find<HomeScreenController>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Obx(() {
        final stats = controller.weeklyStats;
        final summary = (stats['summary'] as List?) ?? [];
        final totalPages = stats['total_pages'] ?? 0;

        // Calculate max pages to normalize bar heights
        int maxPages = 1;
        for (var item in summary) {
          final pages = (item['total_pages'] as num?)?.toInt() ?? 0;
          if (pages > maxPages) {
            maxPages = pages;
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Ngaji',
                  style: pMedium12.copyWith(
                    color: AppColor.globalTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    text: '$totalPages',
                    style: pSemiBold14.copyWith(
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(
                        text: ' Halaman',
                        style: pSemiBold12.copyWith(
                          color: AppColor.globalTextSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: !AuthController.to.isLogin.value
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Get.dialog(buildLoginDialog(controller));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Masuk',
                            style: pMedium12.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : (controller.isLoadingWeekly.value && summary.isEmpty
                        ? Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: summary.map((item) {
                              final pages =
                                  (item['total_pages'] as num?)?.toInt() ?? 0;
                              final isToday =
                                  item['date'] ==
                                  DateTime.now().toIso8601String().split(
                                    'T',
                                  )[0];

                              // Max height is 40. Minimum height is 4 for empty.
                              double barHeight = (pages / maxPages) * 40.0;
                              if (barHeight < 4) barHeight = 4;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: barHeight,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: pages > 0
                                          ? AppColor.primaryColor
                                          : (Get.isDarkMode
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['day'].toString(),
                                    style: pMedium10.copyWith(
                                      color: isToday
                                          ? AppColor.primaryColor
                                          : AppColor.globalTextSecondary,
                                      fontWeight: isToday
                                          ? FontWeight.w800
                                          : null,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          )),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildListBlog() {
    final blogController = Get.put(BlogController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taman Syurga',
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => blogController.filterByCategory(null),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.globalBorder,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        color: blogController.selectedCategoryId.value == null
                            ? AppColor.primaryColor
                            : Colors.transparent,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        "Semua",
                        style: blogController.selectedCategoryId.value == null
                            ? pSemiBold10.copyWith(color: Colors.white)
                            : pRegular10.copyWith(
                                color: AppColor.globalTextSecondary,
                              ),
                      ),
                    ),
                  ),
                  if (blogController.categories.isNotEmpty)
                    ...blogController.categories.map((category) {
                      final isSelected =
                          blogController.selectedCategoryId.value ==
                          category.id;
                      return GestureDetector(
                        onTap: () =>
                            blogController.filterByCategory(category.id),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.globalBorder,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            color: isSelected
                                ? AppColor.primaryColor
                                : Colors.transparent,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text(
                            category.name ?? "Kategori",
                            style: isSelected
                                ? pSemiBold10.copyWith(color: Colors.white)
                                : pRegular10.copyWith(
                                    color: AppColor.globalTextSecondary,
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          Obx(() {
            if (blogController.isLoading.value &&
                blogController.blogs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                ),
              );
            }

            if (blogController.blogs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada artikel.',
                    style: pRegular12.copyWith(
                      color: AppColor.globalTextSecondary,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blogController.blogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final blog = blogController.blogs[index];
                return GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.showBlog, arguments: blog.slug);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 80,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image:
                                (blog.thumbnail != null &&
                                    blog.thumbnail!.isNotEmpty)
                                ? CachedNetworkImageProvider(blog.thumbnail!)
                                : const AssetImage(
                                        "assets/images/png/bg-palestine.png",
                                      )
                                      as ImageProvider,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          blog.title ?? "",
                          style: pSemiBold12.copyWith(
                            color: AppColor.globalTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListDoa() {
    final controller = Get.find<HomeScreenController>();
    return Obx(() {
      if (controller.isLoadingPrayers.value || controller.prayers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saling Mendoakan',
                  style: pSemiBold14.copyWith(
                    color: AppColor.globalTextSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.createPrayer);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.bookmarkPlus,
                        size: 18,
                        color: AppColor.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Buat Doa',
                        style: pMedium12.copyWith(color: AppColor.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.prayers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final prayer = controller.prayers[index];
                  return _buildPrayerCard(prayer, controller);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPrayerCard(prayer, HomeScreenController controller) {
    bool isAnon = prayer.isAnonymous == 1 || prayer.isAnonymous == true;
    bool isAmened = prayer.isAmened == 1 || prayer.isAmened == true;
    String name = isAnon ? "Hamba Allah" : (prayer.userName ?? "Hamba Allah");
    String time = prayer.publishedAt ?? "";

    return InkWell(
      onTap: () {
        if (AuthController.to.isLogin.value) {
          Get.toNamed(Routes.showPrayer, arguments: prayer.id);
        } else {
          Get.dialog(const HomeScreen().buildLoginDialog(controller));
        }
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.globalBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    image:
                        (!isAnon &&
                            prayer.userProfile != null &&
                            prayer.userProfile!.isNotEmpty)
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              prayer.userProfile!,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      (isAnon ||
                          prayer.userProfile == null ||
                          prayer.userProfile!.isEmpty)
                      ? Icon(
                          LucideIcons.circleUserRound,
                          size: 20,
                          color: Colors.grey.shade600,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: pMedium12.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(time, style: pRegular10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                '"${prayer.content ?? ""}"',
                style: pRegular12.copyWith(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (prayer.latestAmens != null &&
                    prayer.latestAmens!.isNotEmpty)
                  SizedBox(
                    width:
                        24.0 +
                        ((prayer.latestAmens!.length > 3
                                    ? 3
                                    : prayer.latestAmens!.length) -
                                1) *
                            16.0,
                    height: 24,
                    child: Stack(
                      children: List.generate(
                        prayer.latestAmens!.length > 3
                            ? 3
                            : prayer.latestAmens!.length,
                        (i) => Positioned(
                          left: i * 16.0,
                          child: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade300,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              image:
                                  (prayer.latestAmens![i].userProfile != null &&
                                      prayer
                                          .latestAmens![i]
                                          .userProfile!
                                          .isNotEmpty)
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        prayer.latestAmens![i].userProfile!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                (prayer.latestAmens![i].userProfile == null ||
                                    prayer.latestAmens![i].userProfile!.isEmpty)
                                ? Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  )
                                : null,
                          ),
                        ),
                      ).reversed.toList(),
                    ),
                  ),
                if (prayer.latestAmens != null &&
                    prayer.latestAmens!.isNotEmpty)
                  const SizedBox(width: 8),
                Text(
                  "di Aamiinkan ${prayer.amensCount ?? 0} kali",
                  style: pRegular10,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColor.globalBorder, thickness: 0.5),
            const SizedBox(height: 12),
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
                    Get.dialog(const HomeScreen().buildLoginDialog(controller));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isAmened
                          ? AppColor.primaryColor
                          : AppColor.globalBorder,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    color: isAmened
                        ? AppColor.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.heartHandshake,
                        size: 18,
                        color: isAmened
                            ? AppColor.primaryColor
                            : AppColor.globalTextSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Aamiin",
                        style: pMedium12.copyWith(
                          color: isAmened
                              ? AppColor.primaryColor
                              : AppColor.globalTextSecondary,
                        ),
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

  Widget _buildListEvent() {
    final controller = Get.find<HomeScreenController>();
    return Obx(() {
      if (controller.isLoadingEvents.value || controller.events.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Mendatang',
              style: pSemiBold14.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.events.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final event = controller.events[index];
                  return _buildEventCard(event);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEventCard(EventModel event) {
    String dateText = '-';
    if (event.startDate != null) {
      final startStr = DateFormat('dd MMM HH:mm').format(event.startDate!);
      if (event.endDate != null) {
        final endStr = DateFormat('HH:mm').format(event.endDate!);
        dateText = '$startStr - $endStr';
      } else {
        dateText = startStr;
      }
    }

    String priceText = 'Gratis';
    if (event.price != null && event.price! > 0) {
      if (event.formattedPrice != null && event.formattedPrice!.isNotEmpty) {
        priceText = event.formattedPrice!;
      } else {
        priceText = 'Rp ${event.price}';
      }
    }

    return GestureDetector(
      onTap: () {
        // Fallback or explicit navigation can be added here
        Get.toNamed(Routes.showEvent, arguments: event);
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.only(right: 6, left: 6, top: 6, bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.globalBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
                image: (event.thumbnail != null && event.thumbnail!.isNotEmpty)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(event.thumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pMedium12,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Icon(Icons.timer, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pMedium12.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  priceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pSemiBold12.copyWith(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Events that are over, newest first. Cards with a recording say so.
  Widget _buildListFinishedEvent() {
    final controller = Get.find<HomeScreenController>();
    return Obx(() {
      if (controller.finishedEvents.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(top: 18, left: 14, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Selesai',
              style: pSemiBold14.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.finishedEvents.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _buildFinishedEventCard(controller.finishedEvents[index]),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFinishedEventCard(EventModel event) {
    final dateText = event.endDate != null || event.startDate != null
        ? DateFormat('dd MMM yyyy').format((event.endDate ?? event.startDate)!)
        : '-';
    final hasVideo = event.hasVideo;

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.showEvent, arguments: event),
      child: Container(
        width: 280,
        padding: const EdgeInsets.only(right: 6, left: 6, top: 6, bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.globalBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                    image:
                        (event.thumbnail != null && event.thumbnail!.isNotEmpty)
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(event.thumbnail!),
                            fit: BoxFit.cover,
                            colorFilter: const ColorFilter.mode(
                              Colors.black26,
                              BlendMode.darken,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Selesai',
                      style: pSemiBold10.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                if (hasVideo)
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        LucideIcons.circlePlay,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pMedium12,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendarCheck,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pMedium12.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Icon(
                    hasVideo ? LucideIcons.video : LucideIcons.videoOff,
                    size: 14,
                    color: hasVideo
                        ? AppColor.primaryColor
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasVideo ? 'Rekaman tersedia' : 'Belum ada rekaman',
                    style: pSemiBold12.copyWith(
                      color: hasVideo
                          ? AppColor.primaryColor
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final controller = Get.find<HomeScreenController>();
    return Obx(() {
      if (controller.isLoadingBanner.value) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }

      if (controller.dataBanner.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 160,
        child: PageView.builder(
          controller: controller.sliderController,
          itemCount: controller.dataBanner.length,
          itemBuilder: (context, index) {
            final banner = controller.dataBanner[index];
            return GestureDetector(
              onTap: () {
                if (banner.redirectTo.isNotEmpty) {
                  DeepLinkService.handlePayload(banner.redirectTo);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(banner.cover),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMenuGrid(BuildContext context) {
    final controller = Get.find<HomeScreenController>();

    return Obx(() {
      if (controller.mainMenus.isEmpty) {
        return const SizedBox();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          children: controller.mainMenus.map((item) {
            VoidCallback? action;
            if (item.actionType == 'quran_bottom_sheet') {
              action = () => _showQuranBottomSheet(context);
            } else if (item.actionType == 'more_menu') {
              action = () => _showMoreMenuBottomSheet();
            }
            return _buildMenuItem(
              item.title,
              item.asset ?? '',
              item.route,
              action,
            );
          }).toList(),
        ),
      );
    });
  }

  void _showQuranBottomSheet(BuildContext context) {
    final controller = Get.find<HomeScreenController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.backgroundColorDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pilih Mushaf Al-Quran', style: pSemiBold16),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, color: AppColor.globalTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                _showTilawahHistoryDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.bookmark, size: 28, color: Colors.white),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Tilawah',
                          style: pSemiBold14.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lanjutkan bacaan terakhirmu',
                          style: pMedium12.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.72,
                ),
                itemCount: controller.quranMenus.length,
                itemBuilder: (context, index) {
                  final item = controller.quranMenus[index];
                  return InkWell(
                    onTap: () {
                      Get.back();
                      if (item.isPages == true) {
                        Get.toNamed(
                          item.route ?? Routes.quranPage,
                          arguments: {'slug': item.slug},
                        );
                      } else {
                        Get.toNamed(item.route ?? Routes.quranList);
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
                            child: _buildMenuIcon(
                              item.asset ?? 'assets/images/svg/q-yellow.svg',
                              size: 65,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: pMedium10,
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
      ),
      isScrollControlled: true,
    );
  }

  void _showTilawahHistoryDialog(BuildContext context) {
    final tilawahController = Get.put(TilawahController());
    tilawahController.loadAllBookmarks();
    Get.dialog(
      Dialog(
        backgroundColor: context.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Riwayat Tilawah', style: pSemiBold16),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: AppColor.globalTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Obx(() {
                  if (tilawahController.isLoading.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      ),
                    );
                  }
                  if (tilawahController.bookmarks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.bookmarkX,
                            size: 48,
                            color: AppColor.globalTextSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada riwayat tilawah.',
                            style: pMedium12.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: tilawahController.bookmarks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = tilawahController.bookmarks[index];
                      return InkWell(
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
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.globalBorder,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.bookOpenText,
                                  color: AppColor.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b['surah_name'] ?? 'Surah',
                                      style: pSemiBold14,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Halaman ${b['page_number']}',
                                      style: pMedium12.copyWith(
                                        color: AppColor.globalTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronRight,
                                size: 18,
                                color: AppColor.globalTextSecondary,
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

  void _showMoreMenuBottomSheet() {
    final controller = Get.find<HomeScreenController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.backgroundColorDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menu Lainnya', style: pSemiBold16),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, color: AppColor.globalTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(
              () => GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                children: controller.moreMenus.map((item) {
                  return _buildMenuItem(
                    item.title,
                    item.asset ?? '',
                    item.route,
                    null,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMenuIcon(String asset, {double size = 48}) {
    if (asset.isEmpty) {
      return SizedBox(width: size, height: size);
    }

    bool isNetwork = asset.startsWith('http') || asset.startsWith('/storage');
    String imageUrl = asset;
    if (asset.startsWith('/storage')) {
      imageUrl = '${Url.baseUrl}$asset';
    }

    bool isSvg = imageUrl.toLowerCase().endsWith('.svg');

    if (isSvg) {
      if (isNetwork) {
        return SvgPicture.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } else {
        return SvgPicture.asset(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    } else {
      if (isNetwork) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Icon(Icons.error, size: size),
        );
      } else {
        return Image.asset(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    }
  }

  Widget _buildMenuItem(
    String title,
    String asset,
    String? route,
    VoidCallback? action,
  ) {
    return InkWell(
      onTap: () {
        if (action != null) {
          action();
        } else if (route != null && route.isNotEmpty) {
          Get.toNamed(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.globalBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMenuIcon(asset, size: 48),
            const SizedBox(height: 4),
            Text(
              title,
              style: pMedium10,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerItem(String name, String? time, {bool isNext = false}) {
    return Column(
      children: [
        Text(
          time ?? '-',
          style: pRegular10.copyWith(
            color: isNext ? AppColor.secondaryColor : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: pRegular10.copyWith(
            color: isNext ? AppColor.secondaryColor : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          width: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isNext ? AppColor.secondaryColor : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget buildLoginDialog(HomeScreenController controller) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Get.context!.theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  controller.isEmailLogin.value
                      ? 'Masukkan email dan password akunmu'
                      : 'Simpan riwayat ngaji dan nikmati fitur lainnya',
                  style: pMedium12,
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
                          backgroundColor: AppColor.primaryColor,
                          elevation: 1,
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
                                    width: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Login dengan Google',
                                    style: pMedium12.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      if (Platform.isIOS) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: AuthController.to.isLoadingAppleLogin.value
                              ? null
                              : () => AuthController.to.handleAppleSignIn(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 1,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: AuthController.to.isLoadingAppleLogin.value
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Get.theme.colorScheme.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/png/apple.png',
                                      width: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Login dengan Apple',
                                      style: pMedium12.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ],
                  );
                }
              }),
              // Obx(
              //   () => TextButton(
              //     onPressed: () => controller.isEmailLogin.toggle(),
              //     child: Text(
              //       controller.isEmailLogin.value
              //           ? 'Login dengan Google'
              //           : 'Login dengan akun lainnya',
              //       style: pMedium12.copyWith(
              //         color: Get.theme.colorScheme.primary,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 24),
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
}

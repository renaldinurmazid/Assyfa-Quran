import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/prayer/list_prayer_controller.dart';
import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/home/home_screen.dart';

import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shimmer/shimmer.dart';

class ListPrayerScreen extends StatefulWidget {
  const ListPrayerScreen({super.key});

  @override
  State<ListPrayerScreen> createState() => _ListPrayerScreenState();
}

class _ListPrayerScreenState extends State<ListPrayerScreen> {
  final controller = Get.put(ListPrayerController());
  final ScrollController _allScrollController = ScrollController();
  final ScrollController _myScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _allScrollController.addListener(() {
      if (_allScrollController.position.pixels >=
          _allScrollController.position.maxScrollExtent - 200) {
        controller.fetchAllPrayers(isRefresh: false);
      }
    });
    _myScrollController.addListener(() {
      if (_myScrollController.position.pixels >=
          _myScrollController.position.maxScrollExtent - 200) {
        controller.fetchMyPrayers(isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _allScrollController.dispose();
    _myScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Saling Mendoakan', style: pSemiBold16),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: controller.tabController,
            labelColor: context.theme.colorScheme.primary,
            unselectedLabelColor: context.theme.colorScheme.onSurfaceVariant,
            indicatorColor: context.theme.colorScheme.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            labelStyle: pSemiBold14,
            unselectedLabelStyle: pRegular14,
            tabs: const [
              Tab(text: 'Semua Doa'),
              Tab(text: 'Doa Saya'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildPrayerList(
            context,
            controller,
            isAll: true,
            scrollController: _allScrollController,
          ),
          _buildPrayerList(
            context,
            controller,
            isAll: false,
            scrollController: _myScrollController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (AuthController.to.isLogin.value) {
            Get.toNamed(Routes.createPrayer);
          } else {
            Get.dialog(const HomeScreen().buildLoginDialog(Get.find()));
          }
        },
        backgroundColor: context.theme.colorScheme.primary,
        elevation: 2,
        icon: const Icon(IconlyBold.plus, color: Colors.white, size: 18),
        label: Text(
          'Buat Doa',
          style: pSemiBold14.copyWith(color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildPrayerList(
    BuildContext context,
    ListPrayerController controller, {
    required bool isAll,
    required ScrollController scrollController,
  }) {
    return Obx(() {
      final isLoading = isAll
          ? controller.isLoadingAll.value
          : controller.isLoadingMy.value;
      final isLoadingMore = isAll
          ? controller.isLoadingMoreAll.value
          : controller.isLoadingMoreMy.value;
      final prayers = isAll ? controller.allPrayers : controller.myPrayers;

      if (isLoading && prayers.isEmpty) {
        return _buildShimmerList();
      }

      if (prayers.isEmpty) {
        return _buildEmptyState(context, isAll);
      }

      return RefreshIndicator(
        onRefresh: () =>
            isAll ? controller.fetchAllPrayers() : controller.fetchMyPrayers(),
        color: context.theme.colorScheme.primary,
        child: ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: prayers.length + (isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == prayers.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: context.theme.colorScheme.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              );
            }
            final prayer = prayers[index];
            return _buildPrayerCard(context, controller, prayer);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, bool isAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.chat,
              size: 48,
              color: context.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isAll ? 'Belum Ada Doa Hari Ini' : 'Kamu Belum Membuat Doa',
            style: pBold16.copyWith(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            isAll
                ? 'Jadilah yang pertama mendoakan saudara kita'
                : 'Ayo mulai bagikan doamu sekarang',
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(
    BuildContext context,
    ListPrayerController controller,
    PrayerItem prayer,
  ) {
    bool isAnon = prayer.isAnonymous == true;
    String name = isAnon ? "Hamba Allah" : prayer.isMyPrayer == true ? "Kamu" : (prayer.userName ?? "Hamba Allah");
    String time = prayer.publishedAt ?? "";

    return InkWell(
      onTap: () {
        if (AuthController.to.isLogin.value) {
          Get.toNamed(Routes.showPrayer, arguments: prayer.id);
        } else {
          Get.dialog(const HomeScreen().buildLoginDialog(Get.find()));
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColor.globalBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    image: (!isAnon &&
                            prayer.userProfile != null &&
                            prayer.userProfile!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(prayer.userProfile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (isAnon ||
                          prayer.userProfile == null ||
                          prayer.userProfile!.isEmpty)
                      ? Icon(
                          LucideIcons.user,
                          size: 18,
                          color: Colors.grey.shade400,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: pSemiBold12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: pMedium10.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Prayer Content
            Text(
              '"${prayer.content ?? "-"}"',
              style: pMedium12.copyWith(
                color: context.theme.colorScheme.onSurface,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            // Divider
            const Divider(
              color: AppColor.borderColor,
              height: 1,
            ),
            const SizedBox(height: 12),

            // Footer: Amens + Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amen Avatars + Count
                Expanded(
                  child: Row(
                    children: [
                      if (prayer.latestAmens != null &&
                          prayer.latestAmens!.isNotEmpty) ...[
                        SizedBox(
                          width: 24.0 +
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
                                    color: Colors.grey.shade200,
                                    border: Border.all(
                                      color: context.theme.colorScheme.surface,
                                      width: 1.5,
                                    ),
                                    image: (prayer.latestAmens![i]
                                                    .userProfile !=
                                                null &&
                                            prayer.latestAmens![i]
                                                .userProfile!.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              prayer.latestAmens![i]
                                                  .userProfile!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: (prayer.latestAmens![i].userProfile ==
                                              null ||
                                          prayer.latestAmens![i].userProfile!
                                              .isEmpty)
                                      ? Icon(
                                          LucideIcons.user,
                                          size: 12,
                                          color: Colors.grey.shade400,
                                        )
                                      : null,
                                ),
                              ),
                            ).reversed.toList(),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (prayer.amensCount != 0)
                        Expanded(
                          child: Text(
                            "di Aamiinkan ${prayer.amensCount ?? 0} kali",
                            style: pMedium10.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),

                // Amen Button
                if (prayer.isMyPrayer != true)
                  GestureDetector(
                    onTap: () {
                      if (AuthController.to.isLogin.value) {
                        controller.toggleAmen(prayer.id!);
                      } else {
                        Get.dialog(
                          const HomeScreen().buildLoginDialog(Get.find()),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: prayer.isAmened == true
                            ? context.theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: prayer.isAmened == true 
                            ? context.theme.colorScheme.primary 
                            : AppColor.globalBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.heartHandshake,
                            size: 14,
                            color: prayer.isAmened == true
                                ? context.theme.colorScheme.primary
                                : AppColor.globalTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            prayer.isAmened == true ? 'Diaminkan' : 'Aamiinkan',
                            style: pSemiBold10.copyWith(
                              color: prayer.isAmened == true
                                  ? context.theme.colorScheme.primary
                                  : AppColor.globalTextSecondary,
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
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        highlightColor: context.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

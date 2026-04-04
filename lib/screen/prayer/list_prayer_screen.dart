import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/prayer/list_prayer_controller.dart';
import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/home_screen.dart';

import 'package:quran_app/theme/font.dart';
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
        backgroundColor: context.theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Saling Mendoakan',
          style: pBold18.copyWith(color: context.theme.colorScheme.primary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: controller.tabController,
              labelColor: context.theme.colorScheme.primary,
              unselectedLabelColor: context.theme.colorScheme.onSurfaceVariant,
              indicatorColor: context.theme.colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: pBold14,
              unselectedLabelStyle: pRegular14,
              tabs: const [
                Tab(text: 'Semua Doa'),
                Tab(text: 'Doa Saya'),
              ],
            ),
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
        elevation: 8,
        icon: const Icon(IconlyBold.plus, color: Colors.white, size: 20),
        label: Text('Buat Doa', style: pBold14.copyWith(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:
                      Get.context!.theme.colorScheme.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconlyLight.chat,
                  size: 64,
                  color:
                      Get.context!.theme.colorScheme.primary.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isAll ? 'Belum Ada Doa Hari Ini' : 'Kamu Belum Membuat Doa',
                style: pBold16.copyWith(
                  color: Get.context!.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAll
                    ? 'Jadilah yang pertama mendoakan saudara kita'
                    : 'Ayo mulai bagikan doamu sekarang',
                style: pRegular12.copyWith(
                  color: Get.context!.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () =>
            isAll ? controller.fetchAllPrayers() : controller.fetchMyPrayers(),
        color: context.theme.colorScheme.primary,
        child: ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: prayers.length + (isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            if (index == prayers.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    color: Get.context!.theme.colorScheme.primary,
                    strokeWidth: 2,
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

  Widget _buildPrayerCard(
    BuildContext context,
    ListPrayerController controller,
    PrayerItem prayer,
  ) {
    return GestureDetector(
      onTap: () {
        if (AuthController.to.isLogin.value) {
          Get.toNamed(Routes.showPrayer, arguments: prayer.id);
        } else {
          Get.dialog(const HomeScreen().buildLoginDialog(Get.find()));
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.theme.colorScheme.primary.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Ornament
            Positioned(
              right: -15,
              top: -15,
              child: Opacity(
                opacity: 0.04,
                child: Icon(
                  IconlyLight.chat,
                  size: 100,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                context.theme.colorScheme.primary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              context.theme.colorScheme.primary.withOpacity(0.1),
                          backgroundImage:
                              (prayer.isAnonymous == false &&
                                  prayer.userProfile != null)
                              ? NetworkImage(prayer.userProfile!)
                              : null,
                          child:
                              (prayer.isAnonymous == true ||
                                  prayer.userProfile == null)
                              ? Text(
                                  (prayer.isAnonymous == true)
                                      ? 'H'
                                      : (prayer.userName?[0].toUpperCase() ??
                                            'U'),
                                  style: pBold14.copyWith(
                                    color: context.theme.colorScheme.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                              style: pBold14.copyWith(
                                color: context.theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              prayer.publishedAt ?? '-',
                              style: pRegular10.copyWith(color: context.theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    prayer.content ?? '-',
                    style: pMedium14.copyWith(
                      color: context.theme.colorScheme.primary,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (prayer.amensCount != 0)
                        Row(
                          children: [
                            if (prayer.latestAmens != null &&
                                prayer.latestAmens!.isNotEmpty) ...[
                              SizedBox(
                                width:
                                    (prayer.latestAmens!.length > 3
                                            ? 3
                                            : prayer.latestAmens!.length) *
                                        14.0 +
                                    10,
                                height: 20,
                                child: Stack(
                                  children: List.generate(
                                    prayer.latestAmens!.length > 3
                                        ? 3
                                        : prayer.latestAmens!.length,
                                    (idx) {
                                      final amenUser = prayer.latestAmens![idx];
                                      return Positioned(
                                        left: idx * 14.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: context.theme.colorScheme.surface,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Get.context!.theme
                                                .colorScheme.primary
                                                .withOpacity(0.2),
                                            backgroundImage:
                                                amenUser.userProfile != null
                                                ? NetworkImage(
                                                    amenUser.userProfile!,
                                                  )
                                                : null,
                                            child: amenUser.userProfile == null
                                                ? Text(
                                                    amenUser.userName?[0]
                                                            .toUpperCase() ??
                                                        'A',
                                                    style: pBold10.copyWith(
                                                      fontSize: 6,
                                                      color: Get.context!.theme
                                                          .colorScheme.primary,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '${prayer.amensCount ?? 0} Aamiin',
                              style: pRegular10.copyWith(
                                color: Get.context!.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      if (prayer.isMyPrayer != true)
                        InkWell(
                          onTap: () {
                            if (AuthController.to.isLogin.value) {
                              controller.toggleAmen(prayer.id!);
                            } else {
                              Get.dialog(
                                const HomeScreen().buildLoginDialog(Get.find()),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: prayer.isAmened == true
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: context.theme.colorScheme.primary,
                                width: 1,
                              ),
                              boxShadow: prayer.isAmened == true
                                  ? [
                                      BoxShadow(
                                        color: context.theme.colorScheme.primary
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  prayer.isAmened == true
                                      ? Icons.check_circle
                                      : IconlyLight.heart,
                                  size: 14,
                                  color: prayer.isAmened == true
                                      ? Colors.white
                                      : context.theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  prayer.isAmened == true
                                      ? 'Diaminkan'
                                      : 'Aamiinkan',
                                  style: pSemiBold10.copyWith(
                                    color: prayer.isAmened == true
                                        ? Colors.white
                                        : context.theme.colorScheme.primary,
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
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.theme.colorScheme.surfaceVariant,
        highlightColor: context.theme.colorScheme.surface,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
